-- Imports the plugin's additional Lua modules.
local utils = require("age.utils")

-- Creates an object for the module. All of the module's
-- functions are associated with this object, which is
-- returned when the module is called with `require`.
local M = {}

-- Routes calls made to this module to functions in the
-- plugin's other modules.
M.get = utils.get
M.list = utils.list
M.from_json = utils.from_json
M.from_sops = utils.from_sops

function M.setup(spec, opts)
    if type(spec) == "table" and spec.spec then
        opts = spec
    else
        opts = opts or {}
        opts.spec = spec
    end

    if vim.fn.executable('age') == 0 then
        return vim.notify("Age requires age to be installed and executable", vim.log.levels.ERROR,
            { title = "age.nvim" })
    end
end

return M
