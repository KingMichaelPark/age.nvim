local M = {}

-- Opens the provided file and returns the contents as a string
--- Decrypts and reads the contents of an age-encrypted file
--- @param secret_path string Path to the encrypted file
--- @param identity_filepath string Path to the age identity/key file
--- @param print_secret boolean Optional flag to print the decrypted content
--- @return string|nil The decrypted content with trailing newline removed, or nil if operation fails
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
--- Decrypts and reads the contents of an age-encrypted file, returning each line as a table entry
--- @param secret_path string Path to the encrypted file
--- @param identity_filepath string Path to the age identity/key file
--- @param print_secret boolean Optional flag to print the decrypted content
--- @return table|nil Table containing each line of the decrypted content as separate entries, or nil if operation fails
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

--- Decrypts an age-encrypted JSON file and returns its parsed contents
--- @param secret_path string Path to the encrypted JSON file
--- @param identity_filepath string Path to the age identity/key file
--- @param print_secret boolean Optional flag to print the decoded content
--- @return table|nil Table containing the decoded JSON data, or nil if operation fails
function M.from_json(secret_path, identity_filepath, print_secret)
    print_secret = print_secret or false
    local handle = io.popen("age --decrypt --identity " .. identity_filepath .. " " .. secret_path)
    if handle ~= nil then
        local result = handle:read("*a")
        handle:close()
        local results = vim.json.decode(result)
        if print_secret then
            print(vim.inspect(results))
        end
        return results
    end
end

--- Decrypts a SOPS-encrypted JSON file and returns its parsed contents
--- @param secret_path string Path to the SOPS-encrypted file
--- @param print_secret boolean Optional flag to print the decoded content
--- @return table|nil Table containing the decoded JSON data, or nil if operation fails
function M.from_sops(secret_path, print_secret)
    print_secret = print_secret or false
    local handle = io.popen("sops --decrypt " .. secret_path)
    if handle ~= nil then
        local result = handle:read("*a")
        handle:close()
        local results = vim.json.decode(result)
        if print_secret then
            print(vim.inspect(results))
        end
        return results
    end
end

return M
