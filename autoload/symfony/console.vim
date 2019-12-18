function! symfony#console#run(args, onExit) abort
  let s:context = {
    \   'stdout': [ '' ],
    \   'stderr': [ '' ],
    \   'on_stdout': function('s:onJobStdEvent'),
    \   'on_stderr': function('s:onJobStdEvent'),
    \}
  let s:context.on_exit = function('s:onJobExit', [ a:onExit ], s:context)

  let s:command =  symfony#get().rootPath . '/' . symfony#get().console . ' ' . a:args
  return jobstart(s:command, s:context)
endfunction

function! s:onJobStdEvent(jobId, data, event) dict
  if a:event is 'stdout'
    let self.stdout[-1] .= a:data[0]
    call extend(self.stdout, a:data[1:])
  elseif a:event is 'stderr'
    let self.stderr[-1] .= a:data[0]
    call extend(self.stderr, a:data[1:])
  endif
endfunction

function! s:onJobExit(onExit, jobId, data, event) dict
  call a:onExit(a:data, self.stderr, self.stdout)
endfunction

" debug container command for services, events, tags {{{
function! symfony#console#runDebugContainer() abort
  call symfony#console#run('debug:container --env=dev --no-ansi --format=md', function('s:parseDebugContainer'))
endfunction

function! s:parseDebugContainer(exitCode, stderr, stdout) abort
  if a:exitCode && len(a:stdout) < 5
    echom join(a:stderr, "\n\r")
    echom 'debug:container exited with an error code: ' . a:exitCode
    return
  endif

  call symfony#_clearServices()

  let service = v:null
  let GetServiceForLine = s:createDebugContainerGetServiceForLine()
  for line in a:stdout
    let service = GetServiceForLine(line)
    if service is v:null
      continue
    endif

    if s:matchDebugContainerClass(line, service)
      continue
    elseif s:matchDebugContainerBoolean(line, 'Public', service)
      continue
    elseif s:matchDebugContainerBoolean(line, 'Shared', service)
      continue
    elseif s:matchDebugContainerBoolean(line, 'Abstract', service)
      continue
    endif
  endfor

  if service isnot v:null
    call add(symfony#get().services, service)
  endif
endfunction

function! s:createDebugContainerGetServiceForLine() abort
  let service = v:null

  function! s:serviceGetter(line) closure
    let serviceName = matchstr(a:line, '\v^### \zs[a-z._]+')
    if !strlen(serviceName)
      return service
    endif

    if service isnot v:null
      call add(symfony#get().services, service)
    endif

    let service = {
      \ 'name': serviceName,
      \ 'class': '',
      \ 'public': v:false,
      \ 'shared': v:false,
      \ 'abstract': v:false,
      \ }
  endfunction

  return function('s:serviceGetter')
endfunction

function! s:matchDebugContainerClass(line, service)
  let className = matchstr(a:line, '\v^- Class: `\zs[a-zA-Z\\]+\ze`')
  if !strlen(className)
    return v:false
  endif

  let a:service.class = className
  let a:service.name = s:restoreCamelCaseFromClass(a:service.name, className)
endfunction

function! s:restoreCamelCaseFromClass(name, class)
  let splittedClass = map(split(a:class, '\\'), 'tolower(v:val[0:0]).v:val[1:]')
  let splittedName = split(a:name, '\.')

  let i = 0
  for namePart in splittedName
    for classPart in splittedClass
      let partIndex = stridx(tolower(classPart), namePart)
      if partIndex is -1
        continue
      endif

      let splittedName[i] = classPart[partIndex:(partIndex + strlen(namePart)) - 1]
      if partIndex isnot 0
        let splittedName[i] = tolower(splittedName[i][0:0]) . splittedName[i][1:]
      endif
      break
    endfor
    let i += 1
  endfor

  return join(splittedName, '.')
endfunction

function! s:matchDebugContainerBoolean(line, property, service)
  let propertyValue = matchstr(a:line, '\v^- '.a:property.': \zs(yes|no)\ze')
  if !strlen(propertyValue)
    return v:false
  endif

  let a:service[tolower(a:property)] = propertyValue ==? 'yes' ? v:true : v:false
endfunction
" }}}
