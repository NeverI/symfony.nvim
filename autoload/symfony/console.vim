function! symfony#console#run(args, onExit) abort
  let s:context = {
    \   'stdout': [ '' ],
    \   'stderr': [ '' ],
    \   'on_stdout': function('s:onJobStdEvent'),
    \   'on_stderr': function('s:onJobStdEvent'),
    \}
  let s:context.on_exit = function('s:onJobExit', [ a:onExit ], s:context)

  let s:command =  symfony#getConsolePath() . ' ' . a:args

  if g:symfonyNvimDebug
    echom 'Calling symfony command: ' . s:command
  endif

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
  call symfony#console#run('debug:container --env=dev --no-ansi --format=md --show-private', {
        \ exitCode, stderr, stdout ->
        \ symfony#_setServices(symfony#console#_parseDebugContainer(exitCode, stderr, stdout)) })
endfunction

function! symfony#console#_parseDebugContainer(exitCode, stderr, stdout) abort
  if g:symfonyNvimDebug
    echom 'debug container call finished'
  endif

  if a:exitCode && len(a:stdout) < 5
    echom join(a:stderr, "\n\r")
    echom 'debug:container exited with an error code: ' . a:exitCode
    return
  endif

  let services = {}
  let service = v:null
  let GetServiceForLine = s:createDebugContainerGetServiceForLine()
  for line in a:stdout
    let service = GetServiceForLine(line, services)
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
    elseif s:matchDebugContainerAlias(line, service)
      continue
    endif
  endfor

  if service isnot v:null
    let services[tolower(service.name)] = service
  endif

  return s:postProcessDebugContainer(services)
endfunction

function! s:createDebugContainerGetServiceForLine() abort
  let service = v:null

  function! s:serviceGetter(line, services) closure abort
    let serviceName = matchstr(a:line, '\v^### \zs[a-z._]+')
    if !strlen(serviceName)
      return service
    endif

    if match(serviceName, '\v[a-z0-9]\{64\}_[0-9]+') is 0 && service is v:null
      return v:null
    endif

    if service isnot v:null
      let a:services[tolower(service.name)] = service
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
  if g:symfonyNvimCamelCaseServiceNames
    let a:service.name = s:restoreCamelCaseFromClass(a:service.name, split(a:service.class, '\\'))
  endif
endfunction

function! s:restoreCamelCaseFromClass(name, splittedSource)
  let splittedName = split(a:name, '\.')

  let i = 0
  for namePart in splittedName
    for sourcePart in a:splittedSource
      let partIndex = stridx(tolower(sourcePart), namePart)
      if partIndex is -1 || toupper(sourcePart) is sourcePart
        continue
      endif

      let splittedName[i] = sourcePart[partIndex:(partIndex + strlen(namePart)) - 1]
      let splittedName[i] = tolower(splittedName[i][0:0]) . splittedName[i][1:]
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

function! s:matchDebugContainerAlias(line, service)
  let serviceName = matchstr(a:line, '\v^- Service: `\zs[a-z0-9\._]+\ze`')
  if !strlen(serviceName)
    return v:false
  endif

  let a:service.aliasSource = serviceName
endfunction

function! s:postProcessDebugContainer(services)
  if !g:symfonyNvimCamelCaseServiceNames
    return a:services
  endif

  for [key, service] in items(a:services)
    if has_key(service, 'aliasSource')
      if !has_key(a:services, service.aliasSource)
        throw 'Missing alias source for service: ' . service.name
      endif

      let aliasedService = a:services[service.aliasSource]
      let service.name = s:restoreCamelCaseFromClass(service.name, split(aliasedService.name, '\.'))
      let service.name = s:restoreCamelCaseFromClass(service.name, split(aliasedService.class, '\\'))
    endif
  endfor

  return a:services
endfunction
" }}}
