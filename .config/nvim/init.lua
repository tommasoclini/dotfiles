vim.loader.enable(true)

local is_windows = vim.loop.os_uname().sysname == "Windows_NT"

-- OPTIONS

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

vim.diagnostic.config({ virtual_text = true })

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.format_on_save = true

local scroll = 3

vim.opt.scroll = scroll
--[[
vim.api.nvim_create_autocmd({ "VimResized", "BufWinEnter" }, {
    callback = function()
        vim.opt_local.scroll = scroll
    end,
})
--]]

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
    "https://github.com/romus204/tree-sitter-manager.nvim.git",
    "https://github.com/ellisonleao/gruvbox.nvim.git",
    "https://github.com/shortcuts/no-neck-pain.nvim.git",
    "https://github.com/j-hui/fidget.nvim.git",
})

require("fidget").setup({})

require("no-neck-pain").setup()

require("tree-sitter-manager").setup({
    ensure_installed = {
        "rust",
        "lua",
        "c",
        "cpp",
        "cmake",
    },
    nohighlight = { "rust", "c", "cpp", "toml" },
})

require("lsp_signature").setup({
    bind = true,
    handler_opts = {
        borders = "rounded",
    },
})

require("grug-far").setup()

require("crates").setup({})

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

--[[
local starter = require("mini.starter")
starter.setup({
    items = {
        {
            { action = Snacks.picker.command_history, name = "Command history", section = "Pick" },
            { action = Snacks.explorer.open, name = "Explorer", section = "Pick" },
            { action = Snacks.picker.files, name = "Files", section = "Pick" },
            { action = Snacks.picker.grep, name = "Grep live", section = "Pick" },
            { action = Snacks.picker.help, name = "Help tags", section = "Pick" },
        },
        starter.sections.recent_files(5, true),
        starter.sections.recent_files(5, false),
    },
    footer = "",
})
--]]

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
        ["<C-s>"] = { "show" },
        ["<Tab>"] = { "accept", "fallback" },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-Space>'] = { 'show', 'fallback' },
    },
    cmdline = {
        enabled = true,
        keymap = {
            preset = 'cmdline',
            ['<Tab>'] = { 'show_and_insert', 'accept' },
            ['<Up>'] = { 'select_prev', 'fallback' },
            ['<Down>'] = { 'select_next', 'fallback' },
        },
    }
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

if not is_windows then
    vim.pack.add({ "https://github.com/Aietes/esp32.nvim.git" })
    local get_clangd = function()
        local clangd = require("esp32").lsp_config()
        table.insert(clangd.cmd, "--header-insertion=never")
        table.insert(
            clangd.cmd,
            "--query-driver=/usr/bin/clang*,/usr/bin/gcc,/usr/bin/g++,/usr/bin/cc,/home/tommaso/git_repos/bldc/tools/gcc-arm-none-eabi-7-2018-q2-update/bin/arm-none-eabi-gcc,/home/tommaso/git_repos/my-bldc/tools/gcc-arm-none-eabi-7-2018-q2-update/bin/arm-none-eabi-gcc"
        )
        return clangd
    end

    vim.lsp.config("clangd", get_clangd())
end

-- COLORSCHEME

vim.cmd("colorscheme gruvbox")

--  end

-- KEYMAPS

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
if vim.fn.executable("lazygit") then
    vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
end

-- Oil
vim.keymap.set("n", "<leader>o", "<cmd>Oil<cr>", { desc = "Oil file explorer" })

-- MiniBufRemove
vim.keymap.set("n", "<leader>bd", MiniBufremove.delete, { desc = "My delete buffer" })
vim.keymap.set("n", "<leader>bw", MiniBufremove.wipeout, { desc = "My wipeout buffer" })

-- pickers
vim.keymap.set("n", "<leader><leader>", Snacks.picker.files, { desc = "search files" })
vim.keymap.set("n", "<leader>sg", Snacks.picker.grep, { desc = "grep files" })

-- explorer
vim.keymap.set("n", "<leader>e", Snacks.explorer.open, { desc = "file explorer" })

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
    pattern = "rust",
    group = vim.api.nvim_create_augroup("Rust_disable_single_quote", { clear = true }),
    callback = function()
        MiniPairs.unmap("i", "'", "''")
    end,
    desc = "Disable single quote Rust",
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "rust",
    callback = function()
        vim.opt_local.scroll = 3
    end,
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

require("vim._core.ui2").enable({
    enable = true, -- Whether to enable or disable the UI.
    msg = {        -- Options related to the message module.
        ---@type 'cmd'|'msg' Default message target, either in the
        ---cmdline or in a separate ephemeral message window.
        ---@type string|table<string, 'cmd'|'msg'|'pager'> Default message target
        ---or table mapping |ui-messages| kinds and triggers to a target.
        targets = "cmd",
        cmd = {             -- Options related to messages in the cmdline window.
            height = 0.5,   -- Maximum height while expanded for messages beyond 'cmdheight'.
        },
        dialog = {          -- Options related to dialog window.
            height = 0.5,   -- Maximum height.
        },
        msg = {             -- Options related to msg window.
            height = 0.5,   -- Maximum height.
            timeout = 4000, -- Time a message is visible in the message window.
        },
        pager = {           -- Options related to message window.
            height = 1,     -- Maximum height.
        },
    },
})
