local M = {}

--- Get the text and range of the current visual selection.
---
--- @return string|nil content The concatenated selected text or nil if selection is empty.
--- @return table|nil s_start The start position of the selection as returned by getpos().
--- @return table|nil s_end The end position of the selection as returned by getpos().
--- @return string|nil mode The visual mode character ('v', 'V', or character 22 for blockwise).
local function get_visual_selection()
    local s_start = vim.fn.getpos("'<")
    local s_end = vim.fn.getpos("'>")
    local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)

    if #lines == 0 then return nil end

    local mode = vim.fn.visualmode()

    if mode == 'v' then
        local start_col = s_start[3]
        local end_col = s_end[3]

        if #lines == 1 then
            lines[1] = string.sub(lines[1], start_col, end_col)
        else
            lines[1] = string.sub(lines[1], start_col)
            lines[#lines] = string.sub(lines[#lines], 1, end_col)
        end
    end

    return table.concat(lines, "\n"), s_start, s_end, mode
end

--- Create a centered floating window for user text input.
--- @param prompt string The title text displayed on the window border.
--- @param callback fun(text: string) The function to execute with the input string upon confirmation.
local function input_window(prompt, callback)
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 60
    local height = 1
    local ui = vim.api.nvim_list_uis()[1]
    local row = (ui.height - height) / 2
    local col = (ui.width - width) / 2

    local opts = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = prompt,
        title_pos = "center"
    }

    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Setup buffer for input
    vim.cmd("startinsert")

    local function on_confirm()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local text = table.concat(lines, "")
        if text and text ~= "" then
            vim.api.nvim_win_close(win, true)
            callback(text)
        else
            vim.notify("No input provided", vim.log.levels.WARN)
            vim.api.nvim_win_close(win, true)
        end
    end

    local function on_cancel()
        vim.api.nvim_win_close(win, true)
    end

    vim.keymap.set("i", "<CR>", on_confirm, { buffer = buf, noremap = true, silent = true })
    vim.keymap.set("n", "<CR>", on_confirm, { buffer = buf, noremap = true, silent = true })
    vim.keymap.set("n", "<Esc>", on_cancel, { buffer = buf, noremap = true, silent = true })
    vim.keymap.set("n", "q", on_cancel, { buffer = buf, noremap = true, silent = true })
end


--- Encrypt the current visual selection using age.
---
--- Prompts for confirmation and recipients, then replaces the selected text
--- with encrypted output using the `age` command-line tool.
---
--- @return nil
function M.encrypt()
    -- 1. Get Visual Selection
    -- We need to exit visual mode to update the '< and '> marks
    local mode = vim.api.nvim_get_mode().mode
    if mode == 'v' or mode == 'V' or mode == "\22" then
        vim.cmd('normal! \27') -- Exit visual mode
    end

    local text, s_start, s_end, vmode = get_visual_selection()
    if not text then
        vim.notify("No text selected", vim.log.levels.ERROR)
        return
    end

    -- 2. Confirmation Dialog
    local confirmed = vim.fn.confirm("Are you sure you want to encrypt this selection?", "&Yes\n&No", 1)
    if confirmed ~= 1 then
        return
    end

    -- 3. Prompt for Recipients
    input_window("Enter recipients (comma separated)", function(input)
        local recipients = {}
        for r in string.gmatch(input, "([^,]+)") do
            local trimmed = vim.trim(r)
            if trimmed ~= "" then
                table.insert(recipients, "-r")
                table.insert(recipients, trimmed)
            end
        end

        if #recipients == 0 then
            vim.notify("No recipients provided", vim.log.levels.ERROR)
            return
        end

        -- 4. Encrypt using age
        -- Construct command: age -a -r <recip> ...
        local cmd = { "age", "-a" }
        for _, r in ipairs(recipients) do
            table.insert(cmd, r)
        end

        local job_opts = {
            stdin = text,
            on_exit = function(obj)
                if obj.code ~= 0 then
                    vim.schedule(function()
                        vim.notify("Encryption failed: " .. (obj.stderr or "unknown error"), vim.log.levels.ERROR)
                    end)
                    return
                end

                local encrypted_text = obj.stdout
                -- Remove trailing newline from command output if present/undesired,
                -- but age -a output usually has a trailing newline which is good for blocks.

                -- 5. Replace Selection
                vim.schedule(function()
                    if not s_start or not s_end then return end
                    local lines = vim.split(encrypted_text, "\n")
                    if lines[#lines] == "" then table.remove(lines) end -- Trim last empty line if split created it


                    local start_row = s_start[2] - 1
                    local start_col = s_start[3] - 1
                    local end_row = s_end[2] - 1

                    local end_col = s_end[3]

                    if vmode == 'V' then
                        vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, lines)
                    else
                        vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, lines)
                    end
                end)
            end
        }

        if vim.system then
            vim.system(cmd, { stdin = text }, function(obj)
                job_opts.on_exit(obj)
            end)
        else
            vim.notify("vim.system not available, please update Neovim", vim.log.levels.ERROR)
        end
    end)
end

return M
