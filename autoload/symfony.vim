if !exists('g:symfonyNvimCamelCaseServiceNames')
  let g:symfonyNvimCamelCaseServiceNames = v:true
endif

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

function! symfony#getServices()
  return s:symfony is v:null ? [] : copy(s:symfony.services)
endfunction
endfunction

function! symfony#_clearServices()
  let s:symfony.services = []
endfunction

