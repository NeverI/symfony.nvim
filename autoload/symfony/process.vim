function! symfony#process#exec(command, onExit) abort
  let s:context = {
    \   'stdout': [ '' ],
    \   'stderr': [ '' ],
    \   'on_stdout': function('s:onJobStdEvent'),
    \   'on_stderr': function('s:onJobStdEvent'),
    \}
  let s:context.on_exit = function('s:onJobExit', [ a:onExit ], s:context)

  if g:symfonyNvimDebug
    echom 'Calling process: ' . a:command
  endif

  return jobstart(a:command, s:context)
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

function! symfony#process#grep(pattern, filePatternGlob, onExit) abort
  return symfony#process#exec(
    \ "rg '" . a:pattern . "' --follow -i --vimgrep --glob '" . a:filePatternGlob . "' "
    \ . symfony#getRootPath() . '/src ' . symfony#getRootPath() . '/vendor'
    \ , function('s:splitGrepResult', [ a:onExit ])
    \ )
endfunction

function! s:splitGrepResult(cb, data, stderr, lines) abort
  let result = []
  for line in a:lines
    let parts = split(line, ':')
    if !len(parts)
      continue
    endif

    call add(result, {
      \ 'filename': remove(parts, 0, 0)[0],
      \ 'lnum': remove(parts, 0, 0)[0],
      \ 'col': remove(parts, 0, 0)[0],
      \ 'text': trim(join(parts, ':'))
      \})
  endfor

  call a:cb(result)
endfunction
