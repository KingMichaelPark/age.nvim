" Title:        Age
" Description:  A plugin to get strings from encrypted text files
" Last Change:  October 14, 2023
" Maintainer:   Michael Park <https://github.com/KingMichaelPark>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_age")
    finish
endif
let g:loaded_age = 1

" Defines a package path for Lua. This facilitates importing the
" Lua modules from the plugin's dependency directory.
let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/age"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

" Exposes the plugin's functions for use as commands in Neovim.
command! -nargs=* -complete=file AgeGet lua require("age").get(<f-args>, true)
command! -nargs=* -complete=file AgeList lua require("age").list(<f-args>, true)
command! -nargs=* -complete=file AgeJson lua require("age").from_json(<f-args>, true)
command! -nargs=* -complete=file AgeSops lua require("age").from_sops(<f-args>, true)
