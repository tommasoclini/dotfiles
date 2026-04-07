return {
    settings = {
        Lua = {
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
                ignoreDir = {
                    ".git",
                    "node_modules",
                    ".vscode",
                    ".idea",
                    "build",
                    "target",
                    "dist",
                    ".cache",
                },
            },
            diagnostics = {
                globals = { "vim" },
            },
        },
    },
}
