let s:serviceWordPattern = '[a-zA-z0-9\._]+'

function! s:completeServicesForYml(context)
  call ncm2#complete(a:context, a:context.startccol, symfony#getAllServiceNames())
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
  call ncm2#complete(a:context, a:context.startccol, symfony#getPublicServiceNames())
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
