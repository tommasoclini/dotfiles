return {
    settings = {
        Lua = {
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            diagnostics = {
                globals = { "vim" },
            },
        },
    },
    single_file_support = true,
    root_dir = function()
        return nil
    end,
}
