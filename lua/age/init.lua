local utils = require("age.utils")

local M = {}

-- Routes calls made to this module to functions in the
-- plugin's other modules.
M.get = utils.get
M.list = utils.list
M.from_json = utils.from_json
M.from_sops = utils.from_sops

--- Initializes the age plugin with the given configuration
--- @param spec table|string The specification for age configuration. Can be either a table with a spec field or a direct spec value
--- @param opts? table Optional configuration table. If spec is a table with spec field, this parameter is ignored
--- @return nil|string Returns nil on success, or returns an error notification if age is not installed
function M.setup(spec, opts)
    if type(spec) == "table" and spec.spec then
        opts = spec
    else
        opts = opts or {}
        opts.spec = spec
    end

    -- Ensure age is executable
    if vim.fn.executable('age') == 0 then
        return vim.notify("Age requires age to be installed and executable", vim.log.levels.ERROR,
            { title = "age.nvim" })
    end
end

return M
