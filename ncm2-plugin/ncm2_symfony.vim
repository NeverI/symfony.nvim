" vim: foldmethod=marker

" utils {{{
let s:serviceWordPattern = '[a-zA-Z0-9\._]+'
let s:classWordPattern = '[a-zA-Z0-9\._\\]+'

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
" }}}
" service name autocomplete {{{
function! s:completeServicesForYml(context)
  call ncm2#complete(a:context, a:context.startccol, symfony#getSourceForAutocomplete('services'))
endfunction

call ncm2#register_source({
    \ 'name': 'symfonyServicesForYml',
    \ 'mark': 'sfService',
    \ 'enable': 1,
    \ 'ready': 1,
    \ 'priority': 9,
    \ 'scope': [ 'yamlSFconfig' ],
    \ 'word_pattern': s:serviceWordPattern,
    \ 'complete_pattern': [ "@", ' parent: ' ],
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

  call ncm2#complete(a:context, a:context.startccol, symfony#getSourceForAutocomplete('services'))
endfunction

call ncm2#register_source({
    \ 'name': 'symfonyServicesForPhp',
    \ 'mark': 'sfService',
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
" }}}
" parameter autocomplete {{{
function! s:completeParametersForYml(context)
  call ncm2#complete(a:context, a:context.startccol, symfony#getSourceForAutocomplete('parameters'))
endfunction

call ncm2#register_source({
    \ 'name': 'symfonyParametersForYml',
    \ 'mark': 'sfParameter',
    \ 'enable': 1,
    \ 'ready': 1,
    \ 'priority': 9,
    \ 'scope': [ 'yamlSFconfig' ],
    \ 'word_pattern': s:serviceWordPattern,
    \ 'complete_pattern': [ " %" ],
    \ 'complete_length': -1,
    \ 'popup_limit': 40,
    \ 'on_complete': function('s:completeParametersForYml'),
    \ })

function! s:completeParametersForPhp(context)
  let lines = getbufline(a:context.bufnr, a:context.lnum - 1, a:context.lnum)
  let lines[1] = lines[1][0:a:context.startccol - 18]
  if !s:isPreviousPattern(lines, ['\Wcontainer$', '\WgetContainer()$'])
    return []
  endif

  call ncm2#complete(a:context, a:context.startccol, symfony#getSourceForAutocomplete('parameters')))
endfunction

call ncm2#register_source({
    \ 'name': 'symfonyParametersForPhp',
    \ 'mark': 'sfParameter',
    \ 'enable': 1,
    \ 'ready': 1,
    \ 'priority': 9,
    \ 'scope': [ 'php' ],
    \ 'word_pattern': s:serviceWordPattern,
    \ 'complete_pattern': [ "->getParameter\\(['|\"]" ],
    \ 'complete_length': -1,
    \ 'popup_limit': 40,
    \ 'on_complete': function('s:completeParametersForPhp'),
    \ })
" }}}
" entity autocomplete {{{
function! s:completeShortEntityClasses(context)
  call ncm2#complete(a:context, a:context.startccol, symfony#getSourceForAutocomplete('entitiesShort'))
endfunction

call ncm2#register_source({
    \ 'name': 'symfonyShortEntityForPhp',
    \ 'mark': 'sfEntity',
    \ 'enable': 1,
    \ 'ready': 1,
    \ 'priority': 9,
    \ 'scope': [ 'php' ],
    \ 'word_pattern': s:classWordPattern,
    \ 'complete_pattern': [ "->getRepository\\(" ],
    \ 'complete_length': -1,
    \ 'popup_limit': 40,
    \ 'on_complete': function('s:completeShortEntityClasses'),
    \ })

function! s:completeEntityClasses(context)
  let lines = getbufline(a:context.bufnr, a:context.lnum - 1, a:context.lnum)
  if !s:isPreviousPattern(lines, ['->createQuery('])
    return []
  endif

  call ncm2#complete(a:context, a:context.startccol, symfony#getSourceForAutocomplete('entitiesFull'))
endfunction

call ncm2#register_source({
    \ 'name': 'symfonyFullEntityForPhp',
    \ 'mark': 'sfEntity',
    \ 'enable': 1,
    \ 'ready': 1,
    \ 'priority': 9,
    \ 'scope': [ 'php' ],
    \ 'word_pattern': s:classWordPattern,
    \ 'complete_pattern': [ ' FROM ', 'UPDATE ' ],
    \ 'complete_length': -1,
    \ 'popup_limit': 40,
    \ 'on_complete': function('s:completeEntityClasses'),
    \ })
" }}}
" class autocomplete for sFconfig {{{
let s:sFconfigPhpProc = yarp#py3({
    \ 'module': 'ncm2_sFconfig_php',
    \ 'on_load': { -> ncm2#set_ready(s:sFconfigPhpSource)}
    \ })

function! s:warmupPhpForConfig(context)
  call s:sFconfigPhpProc.jobstart()
endfunction

function! s:completePhpForConfig(context)
  echom a:context.startccol.' '.a:context.ccol.' '.a:context.base
  call s:sFconfigPhpProc.try_notify('on_complete', a:context)
endfunction

let s:sFconfigPhpSource = {
    \ 'name': 'symfonyClassForSfConfig',
    \ 'mark': 'php',
    \ 'enable': 1,
    \ 'ready': 0,
    \ 'priority': 9,
    \ 'scope': [ 'yamlSFconfig' ],
    \ 'word_pattern': s:classWordPattern,
    \ 'complete_pattern': [ " class: ..." ],
    \ 'complete_length': -1,
    \ 'popup_limit': 40,
    \ 'on_warmup': function('s:warmupPhpForConfig'),
    \ 'on_complete': function('s:completePhpForConfig'),
    \ }

call ncm2#register_source(s:sFconfigPhpSource)
" }}}
