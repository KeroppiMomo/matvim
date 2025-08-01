local M = {}

function M.goto_next_section()
    vim.fn.search("^%%", "W") -- W means do not wrap around file
end

function M.goto_prev_section()
    vim.fn.search("^%%", "bW") -- b means backwards, W means do not wrap around file
end

--- In visual mode, select the section under the cursor.
--- @param around boolean Whether to include the section header.
function M.visual_section(around)
    -- Find previous section header
    local match_line = vim.fn.search([[^%%]], "bcW") -- backward, accept match at cursor, no wrap
    if match_line == 0 then -- No match
        vim.cmd[[keepjumps normal! gg^]] -- go to top of buffer
    elseif not around then
        vim.api.nvim_feedkeys("j", "nx", false) -- go down one line
    end

    -- Reset the other end of highlighted text
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_feedkeys("o", "nx", false)
    vim.api.nvim_win_set_cursor(0, pos)

    -- Find next section header
    match_line = vim.fn.search([[^%%]], "W") -- forward, do not accept match at cursor, no wrap
    if match_line == 0 then -- no match
        vim.cmd[[keepjumps normal! G$]] -- go to end of file
    else
        vim.api.nvim_feedkeys("k$", "nx", false) -- go to end of previous line
    end
end

return M
