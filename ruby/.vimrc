set makeprg=irb-jruby-1.6.4\ %

set omnifunc=rubycomplete#Complete 
let g:rubycomplete_buffer_loading = 1 
let g:rubycomplete_classes_in_global = 1 

" autoindent
autocmd FileType ruby,eruby set autoindent|set smartindent

" 4 space tabs
autocmd FileType ruby,eruby set tabstop=4|set shiftwidth=4|set expandtab|set softtabstop=4

autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
