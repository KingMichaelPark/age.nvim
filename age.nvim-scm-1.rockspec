local _MODREV, _SPECREV = 'scm', '-1'
rockspec_format = "3.0"
package = 'age.nvim'
version = _MODREV .. _SPECREV

description = {
    summary = 'load secrets from age encrypted text files ',
    labels = { "neovim" },
    detailed = [[
      age: For managing and loading secrets like API keys for plugins that need external configs.
   ]],
    homepage = 'http://github.com/KingMichaelPark/age.nvim',
    license = 'MIT/X11',
}

dependencies = {
    'lua >= 5.1, < 5.4',
    'luassert'
}

source = {
    url = 'git://github.com/KingMichaelPark/age.nvim',
}

build = {
    type = 'builtin',
    copy_directories = {
        'plugin', 'lua'
    }
}
test = {
    type = "command",
    command = "lua tests/test_age.lua"
}
