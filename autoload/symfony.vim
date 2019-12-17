let s:symfony = v:null

function! symfony#init(rootPath)
    let s:symfony = {
      \ 'rootPath': a:rootPath,
      \ 'console': 'app/console',
      \ 'services': [],
      \ 'events': [],
      \ 'tags': [],
      \ 'entities': [],
      \ 'parameters': [],
      \}
endfunction

function! symfony#get()
  return s:symfony
endfunction

function! symfony#_clearServices()
  let s:symfony.services = []
endfunction

