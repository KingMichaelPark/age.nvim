local M = {}
M.check = function()
    vim.health.start("age.nvim report")

    -- Check for age executable
    if vim.fn.executable("age") == 1 then
        vim.health.ok("`age` executable found.")
    else
        vim.health.error("`age` executable not found in PATH.")
    end

    -- Check for sops executable
    if vim.fn.executable("sops") == 1 then
        vim.health.ok("`sops` executable found.")
    else
        vim.health.warn("`sops` executable not found in PATH. This is only required for SOPS integration.")
    end
end
return M
