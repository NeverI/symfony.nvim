if !exists('g:symfonyNvimDebug')
  let g:symfonyNvimDebug = v:false
endif

if !exists('g:symfonyNvimCamelCaseServiceNames')
  let g:symfonyNvimCamelCaseServiceNames = v:false
endif

let s:symfony = v:null

function! symfony#init(rootPath)
    let s:symfony = {
      \ 'rootPath': a:rootPath,
      \ 'console': 'app/console',
      \ 'services': {},
      \ 'events': [],
      \ 'tags': [],
      \ 'entities': [],
      \ 'parameters': [],
      \}
endfunction

function! symfony#getConsolePath()
  if s:symfony is v:null
    throw 'Symfony does not initialized yet'
  endif

  return s:symfony.rootPath . '/' . s:symfony.console
endfunction

function! symfony#getServices()
  return s:symfony is v:null ? {} : copy(s:symfony.services)
endfunction
endfunction

function! symfony#_clearServices()
  let s:symfony.services = []
endfunction

function! symfony#_setServices(services)
  let s:symfony.services = copy(a:services)

  if g:symfonyNvimDebug
    echom 'Cache builded with all service: '.len(s:symfony.allServiceNames). ' and public service: '.len(s:symfony.publicServiceNames)
  endif
endfunction
