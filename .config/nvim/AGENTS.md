# AGENTS.md - Neovim Configuration

This is a personal Neovim (0.11+) configuration living inside a dotfiles
repository. The entire config is a single-file monolith (`init.lua`, ~365
lines) with one auxiliary LSP config file (`lsp/lua_ls.lua`).

## Project Structure

```
.config/nvim/
  init.lua              -- Entire configuration (options, plugins, keymaps, autocmds)
  lsp/
    lua_ls.lua          -- lua_ls LSP server settings (Neovim 0.11+ native lsp/ dir)
  stylua.toml           -- StyLua formatter config
  nvim-pack-lock.json   -- Plugin version lock file (do not edit manually)
```

There are no `lua/`, `plugin/`, `after/`, or `ftplugin/` directories. All
filetype-specific config is handled inline via `FileType` autocmds in `init.lua`.

## Build / Lint / Test Commands

There are no build steps, tests, or CI pipelines. This is a Neovim config,
not a software project.

### Formatting

```sh
# Format all Lua files with StyLua
stylua .

# Check formatting without writing
stylua --check .
```

StyLua config (`stylua.toml`) only sets `indent_type = "Spaces"`. All other
settings use StyLua defaults: 4-space indent width, 120-column line width,
double quotes, trailing commas.

### Linting

No linter is configured (no luacheck, selene, etc.). If adding one, ensure it
understands the Neovim `vim.*` global namespace.

### Validation

Load the config in Neovim to verify it works:

```sh
nvim --headless "+quit"
```

## Package Manager

Uses `vim.pack` (Neovim native package manager, 0.11+). Not lazy.nvim or
packer. Plugins are declared with `vim.pack.add()` using `{ src = "url" }`
tables. Some entries pin a `version` field.

The lock file `nvim-pack-lock.json` is auto-generated. Do not edit it manually.

## Code Style Guidelines

### Language

100% Lua. No Vimscript files. Vimscript only appears as arguments to
`vim.cmd()` when the Lua API is inconvenient.

### Formatting

- **Indentation**: 4 spaces (never tabs)
- **Line width**: 120 columns (StyLua default)
- **Quotes**: Double quotes exclusively (`"..."`, never `'...'`)
- **Trailing commas**: Always include in multi-line tables
- **Blank lines**: Single blank line between logical blocks; section headers
  get a blank line before and after

### Naming Conventions

- **Variables and functions**: `snake_case` (e.g., `is_windows`, `get_clangd`,
  `buf_id`, `seconds_until_next_minute`)
- **Callback parameters**: `ev` for event objects, `buf`/`bufnr` for buffer
  numbers, `client` for LSP clients, `label` for display strings
- **No camelCase** in user-written code
- **Global plugin APIs** accessed as uppercase globals per plugin convention
  (`MiniTabline`, `MiniBufremove`, `MiniPick`, `MiniExtra`, `MiniPairs`,
  `Snacks`)

### Imports / Requires

- Use `require("name").setup({...})` directly at point of use
- Do NOT assign require results to local variables (no `local telescope = require("telescope")`)
- Exception: inside callbacks, `local map = vim.keymap.set` alias is acceptable
  for brevity

### Module Pattern

- LSP config files in `lsp/` return a plain table: `return { settings = { ... } }`
- No `local M = {}; return M` pattern needed for this codebase

### Comments

- **Section headers**: `-- ALL CAPS` on their own line (e.g., `-- OPTIONS`,
  `-- PLUGINS`, `-- KEYMAPS`, `-- AUTOCOMMANDS`)
- **Inline comments**: Rare, brief, lowercase
- **Block comments**: `--[[ ... --]]` for commenting out code blocks
- No LuaDoc / EmmyLua type annotations

### Type Annotations

None. This codebase does not use LuaLS annotations or EmmyLua docstrings.

### Error Handling

None. All `require()` and `.setup()` calls are unprotected (no `pcall`). This
is intentional for a personal config -- if a plugin is missing, Neovim should
fail loudly at startup rather than silently degrading.

Do not add `pcall` wrappers unless specifically requested.

### Vim API Usage

- **Options**: Prefer `vim.o.*` for global options, `vim.opt_local.*` inside
  autocmds, `vim.bo[buf].*` for buffer-local reads, `vim.g.*` for global
  variables
- **Keymaps**: Always use `vim.keymap.set()` (never `vim.api.nvim_set_keymap`).
  Always include a `desc` field for which-key discoverability. Descriptions are
  lowercase (e.g., `"go to next error"`, `"pick files"`)
- **Autocmds**: Use `vim.api.nvim_create_autocmd()` with inline anonymous
  `callback` functions. Group related autocmds with `nvim_create_augroup()`
  when appropriate

### init.lua Section Order

The file follows a strict linear structure. Maintain this order:

1. OS detection
2. `-- OPTIONS` (editor settings)
3. `-- PLUGINS` (vim.pack.add + plugin setup)
4. `-- COLORSCHEME` (theme)
5. `-- KEYMAPS` (all keybindings, including LSP ones in LspAttach)
6. `-- AUTOCOMMANDS` (clipboard, filetype, yank highlight, format-on-save)
7. `-- TIMERS` (statusline refresh)

### Conditional Logic

Platform-specific code is guarded by `if not is_windows then ... end` (defined
at the top of init.lua). Keep platform checks using this existing variable.

## Key Design Decisions

- **Single-file architecture**: Everything lives in `init.lua`. Do not split
  into modules unless explicitly asked.
- **No lazy-loading**: All plugins load synchronously at startup. Do not add
  deferred or conditional loading.
- **Neovim 0.11+ features**: This config uses `vim.pack`, native `lsp/`
  directory, `vim.lsp.inline_completion`, and other 0.11+ APIs. Do not
  downgrade to older patterns.
- **Minimal config files**: Only `lsp/lua_ls.lua` exists outside init.lua.
  New LSP server configs go in `lsp/<server_name>.lua` following the same
  `return { settings = { ... } }` pattern.
