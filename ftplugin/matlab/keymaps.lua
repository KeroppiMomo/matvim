local function displayError(msg)
    vim.cmd("echohl ErrorMsg | echo '" .. msg .. "' | echohl None")
end

local matvim = require("matvim")

-- From the docs
local function region_to_text(region)
    local text = ''
    local maxcol = vim.v.maxcol
    for line, cols in vim.spairs(region) do
        local endcol = cols[2] == maxcol and -1 or cols[2]
        local chunk = vim.api.nvim_buf_get_text(0, line, cols[1], line, endcol, {})[1]
        text = ('%s%s\n'):format(text, chunk)
    end
    return text
end

local function run_visual()
    if matvim.job == nil then
        displayError("No running Matlab instance. Start one with :MatlabStart")
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', false, true, true), 'nx', false)
    local r = vim.region(0, "'<", "'>", vim.fn.visualmode(), true)
    local code = region_to_text(r)

    matvim.execute_within_file(code, 0)
end

-- https://github.com/neovim/neovim/issues/14157#issuecomment-1320787927
local set_opfunc = vim.fn[vim.api.nvim_exec([[
  func s:set_opfunc(val)
    let &opfunc = a:val
  endfunc
  echon get(function('s:set_opfunc'), 'name')
]], true)]

local function run_normal()
    set_opfunc(function (motion_type)
        if matvim.job == nil then
            displayError("No running Matlab instance. Start one with :MatlabStart")
            return
        end

        local converted_type = ({
            char = "v",
            line = "V",
            block = vim.api.nvim_replace_termcodes("<C-V>", true, false, true), -- I think vim.region is bugged with <C-V>
        })[motion_type]

        local r = vim.region(0, "'[", "']", converted_type, true)
        local code = region_to_text(r)

        matvim.execute_within_file(code, 0)
    end)

    return "g@"
end

local function run_line()
    local code = vim.api.nvim_get_current_line()
    matvim.execute_within_file(code, 0)
end

local function keymap_set(mode, lhss, rhs, opts)
    if type(lhss) == "string" then
        lhss = {lhss}
    end
    for _, lhs in ipairs(lhss) do
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end

local keymaps = matvim.options.keymaps
keymap_set("n", keymaps.matlab_start, "<Cmd>MatlabStart<CR>", {buffer=true})
keymap_set("n", keymaps.run_file, "<Cmd>MatlabRunFile<CR>", {buffer=true})
keymap_set("v", keymaps.run_visual, run_visual, {buffer=true})
keymap_set("n", keymaps.run_normal, run_normal, {buffer=true, expr=true})
keymap_set("n", keymaps.run_line, run_line, {buffer=true})

keymap_set("", keymaps.next_section, require("matvim.motion").goto_next_section, {buffer=true})
keymap_set("", keymaps.prev_section, require("matvim.motion").goto_prev_section, {buffer=true})

keymap_set("x", keymaps.a_section, function()
    require("matvim.motion").visual_section(true)
end, {buffer=true})
keymap_set("o", keymaps.a_section, function()
    vim.api.nvim_feedkeys("v", "nx", false) -- enter visual mode
    require("matvim.motion").visual_section(true)
end, {buffer=true})

keymap_set("x", keymaps.i_section, function()
    require("matvim.motion").visual_section(false)
end, {buffer=true})
keymap_set("o", keymaps.i_section, function()
    vim.api.nvim_feedkeys("v", "nx", false) -- enter visual mode
    require("matvim.motion").visual_section(false)
end, {buffer=true})
