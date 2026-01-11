local is_windows = vim.loop.os_uname().sysname == "Windows_NT"

-- OPTIONS

vim.o.encoding = "utf-8"
vim.o.fileencoding = "utf-8"

if is_windows then
    vim.o.shell = "pwsh"
    vim.o.shellcmdflag = "-NoLogo -NoExit -Command"
    vim.o.shellquote = '"'
    vim.o.shellxquote = ""
end

vim.o.tabstop = 4 -- how wide a tab looks
vim.o.shiftwidth = 4 -- indent size
vim.o.softtabstop = 4 -- <Tab>/<BS> behavior
vim.o.expandtab = true -- use spaces instead of tabs

vim.o.signcolumn = "yes"

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

vim.diagnostic.config({ virtual_text = true })

vim.g.mapleader = " "

vim.api.nvim_create_autocmd("UIEnter", {
    callback = function()
        vim.o.clipboard = "unnamedplus"
    end,
})

-- PLUGINS

vim.cmd("packadd! nohlsearch")

vim.pack.add({
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/folke/which-key.nvim.git" },
    { src = "https://github.com/kdheepak/lazygit.nvim.git" },
    { src = "https://github.com/lewis6991/gitsigns.nvim.git" },
    {
        src = "https://github.com/saghen/blink.cmp.git",
        version = "v1.8.0",
    },
    { src = "https://github.com/folke/snacks.nvim.git" },
    { src = "https://github.com/nvim-mini/mini.nvim.git" },
    { src = "https://github.com/stevearc/oil.nvim.git" },
})

require("oil").setup()

require("mini.tabline").setup()

require("mini.extra").setup()

require("mini.pairs").setup()

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

require("mini.pick").setup()

require("gitsigns").setup()

require("blink.cmp").setup({
    fuzzy = {
        implementation = "prefer_rust",
    },
    keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
        ["<C-s>"] = { "show" },
    },
})

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "clangd",
        "tombi",
    },
})

if not is_windows then
    vim.pack.add({ "https://github.com/Aietes/esp32.nvim.git" })
    local get_clangd = function()
        local clangd = require("esp32").lsp_config()
        table.insert(clangd.cmd, "--header-insertion=never")
        return clangd
    end

    vim.lsp.config("clangd", get_clangd())
end

-- COLORSCHEME

--[[
if not is_windows then
    vim.pack.add({ "https://github.com/navarasu/onedark.nvim.git" })
    local onedark = require("onedark")
    onedark.setup({
        style = "warmer",
    })
    onedark.load()

    vim.cmd("colorscheme onedark")
else
--]]
vim.pack.add({ "https://github.com/olimorris/onedarkpro.nvim.git" })
require("onedarkpro").setup()

vim.cmd("colorscheme onedark")
--  end

-- KEYMAPS

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

vim.keymap.set({ "t", "i" }, "<A-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set({ "t", "i" }, "<A-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set({ "t", "i" }, "<A-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set({ "t", "i" }, "<A-l>", "<C-\\><C-n><C-w>l")
vim.keymap.set({ "n" }, "<A-h>", "<C-w>h")
vim.keymap.set({ "n" }, "<A-j>", "<C-w>j")
vim.keymap.set({ "n" }, "<A-k>", "<C-w>k")
vim.keymap.set({ "n" }, "<A-l>", "<C-w>l")

-- Lazygit
vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

-- Oil
vim.keymap.set("n", "<leader>o", "<cmd>Oil<cr>", { desc = "Oil file explorer" })

-- MiniBufRemove
vim.keymap.set("n", "<leader>bd", MiniBufremove.delete, { desc = "My delete buffer" })
vim.keymap.set("n", "<leader>bw", MiniBufremove.wipeout, { desc = "My wipeout buffer" })

-- pickers
vim.keymap.set("n", "<leader>ff", MiniPick.builtin.files, { desc = "pick files" })
vim.keymap.set("n", "<leader>fg", MiniPick.builtin.grep_live, { desc = "pick files" })

-- AUTOCOMMANDS

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        -- local client = vim.lsp.get_client_by_id(ev.data.client_id)

        local buf = ev.buf

        vim.keymap.set("n", "<leader>i", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = buf })
        end, { buffer = buf, desc = "Toggle lsp inlay hints" })

        vim.keymap.set("n", "<leader>s", function()
            MiniExtra.pickers.lsp({ scope = "document_symbol" })
        end, { buffer = buf, desc = "Pick document symbols" })

        vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true, bufnr = buf })
        end, { buffer = buf, desc = "Format buffer with lsp" })

        vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { buffer = buf, desc = "Rename symbol with lsp" })
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    callback = function()
        vim.hl.on_yank()
    end,
})
