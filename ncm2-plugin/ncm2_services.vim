let s:serviceWordPattern = '[a-zA-Z0-9\._]+'

function! s:completeServicesForYml(context)
  call ncm2#complete(a:context, a:context.startccol, symfony#getServiceNames())
endfunction

call ncm2#register_source({
    \ 'name': 'symfonyServicesForYml',
    \ 'mark': 'sFService',
    \ 'enable': 1,
    \ 'ready': 1,
    \ 'priority': 9,
    \ 'scope': [ 'yamlSFconfig' ],
    \ 'word_pattern': s:serviceWordPattern,
    \ 'complete_pattern': [ "@" ],
    \ 'complete_length': -1,
    \ 'popup_limit': 40,
    \ 'on_complete': function('s:completeServicesForYml'),
    \ })

function! s:completeServicesForPhp(context)
  let lines = getbufline(a:context.bufnr, a:context.lnum - 1, a:context.lnum)
  let lines[1] = lines[1][0:a:context.startccol - 9]
  if !s:isPreviousPattern(lines, ['\Wcontainer$', '\WgetContainer()$'])
    return []
  endif

  call ncm2#complete(a:context, a:context.startccol, symfony#getServiceNames())
endfunction

function! s:isPreviousPattern(lines, patterns)
  for line in a:lines
    for pattern in a:patterns
      if match(line, pattern) isnot -1
        return v:true
      endif
    endfor
  endfor
  return v:false
endfunction

call ncm2#register_source({
    \ 'name': 'symfonyServicesForPhp',
    \ 'mark': 'sFService',
    \ 'enable': 1,
    \ 'ready': 1,
    \ 'priority': 9,
    \ 'scope': [ 'php' ],
    \ 'word_pattern': s:serviceWordPattern,
    \ 'complete_pattern': [ "->get\\(['|\"]" ],
    \ 'complete_length': -1,
    \ 'popup_limit': 40,
    \ 'on_complete': function('s:completeServicesForPhp'),
    \ })
