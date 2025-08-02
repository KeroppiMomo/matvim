local M = {}

M.options = {
    use_custom_interpreter = true,
    matlab_binary = "/Applications/MATLAB_R2025a.app/Contents/MacOS/MATLAB",
    window_create = "vsplit",
    run_preview_length = 50,
    run_temp_folder = "~/tmp/",
    run_temp_filename = function (_)
        local timestamp = os.date("%Y%m%d_%H%M%S")
        return string.format("matvim_%s.m", timestamp)
    end,
    keymaps = {
        matlab_start = "<leader>s",
        run_file = "<leader>R",
        run_visual = "<leader>r",
        run_normal = "<leader>r",
        run_line = "<leader>rr",
        next_section = "]]",
        prev_section = "[[",
        a_section = {"aS", "S"},
        i_section = "iS",
    },
}

M.job = nil

M.temp_files = {}

function M.delete_temp_files()
    for _, filename in ipairs(M.temp_files) do
        local res = os.remove(filename)
        if res == nil then
            print(string.format("Unable to delete %s", filename))
        end
    end
    M.temp_files = {}
end

function M.start_matlab()
    if M.job then
        error("Matlab instance is already running")
    end
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_win_set_buf(0, buf)

    local cmd
    if M.options.use_custom_interpreter then
        local lua_file = debug.getinfo(1, "S").source:sub(2)
        local plugin_path = vim.fn.fnamemodify(lua_file, ":h:h:h") -- go up 3 levels: init.lua → matvim → lua
        local interpreter_path = vim.fs.joinpath(plugin_path, "customInterpreter.py")
        cmd = string.format('python3 "%s" "%s"', interpreter_path, vim.uv.cwd())
    else
        cmd = { M.options.matlab_binary, "-nodesktop", "-sd", vim.uv.cwd() }
    end

    M.job = vim.fn.termopen(cmd, {
        on_exit = function()
            M.job = nil
            M.delete_temp_files()
        end
    })
end

function M.execute(cmd)
    vim.api.nvim_chan_send(M.job, cmd .. "\r\n")
end

--- Extract all function definitions from a Matlab file.
--- @param source string|integer source code or buffer number.
--- @return string
function M.extract_functions(source)
    local functionCode = ""

    local query = vim.treesitter.query.parse('matlab', [[
        ((function_definition) @func
            (#not-has-ancestor? @func function_definition))
    ]]) -- All top-level functions

    local tree = vim.treesitter.get_parser():parse()[1]
    for _, node in query:iter_captures(tree:root(), source) do
        local text = vim.treesitter.get_node_text(node, vim.api.nvim_get_current_buf())
        functionCode = functionCode .. text .. "\n\n"
    end

    return functionCode
end

function M.execute_within_file(code, source)
    local function get_first_non_empty_line(input)
        for line in input:gmatch("[^\r\n]+") do
            if line:match("%S") then  -- contains at least one non-whitespace character
                return line:match("^%s*(.-)%s*$")  -- trim leading/trailing whitespace
            end
        end
        return ""
    end

    local functionCode = M.extract_functions(source)
    local fileContent = code
    if functionCode ~= "" then
        fileContent = string.format([[
%s

%%%% MATVIM DETECTED FUNCTIONS
[]; %% Force Matlab to treat as script file

%s]], fileContent, functionCode)
    end

    local filename = M.options.run_temp_filename(fileContent)
    local file_path = vim.fs.normalize(vim.fs.joinpath(M.options.run_temp_folder, filename))
    local tmpfile = assert(io.open(file_path, "w"))
    tmpfile:write(fileContent)
    tmpfile:close()
    table.insert(M.temp_files, file_path)

    local cmd
    if M.options.run_preview_length > 0 then
        local firstLine = get_first_non_empty_line(code)
        firstLine = firstLine:sub(1, M.options.run_preview_length)

        cmd = string.format('run("%s") %% %s', file_path, firstLine)
    else
        cmd = string.format('run("%s")', file_path)
    end
    M.execute(cmd)
end

function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", M.options, opts or {})

    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = M.delete_temp_files,
    })
end

return M
