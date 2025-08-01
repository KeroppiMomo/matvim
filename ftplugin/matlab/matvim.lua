local function displayError(msg)
    vim.cmd("echohl ErrorMsg | echo '" .. msg .. "' | echohl None")
end

vim.api.nvim_create_user_command("MatlabStart", function()
    local matvim = require("matvim")
    if matvim.job then
        displayError("Matlab instance is already running")
        return
    end

    if type(matvim.options.window_create) == "string" then
        vim.cmd(matvim.options.window_create)
    else
        matvim.options.window_create()
    end

    matvim.start_matlab()
end, {})

vim.api.nvim_create_user_command("MatlabRunFile", function()
    local matvim = require("matvim")
    if matvim.job == nil then
        displayError("No running Matlab instance. Start one with :MatlabStart")
        return
    end

    local currentFile = vim.fn.expand("%:p")
    matvim.execute(string.format([[run("%s")]], currentFile))
end, {})

vim.api.nvim_create_user_command("MatlabExecute", function(opts)
    local code = opts.fargs[1]
    local matvim = require("matvim")

    if matvim.job == nil then
        displayError("No running Matlab instance. Start one with :MatlabStart")
        return
    end

    matvim.execute(code)
end, {
    nargs = 1,
})
