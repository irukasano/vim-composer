
if !exists("g:composer_cmd")
    if filereadable('./composer.phar')
        let g:composer_cmd='php ./composer.phar'
    else
        let g:composer_cmd='composer'
    endif
endif

if !exists("g:composer_install_callback")
    let g:composer_install_callback = ""
endif


" cf) https://tyru.hatenablog.com/entry/20130819/spawn_application_in_the_background_by_pure_vimscript
" Execute program in the background from Vim.
" Return an empty string always.
"
" If a:expr is a List, shellescape() each argument.
" If a:expr is a String, the arguments are passed as-is.
"
" Windows:
" Using :!start , execute program without via cmd.exe.
" Spawning 'expr' with 'noshellslash'
" keep special characters from unwanted expansion.
" (see :help shellescape())
"
" Unix:
" using :! , execute program in the background by shell.
function! s:spawn(expr)
    let s:is_windows = has('win32') || has ('win64')
    if s:is_windows
        let shellslash = &l:shellslash
        setlocal noshellslash
    endif
    try
        if type(a:expr) is type([])
            let special = 1
            let cmdline = join(map(a:expr, 'shellescape(v:val, special)'), ' ')
        elseif type(a:expr) is type("")
            let cmdline = a:expr
        else
            throw 'spawn(): invalid argument (value type:'.type(a:expr).')'
        endif
        if s:is_windows
            silent execute '!start' cmdline
        else
            silent execute '!' cmdline
        endif
    finally
        if s:is_windows
            let &l:shellslash = shellslash
        endif
    endtry
    return ''
endfunction

function! s:ComposerRunFunc(action)
    let s:action = a:action
    let s:composer = g:composer_cmd . ' ' . s:action
    call s:spawn(s:composer)
endfunction

function! vim_composer#ComposerGetFunc()
    call s:spawn("curl -Ss https://getcomposer.org/installer | php")
endfunction

function! vim_composer#OpenComposerJSON()
    if filereadable("./composer.json")
        exe "vsplit ./composer.json"
    else
        echo "Composer json doesn't exist"
    endif
endfunction

function! vim_composer#ComposerInstallFunc(arg)
    call s:ComposerRunFunc("install")
    if len(g:composer_install_callback) > 0
        exe "call ".g:composer_install_callback."()"
    endif
endfunction

function! vim_composer#ComposerInitFunc() abort
    call s:ComposerRunFunc("init")
endfunction

function! vim_composer#ComposerUpdateFunc(arg) abort
    call s:ComposerRunFunc("update")
endfunction

function! vim_composer#ComposerRequireFunc(arg) abort
    if ( ! s:existsPackage(".", a:arg))
        call s:ComposerRunFunc("require " . a:arg)
    endif
endfunction

function! vim_composer#ComposerGlobalRequireFunc(arg) abort
    let s:global_composer_path = getenv('COMPOSER_HOME')
    if ( s:global_composer_path is v:null)
        let s:home = getenv('HOME')
        let s:global_composer_path = s:home."/.config/composer"
    endif
    if ( ! s:existsPackage(s:global_composer_path, a:arg))
        call s:ComposerRunFunc("global require " . a:arg)
    endif
endfunction

function! s:existsPackage(arg1, arg2)
    let s:composer_dir = a:arg1
    let s:package_dir = s:composer_dir . '/vendor/' . tolower(a:arg2)
    return isdirectory(s:package_dir)
endfunction

function! vim_composer#ComposerDumpAutoloadFunc() abort
    call s:ComposerRunFunc("dump-autoload")
endfunction

function! vim_composer#ComposerKnowWhereCurrentFileIs() abort
    let g:currentWord = expand('<cword>')
    let l:command = "grep " . g:currentWord . " ./vendor/composer -R | awk '{print $6}' | awk -F\\' '{print $2}'"
    let l:commandFileFound = l:command . ' | wc -l'
    let g:numberOfResults = system(l:commandFileFound)
    if g:numberOfResults == 1
        let l:fileName = system(l:command)
        let l:openFileCommand = 'tabe .' . l:fileName
        exec l:openFileCommand
    else
        call g:VimComposerCustomBehavior(g:currentWord)
    endif
endfunction


