-- Creates an object for the module.
local M = {}

-- Opens the provided file and returns the contents as a string
function M.get(secret_path, identity_filepath, print_secret)
    print_secret = print_secret or false
    local handle = io.popen("age --decrypt --identity " .. identity_filepath .. " " .. secret_path)
    if handle ~= nil then
        local result = handle:read("*a")
        if print_secret then
            print(result)
        end
        handle:close()
        if string.sub(result, -1) == '\n' then
            result = string.sub(result, 1, -2)
        end
        return result
    end
end

-- Opens the provided file and returns each row's value as a table entry
function M.list(secret_path, identity_filepath, print_secret)
    print_secret = print_secret or false
    local handle = io.popen("age --decrypt --identity " .. identity_filepath .. " " .. secret_path)
    if handle ~= nil then
        local result = handle:read("*a")
        handle:close()
        local results = {}
        for w in string.gmatch(result, "([^\n]+)") do
            table.insert(results, w)
        end
        if print_secret then
            print(vim.inspect(results))
        end
        return results
    end
end

return M
