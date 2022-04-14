" ------------------------------------------------------------------------------
" Vim Composer                                                               {{{
"
" Author: Gianluca Arbezzano <gianarb92@gmail.com>
"
" Description:
" Run Composer from within Vim.
"
" Requires: Vim 6.0 or newer
"
" License: MIT
"
" }}}
" ------------------------------------------------------------------------------

command! -narg=* ComposerInstall call vim_composer#ComposerInstallFunc(<q-args>)
command! -narg=* ComposerRun call vim_composer#ComposerRunFunc(<q-args>)
command! -narg=* ComposerUpdate call vim_composer#ComposerUpdateFunc(<q-args>)
command! -narg=* ComposerRequire call vim_composer#ComposerRequireFunc(<q-args>)
command! -narg=* ComposerGlobalRequire call vim_composer#ComposerGlobalRequireFunc(<q-args>)

command! ComposerGet call vim_composer#ComposerGetFunc()
command! ComposerInit call vim_composer#ComposerInitFunc()
command! ComposerJSON call vim_composer#OpenComposerJSON()
command! ComposerDumpAutoload call vim_composer#ComposerDumpAutoloadFunc()

