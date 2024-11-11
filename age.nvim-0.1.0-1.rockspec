rockspec_format = "3.0"
package = 'age.nvim'
version = '0.1.0-1'

description = {
    summary = 'load secrets from age encrypted text files ',
    labels = { "neovim" },
    detailed = [[
      age: For managing and loading secrets like API keys for plugins that need external configs.
   ]],
    homepage = 'http://github.com/KingMichaelPark/age.nvim',
    license = 'BSD 3',
}

dependencies = {
    'lua >= 5.1, <= 5.4',
    'luassert'
}

source = {
    url = 'git://github.com/KingMichaelPark/age.nvim',
    tag = '0.1.0'
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
