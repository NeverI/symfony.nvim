function! symfony#console#run(args, onExit) abort
  return symfony#process#exec(symfony#getConsolePath() . ' ' . a:args, a:onExit)
endfunction
