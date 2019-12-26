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

  let cword = expand('<cWORD>')
  if cword[0] is '@'
    return symfony#goto#service(cword[1:], a:openMode)
  endif

  if cword[0] is '%' && cword[strlen(cword) - 1] is '%'
    return symfony#goto#parameter(cword[1:strlen(cword) - 2], a:openMode)
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
    exec 'silent ' . cmd . ' ' . fnameescape(a:result[0].file)
    exec 'keepjumps normal! ' . a:result[0].lnum . 'z.'
    call cursor(a:result[0].lnum, a:result[0].col)
  endif
endfunction

function! symfony#goto#parameter(name, openMode) abort
  let CreateCallback = s:asyncResultMerger(function('s:gotoResult', [ a:openMode ]))
  call symfony#process#grep('\s+' . a:name . ': .+$', '**/Resources/config/*.y*ml', CreateCallback())
  call symfony#process#grep('<parameter key="' . a:name . '"', '**/Resources/config/*.xml', CreateCallback())
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
