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
