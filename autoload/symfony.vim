if !exists('g:symfonyNvimDebug')
  let g:symfonyNvimDebug = v:false
endif

if !exists('g:symfonyNvimCamelCaseServiceNames')
  let g:symfonyNvimCamelCaseServiceNames = v:false
endif

let s:symfony = v:null

function! symfony#startHere()
  let cwd = getcwd()
  let s:version = symfony#_getVersionFromFolder(cwd)

  if s:version is v:null
    if g:symfonyNvimDebug
      echom cwd . ' is not a symfony project root'
    endif
    return
  endif

  call symfony#init(cwd, s:version)
  :SymfonyBuildAllCache
endfunction

function! symfony#init(rootPath, version) abort
  if g:symfonyNvimDebug
    echom 'Symfony initalized in: ' . a:rootPath . ' with version: ' . a:version
  endif

  let s:symfony = {
    \ 'version': a:version,
    \ 'rootPath': a:rootPath,
    \ 'console': a:version[0] is '2' ? 'app/console' : 'bin/console',
    \ 'services': {},
    \ 'parameters': {},
    \ 'entities': [],
    \ 'autocompleteCache': {},
    \}
endfunction

function! symfony#_getVersionFromFolder(path)
  if !filereadable(a:path . '/composer.json')
    return v:null
  endif

  if filereadable(a:path . '/app/console')
    return '2.8'
  endif

  let composerJson = readfile(a:path . '/composer.json')
  let frameWorkLine = match(composerJson, '"symfony\/framework-bundle"')
  if frameWorkLine is -1
    return v:null
  endif

  return matchstr(composerJson[frameWorkLine], '": "\zs.\+\ze"')
endfunction

function! symfony#getVersion()
  if s:symfony is v:null
    throw 'Symfony does not initialized yet'
  endif

  return s:symfony.version
endfunction

function! symfony#getRootPath()
  if s:symfony is v:null
    throw 'Symfony does not initialized yet'
  endif

  return s:symfony.rootPath
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
  let s:symfony.autocompleteCache.publicServices = map(filter(values(s:symfony.services), 'v:val.public && !v:val.abstract'), 'v:val.name')

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
