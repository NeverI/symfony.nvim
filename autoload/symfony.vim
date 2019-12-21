if !exists('g:symfonyNvimDebug')
  let g:symfonyNvimDebug = v:false
endif

if !exists('g:symfonyNvimCamelCaseServiceNames')
  let g:symfonyNvimCamelCaseServiceNames = v:false
endif

let s:symfony = v:null

function! symfony#startHere()
  call symfony#init(getcwd())
  call symfony#console#runDebugContainer()
endfunction

function! symfony#init(rootPath) abort
  if g:symfonyNvimDebug
    echom 'Symfony initalized in: ' . a:rootPath
  endif

  let s:symfony = {
    \ 'version': '28',
    \ 'rootPath': a:rootPath,
    \ 'console': 'app/console',
    \ 'services': {},
    \ 'serviceNames': [],
    \ 'events': [],
    \ 'tags': [],
    \ 'entities': [],
    \ 'parameters': [],
    \}
endfunction

function! symfony#getVersion()
  if s:symfony is v:null
    throw 'Symfony does not initialized yet'
  endif

  return s:symfony.version
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

function! symfony#getServiceNames()
  return s:symfony is v:null ? [] : copy(s:symfony.serviceNames)
endfunction

function! symfony#_setServices(services)
  let s:symfony.services = copy(a:services)
  let s:symfony.serviceNames = map(values(s:symfony.services), 'v:val.name')

  if g:symfonyNvimDebug
    echom 'Cache builded with '.len(s:symfony.serviceNames). ' services'
  endif
endfunction
