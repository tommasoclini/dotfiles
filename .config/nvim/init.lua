vim.loader.enable()

local is_windows = vim.loop.os_uname().sysname == "Windows_NT"

-- OPTIONS

vim.o.undofile = true
vim.o.swapfile = false

vim.o.encoding = "utf-8"
vim.o.fileencoding = "utf-8"

if is_windows then
    vim.o.shell = "pwsh"
    vim.o.shellcmdflag = "-NoLogo -NoExit -Command"
    vim.o.shellquote = '"'
    vim.o.shellxquote = ""
end

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true

vim.o.signcolumn = "yes"
vim.cmd("set colorcolumn=80")

vim.o.exrc = true

vim.o.wrap = false

vim.o.number = true
vim.o.relativenumber = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.cursorline = true

vim.o.scrolloff = 4
vim.o.sidescrolloff = 4

vim.o.list = true

vim.o.confirm = true
vim.o.termguicolors = true

vim.o.scroll = 3

-- vim.o.statusline = vim.o.statusline .. " %{strftime('%H:%M')}"

vim.diagnostic.config({
    virtual_text = {
        format = function(diagnostic)
            local code = diagnostic.code

            if code == "inactive-code" then
                return nil
            end

            if type(code) == "table" and code.value == "inactive-code" then
                return nil
            end

            local message = diagnostic.message and diagnostic.message:lower()
            if message and (message:find("code is inactive", 1, true) or message:find("inactive code", 1, true)) then
                return nil
            end

            return diagnostic.message
        end,
    },
})

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.format_on_save = true

vim.opt.scroll = 3

vim.lsp.log.set_level(vim.log.levels.ERROR)

-- PLUGINS

vim.cmd("packadd! nohlsearch")
vim.cmd("packadd! nvim.undotree")
vim.cmd("packadd! nvim.difftool")

vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mason-org/mason-lspconfig.nvim",
    "https://github.com/folke/which-key.nvim.git",
    "https://github.com/kdheepak/lazygit.nvim.git",
    "https://github.com/lewis6991/gitsigns.nvim.git",
    {
        src = "https://github.com/saghen/blink.cmp.git",
        version = vim.version.range("^1"),
    },
    "https://github.com/folke/snacks.nvim.git",
    "https://github.com/nvim-mini/mini.nvim.git",
    "https://github.com/stevearc/oil.nvim.git",
    "https://github.com/nvim-lua/plenary.nvim.git",
    "https://github.com/nvim-tree/nvim-web-devicons.git",
    { src = "https://github.com/mrcjkb/rustaceanvim.git", version = vim.version.range("^9") },
    "https://github.com/saecki/crates.nvim.git",
    "https://github.com/olimorris/onedarkpro.nvim.git",
    "https://github.com/MagicDuck/grug-far.nvim.git",
    "https://github.com/ray-x/lsp_signature.nvim.git",
    "https://github.com/ellisonleao/gruvbox.nvim.git",
    "https://github.com/shortcuts/no-neck-pain.nvim.git",
    "https://github.com/j-hui/fidget.nvim.git",
    "https://github.com/pteroctopus/faster.nvim.git",
    "https://github.com/lukas-reineke/indent-blankline.nvim.git",
    "https://github.com/nvim-treesitter/nvim-treesitter.git",
    "https://github.com/folke/todo-comments.nvim.git",
    "https://github.com/nvim-flutter/flutter-tools.nvim.git",
})

-- local hooks = require("ibl.hooks")
-- hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
--     vim.api.nvim_set_hl(0, "IblScope", { fg = "#DDDDDD" })
-- end)

require("flutter-tools").setup({})

require("crates").setup({})

require("todo-comments").setup()

require("ibl").setup({ scope = { highlight = "IblScope" } })

require("faster").setup()

require("fidget").setup({})

require("no-neck-pain").setup()

require("nvim-treesitter").setup {}
require("nvim-treesitter").install { "rust", "lua", "c", "cpp" }

require("lsp_signature").setup({
    bind = true,
    handler_opts = {
        borders = "rounded",
    },
})

require("grug-far").setup()

require("snacks").setup({
    notifier = {
        enabled = true,
        filter = function(notif)
            if notif.msg and notif.msg:find("No esp%-clangd found") then
                return false
            end
            return true
        end,
    },
    toggle = { enabled = true },
    picker = { enabled = true, sources = { explorer = { layout = { layout = { position = "right" } } } } },
    explorer = { enabled = true },
    zen = {
        toggles = {
            dim = false,
        },
    },
})

require("oil").setup()

require("mini.tabline").setup({
    format = function(buf_id, label)
        local suffix = vim.bo[buf_id].modified and "+ " or ""
        return MiniTabline.default_format(buf_id, label) .. suffix
    end,
    tabpage_section = "right",
})

require("mini.extra").setup()

require("mini.pairs").setup({
    mappings = {
        ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\][^%w_]" },
        ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\][^%w_]" },
        ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\][^%w_]" },
        ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\][^%w_]" },
        ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\][^%w_]" },
        ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\][^%w_]" },
    },
})

require("mini.bufremove").setup()
vim.api.nvim_create_autocmd("BufHidden", {
    callback = function(ev)
        local buf = ev.buf
        if vim.bo[buf].buftype ~= "" then
            return
        end
        if vim.api.nvim_buf_get_name(buf) ~= "" then
            return
        end
        -- Don't delete if user typed something
        if vim.bo[buf].modified then
            return
        end
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(buf) then
                MiniBufremove.delete(buf, true)
            end
        end)
    end,
})

require("gitsigns").setup()

require("blink.cmp").setup({
    fuzzy = {
        implementation = "prefer_rust",
    },
    keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "accept", "fallback" },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    },
    cmdline = {
        enabled = true,
        keymap = {
            preset = 'cmdline',
            ['<Tab>'] = { 'show_and_insert', 'accept' },
            ['<Up>'] = { 'select_prev', 'fallback' },
            ['<Down>'] = { 'select_next', 'fallback' },
        },
    },
    --[[signature = {
        enabled = true,
        keymap = {
            ['<C-u>'] = { 'scroll_signature_up', 'fallback' },
            ['<C-d>'] = { 'scroll_signature_down', 'fallback' },

            -- default in all keymap presets
            ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
        }
    },--]]
})

require("mason").setup()
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
    ensure_installed = {
        "lua_ls",
        "clangd",
        "tombi",
        "buf_ls",
        "tinymist",
    },
})

local function setup_default_clangd()
    vim.lsp.config("clangd", {
        cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
        },
    })
end

local function setup_esp32_clangd()
    if is_windows then
        vim.notify("esp32 clangd profile is not available on windows", vim.log.levels.WARN)
        return
    end

    vim.pack.add({ "https://github.com/Aietes/esp32.nvim.git" })

    local clangd = require("esp32").lsp_config()
    vim.lsp.config("clangd", clangd)
end

local function set_clangd_profile(profile)
    if profile == "esp32" then
        setup_esp32_clangd()
    else
        setup_default_clangd()
    end

    vim.g.clangd_profile = profile
    vim.notify("clangd profile set to " .. profile)

    for _, client in ipairs(vim.lsp.get_clients({ name = "clangd" })) do
        client:stop()
    end

    vim.cmd("edit")
end

setup_default_clangd()
vim.g.clangd_profile = "normale"

vim.api.nvim_create_user_command("ClangdProfile", function(opts)
    local profile = opts.args

    if profile == "normale" then
        profile = "default"
    end

    if profile ~= "default" and profile ~= "esp32" then
        vim.notify("invalid clangd profile: " .. profile .. " (use default|normale|esp32)", vim.log.levels.ERROR)
        return
    end

    set_clangd_profile(profile == "default" and "normale" or profile)
end, {
    nargs = 1,
    complete = function()
        return { "default", "normale", "esp32" }
    end,
    desc = "switch clangd profile",
})

-- COLORSCHEME

vim.cmd("colorscheme gruvbox")

--  end

-- KEYMAPS

vim.keymap.set("i", "<M-Left>", "<C-Left>")
vim.keymap.set("i", "<M-Right>", "<C-Right>")

vim.keymap.set("n", "]c", "<cmd>Gitsigns next_hunk<cr>", { desc = "next git change" })
vim.keymap.set("n", "[c", "<cmd>Gitsigns prev_hunk<cr>", { desc = "prev git change" })

vim.keymap.set("n", "<leader>ub", function()
    if vim.o.background == "light" then
        vim.o.background = "dark"
    else
        vim.o.background = "light"
    end
end, { desc = "toggle background" })

vim.keymap.set({ "n", "v" }, "s", [[/\%.l]], { desc = "search current line" })

vim.keymap.set("n", "<leader>N", NoNeckPain.toggle)

vim.keymap.set("n", "<leader>ut", require("undotree").open)

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

vim.keymap.set({ "t", "i" }, "<A-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set({ "t", "i" }, "<A-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set({ "t", "i" }, "<A-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set({ "t", "i" }, "<A-l>", "<C-\\><C-n><C-w>l")
vim.keymap.set({ "n" }, "<A-h>", "<C-w>h")
vim.keymap.set({ "n" }, "<A-j>", "<C-w>j")
vim.keymap.set({ "n" }, "<A-k>", "<C-w>k")
vim.keymap.set({ "n" }, "<A-l>", "<C-w>l")

vim.keymap.set({ "n" }, "<A-]>", "<cmd>tabnext<cr>")
vim.keymap.set({ "n" }, "<A-[>", "<cmd>tabprev<cr>")

-- Lazygit
-- if vim.fn.executable("lazygit") then
vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
-- end

-- Oil
vim.keymap.set("n", "<leader>O", function() require("oil").open(vim.uv.cwd()) end, { desc = "Oil file explorer cwd" })
vim.keymap.set("n", "<leader>o", require("oil").open, { desc = "Oil file explorer" })

-- MiniBufRemove
vim.keymap.set("n", "<leader>bd", MiniBufremove.delete, { desc = "My delete buffer" })
vim.keymap.set("n", "<leader>bw", MiniBufremove.wipeout, { desc = "My wipeout buffer" })

-- pickers
vim.keymap.set("n", "<leader><leader>", Snacks.picker.files, { desc = "search files" })
vim.keymap.set("n", "<leader>sg", Snacks.picker.grep, { desc = "grep files" })

-- explorer
vim.keymap.set("n", "<leader>e", Snacks.explorer.open, { desc = "file explorer" })
vim.keymap.set("n", "<leader>E",
    function() Snacks.explorer.open({ cwd = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':h') }) end,
    { desc = "file explorer in buffer directory" })

-- buffer navigation
vim.keymap.set("n", "<S-l>", function()
    vim.cmd("bnext")
end, { silent = true })
vim.keymap.set("n", "<S-h>", function()
    vim.cmd("bprev")
end, { silent = true })

Snacks.toggle.zen():map("<leader>z")

vim.keymap.set("n", "<leader>gr", "<cmd>GrugFar<CR>", { desc = "GrugFar" })

-- AUTOCOMMANDS

vim.api.nvim_create_autocmd("UIEnter", {
    callback = function()
        vim.o.clipboard = "unnamedplus"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "rust", "c", "cpp", "lua" },
    callback = function()
        vim.treesitter.start()
    end,
    desc = "treesitter start",
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "rust",
    callback = function()
        MiniPairs.unmap("i", "'", "''")
        vim.opt_local.scroll = 3
    end,
    desc = "rust specific tweaks",
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local bufnr = ev.buf
        local map = vim.keymap.set

        map("n", "]e", function()
            vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
        end, { buffer = bufnr, desc = "go to next error" })
        map("n", "[e", function()
            vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
        end, { buffer = bufnr, desc = "go to previous error" })
        map("n", "]w", function()
            vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
        end, { buffer = bufnr, desc = "go to next warning" })
        map("n", "[w", function()
            vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
        end, { buffer = bufnr, desc = "go to previous warning" })
        map("n", "]i", function()
            vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
        end, { buffer = bufnr, desc = "go to next info" })
        map("n", "[i", function()
            vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
        end, { buffer = bufnr, desc = "go to previous info" })
        map("n", "]h", function()
            vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
        end, { buffer = bufnr, desc = "go to next hint" })
        map("n", "[h", function()
            vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
        end, { buffer = bufnr, desc = "go to previous hint" })

        map("n", "<leader>ui", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
        end, { buffer = bufnr, desc = "Toggle lsp inlay hints" })
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle({
            name = "Format on Save",
            get = function()
                return vim.g.format_on_save ~= false
            end,
            set = function(state)
                vim.g.format_on_save = state
            end,
        }):map("<leader>uf")

        map("n", "<leader>gi", Snacks.picker.lsp_implementations, { buffer = bufnr, desc = "go to implementation" })

        map("n", "<leader>gy", Snacks.picker.lsp_definitions, { buffer = bufnr, desc = "go to type definition" })

        map("n", "<leader>ss", Snacks.picker.lsp_symbols, { buffer = bufnr, desc = "pick document symbols" })

        map("n", "<leader>sS", Snacks.picker.lsp_workspace_symbols, { buffer = bufnr, desc = "pick workspace symbols" })

        map("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true, bufnr = bufnr })
        end, { buffer = bufnr, desc = "Format buffer with lsp" })

        -- map("n", "<leader>r", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename symbol with lsp" })

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
            map("i", "<C-F>", vim.lsp.inline_completion.get, { desc = "LSP: accept inline completion", buffer = bufnr })
            map(
                "i",
                "<C-G>",
                vim.lsp.inline_completion.select,
                { desc = "LSP: switch inline completion", buffer = bufnr }
            )
            map({ "i", "n" }, "<C-H>", function()
                vim.lsp.inline_completion.enable(not vim.lsp.inline_completion.is_enabled({ bufnr = bufnr }), {
                    bufnr = bufnr,
                })
            end, { desc = "LSP: toggle inline completion", buffer = bufnr })
        end

        if client and client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function(event)
                    if vim.g.format_on_save == true and vim.bo[event.buf].filetype ~= "toml" then
                        vim.lsp.buf.format({
                            bufnr = bufnr,
                            async = false,
                        })
                    end
                end,
            })
        end
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    callback = function()
        vim.hl.on_yank()
    end,
})

require("vim._core.ui2").enable()

vim.o.ic = true
