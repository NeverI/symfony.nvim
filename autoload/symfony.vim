if !exists('g:symfonyNvimDebug')
  let g:symfonyNvimDebug = v:false
endif

if !exists('g:symfonyNvimCamelCaseServiceNames')
  let g:symfonyNvimCamelCaseServiceNames = v:false
endif

let s:symfony = v:null

function! symfony#startHere()
  call symfony#init(getcwd())
  :SymfonyBuildAllCache
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
    \ 'parameters': {},
    \ 'entities': [],
    \ 'autocompleteCache': {},
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

function! symfony#getParameters()
  return s:symfony is v:null ? {} : copy(s:symfony.parameters)
endfunction

function! symfony#_setParameters(parameters)
  let s:symfony.parameters = copy(a:parameters)
  let s:symfony.autocompleteCache.parameters = keys(s:symfony.parameters)

  if g:symfonyNvimDebug
    echom len(a:parameters) .' parameters gathered'
  endif
endfunction

function! symfony#getServices()
  return s:symfony is v:null ? {} : copy(s:symfony.services)
endfunction

function! symfony#_setServices(services)
  let s:symfony.services = copy(a:services)
  let s:symfony.autocompleteCache.services = map(values(s:symfony.services), 'v:val.name')

  if g:symfonyNvimDebug
    echom len(s:symfony.autocompleteCache.services). ' services gathered'
  endif
endfunction

function! symfony#getEntities()
  return s:symfony is v:null ? {} : copy(s:symfony.entities)
endfunction

function! symfony#_setEntities(entities)
  let s:symfony.entities = copy(a:entities)
  let s:symfony.autocompleteCache.entitiesFull = s:symfony.entities
  let shortEntityNames = []
  for entity in a:entities
    let classParts = split(entity, '\\')
    let className = classParts[-1:-1][0]
    call add(shortEntityNames, { 'word': className.'::class', 'menu': entity })
  endfor
  let s:symfony.autocompleteCache.entitiesShort = shortEntityNames

  if g:symfonyNvimDebug
    echom len(a:entities). ' entities gathered'
  endif
endfunction

function! symfony#getSourceForAutocomplete(name)
  if s:symfony is v:null || !has_key(s:symfony.autocompleteCache, a:name)
    return []
  endif

  return s:symfony.autocompleteCache[a:name]
endfunction
