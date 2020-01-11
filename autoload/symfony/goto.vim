function! symfony#goto#inYamlSFconfig(openMode) abort
  let line = getline('.')
  let cls = matchstr(line, '\v class: \zs([a-zA-Z0-9\\]+)$')
  if cls isnot ''
    return symfony#goto#class(cls, a:openMode)
  endif

  let parent = matchstr(line, '\v parent: \zs([a-zA-Z0-9_\.]+)$')
  if parent isnot ''
    return symfony#goto#service(parent, a:openMode)
  endif

  let cword = substitute(expand('<cWORD>'), "['\"]", '', 'g')
  if cword[0] is '@'
    return symfony#goto#service(cword[1:], a:openMode)
  endif

  if cword[0] is '%' && cword[strlen(cword) - 1] is '%'
    return symfony#goto#parameter(cword[1:strlen(cword) - 2], a:openMode)
  endif

  if cword =~ "\.twig$"
    return symfony#goto#template(cword, a:openMode)
  endif
endfunction

function! symfony#goto#service(name, openMode) abort
  let CreateCallback = s:asyncResultMerger(function('s:gotoResult', [ a:openMode ]))
  call symfony#process#grep('\s+' . a:name . ':$', '**/Resources/config/*.y*ml', CreateCallback())
  call symfony#process#grep('<service.+id="' . a:name . '"', '**/Resources/config/*.xml', CreateCallback())
endfunction

function! s:asyncResultMerger(onFinish) abort
  let result = []
  let finished = 0
  let counter = 0
  let OnFinish = a:onFinish

  function! s:onJobFinish(lines) abort closure
    call extend(result, a:lines)
    let finished += 1
    if finished is counter
      call OnFinish(result)
    endif
  endfunction

  function! s:getter() abort closure
    let counter += 1
    return function('s:onJobFinish')
  endfunction

  return function('s:getter')
endfunction

function! s:gotoResult(openMode, result) abort
  if len(a:result) is 0
    return
  endif

  if len(a:result) is 1
    let cmd = a:openMode ==? 'split' ? 'split' : 'edit'
    let cmd = a:openMode ==? 'vsplit' ? 'vertical split' : cmd
    let cmd = a:openMode ==? 'tab' ? 'tab' : cmd
    exec 'silent ' . cmd . ' ' . fnameescape(a:result[0].filename)
    exec 'keepjumps normal! ' . a:result[0].lnum . 'z.'
    return cursor(a:result[0].lnum, a:result[0].col)
  endif

  call setqflist([], 'r', {'title': 'Symfony multiple match', 'items': a:result})
  :copen
endfunction

function! symfony#goto#parameter(name, openMode) abort
  let CreateCallback = s:asyncResultMerger(function('s:gotoResult', [ a:openMode ]))
  let rootConfigPath = symfony#getRootPath() . (symfony#getVersion()[0] is '2' ? '/app/config' : '/config')
  call symfony#process#grep('\s+' . a:name . ': .+$', '*.y*ml', CreateCallback(), rootConfigPath)
  call symfony#process#grep('\s+' . a:name . ': .+$', '**/Resources/config/*.y*ml', CreateCallback())
  call symfony#process#grep('<parameter key="' . a:name . '"', '**/Resources/config/*.xml', CreateCallback())
  call symfony#process#grep('<parameter key="' . a:name . '"', '*.xml', CreateCallback(), rootConfigPath)
endfunction

function! symfony#goto#class(cls, openMode) abort
  let target = a:openMode ==? 'vsplit' ? 'vsplit' : 'focused_window'
  let target = a:openMode ==? 'split' ? 'hsplit' : target
  let target = a:openMode ==? 'tab' ? 'new_tab' : target

  let source = '<?php namespace NvimSymfony; use ' . a:cls . ';'
  let result = phpactor#rpc('goto_definition', {
        \ 'source': source,
        \ 'offset': strlen(source) - 3,
        \ 'path': symfony#getRootPath(),
        \ 'target': target
        \ })
endfunction

function! symfony#goto#template(path, openMode) abort
  let pathParts = split(a:path, ':')
  if len(pathParts) < 3
    return
  endif

  let bundle = remove(pathParts, 0, 0)[0]
  if pathParts[0] is ''
    call remove(pathParts, 0, 0)
  endif

  let pattern = '**/Resources/views/' . join(pathParts, '/')
  let proc = symfony#process#exec(
    \ "rg --follow --files --vimgrep --glob '" . pattern . "' "
    \ . symfony#getRootPath() . '/src ' . symfony#getRootPath() . '/vendor'
    \, function('s:gotoByBundle', [ a:openMode, bundle ])
    \ )
endfunction

function! s:gotoByBundle(openMode, bundle, data, stderr, files) abort
  let relevantFiles = []
  let transformedBundle = substitute(a:bundle, '\(\u\)', '-\l\1', 'g')
  for foundFile in a:files
    let transformedFile = substitute(foundFile, '\/\(\u\)', '-\l\1', 'g')
    let transformedFile = substitute(transformedFile, '\/', '-', 'g')
    let transformedFile = substitute(transformedFile, '\(\u\)', '-\l\1', 'g')
    if stridx(transformedFile, transformedBundle) isnot -1
      call add(relevantFiles, {'filename':foundFile, 'lnum': 1, 'col': 1})
    endif
  endfor

  call s:gotoResult(a:openMode, relevantFiles)
endfunction

function! symfony#goto#inPhp(openMode) abort
  let stringUnderCursor = s:getStringUnderTheCursor()

  if stringUnderCursor is v:null
    return s:usePhpActorDefinitionJumper(a:openMode)
  endif

  if stringUnderCursor.value =~ '\.twig$'
    return symfony#goto#template(get(stringUnderCursor, 'value'), a:openMode)
  endif

  let subjectAndMethod = s:getSubjectAndMethodAt(stringUnderCursor.startAt)

  if subjectAndMethod is v:null
    return s:usePhpActorDefinitionJumper(a:openMode)
  endif

  if subjectAndMethod.subject is 'container' || subjectAndMethod.subject is 'getContainer()'
    if subjectAndMethod.method is 'get'
      return symfony#goto#service(stringUnderCursor.value, a:openMode)
    elseif subjectAndMethod.method is 'getParameter'
      return symfony#goto#parameter(stringUnderCursor.value, a:openMode)
    endif
  endif

  call s:usePhpActorDefinitionJumper(a:openMode)
endfunction

function! s:getStringUnderTheCursor() abort
  let line = getline('.')
  if strlen(line) > 200
    return v:null
  endif

  let position = col('.')
  let stringPattern = '\v^\zs([a-zA-Z0-9\.:_\\\/]+)\ze[''"]'
  let beforeCursor = matchstr(s:reverseString(line[0:position]), stringPattern)
  if !strlen(beforeCursor)
    return v:null
  endif

  return {
    \ 'value': s:reverseString(beforeCursor) . matchstr(line[position + 1:-1], stringPattern),
    \ 'startAt': position - strlen(beforeCursor)
    \ }
endfunction

function! s:reverseString(string) abort
  return join(reverse(split(a:string, '.\zs')), '')
endfunction

function! s:usePhpActorDefinitionJumper(openMode) abort
  if a:openMode ==? 'vsplit'
    return phpactor#GotoDefinitionVsplit()
  endif
  if a:openMode ==? 'split'
    return phpactor#GotoDefinitionHsplit()
  endif
  if a:openMode ==? 'tab'
    return phpactor#GotoDefinitionTab()
  endif

  call phpactor#GotoDefinition()
endfunction

function! s:getSubjectAndMethodAt(before) abort
  let lines = getbufline(bufname('%'), line('.') - 2, line('.'))
  let lines[-1] = lines[-1][0:a:before - 1]
  let lines = map(lines, "trim(v:val)")
  let pattern = '\v\(([a-zA-Z0-9]+)\>-([a-zA-Z0-9\(\)]+)'
  let match = matchlist(s:reverseString(join(lines, '')), pattern)

  if len(match)
    return { 'subject': s:reverseString(match[2]), 'method': s:reverseString(match[1]) }
  endif

  return v:null
endfunction
