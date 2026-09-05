-- [[ Basic Settings ]]
vim.opt.number = true          -- Show line numbers
vim.opt.relativenumber = false -- Relative line numbers
vim.opt.mouse = "a"            -- Enable mouse support
vim.opt.showmode = false       -- We'll use statusline instead
-- vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.undofile = true        -- Save undo history
vim.opt.ignorecase = true      -- Case-insensitive searching
vim.opt.smartcase = true       -- But be smart about it
vim.opt.signcolumn = "yes"     -- Keep sign column always visible
vim.opt.updatetime = 250       -- Faster update time
vim.opt.timeoutlen = 300       -- Faster key sequence timeout
vim.opt.splitright = true      -- New splits open to the right
vim.opt.splitbelow = true      -- New splits open below
vim.opt.list = true            -- Show invisible characters
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"   -- Preview substitutions live
vim.opt.cursorline = false     -- Highlight current line
vim.opt.scrolloff = 10         -- Keep 10 lines below/above cursor
vim.opt.sidescrolloff = 8      -- Keep 8 columns side scrolling
vim.opt.termguicolors = true
--
-- Indent options
vim.opt.breakindent = true  -- Better indentation for wrapped lines
vim.opt.autoindent = true   -- Copy indent from furrent line when starting a new line
vim.opt.smartindent = false -- Do smart autoindenting when starting a new line
vim.opt.cindent = false     -- Indent fo C progs
vim.opt.copyindent = true   -- Copy the structure of the existing lines indent when autoindenting a new line.
vim.opt.fixeol = false       -- Probably fix for chezmoi EOL diffs

vim.opt.swapfile = false

-- Plugins
vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/zapling/mason-conform.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/numtostr/comment.nvim",
  "https://github.com/kylechui/nvim-surround",
  "https://github.com/mikavilpas/yazi.nvim",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/saghen/blink.lib",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/olimorris/codecompanion.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/xvzc/chezmoi.nvim",

  -- "https://github.com/christoomey/vim-tmux-navigator",
  "https://github.com/knubie/vim-kitty-navigator",

  -- Themes
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/catppuccin/nvim",
  "https://github.com/shaunsingh/nord.nvim",
  "https://github.com/sainnhe/gruvbox-material",
  "https://github.com/nyoom-engineering/oxocarbon.nvim",
})

require("tokyonight").setup({
  transparent = true,
})
vim.cmd.colorscheme("tokyonight-night")

-- [[ Tab Settings: 2 spaces ]]
vim.opt.tabstop = 2      -- Number of spaces a tab counts for
vim.opt.softtabstop = 2  -- Number of spaces for editing (backspace)
vim.opt.shiftwidth = 2   -- Number of spaces for auto-indent
vim.opt.expandtab = true -- Convert tabs to spaces

-- [[ Enable .nvim.lua files]]
vim.o.exrc = true
vim.o.secure = true

-- [[ Key Mappings ]]
vim.g.mapleader = " " -- Set space as leader key
vim.g.maplocalleader = " "

-- [[ Functions ]]
function save()
  vim.cmd('write')
  require("clear_statusline").start_clear_timer()
end

function format()
  require("conform").format()
  -- vim.lsp.buf.format({ async = true, lsp_fallback = true })
end

function format_and_save()
  require("conform").format()
  save()
end

function close_window_with_confirm()
  local choice = vim.fn.confirm(
    "Close window?",
    "&Yes\n&No",
    1
  )
  if choice == 1 then
    vim.cmd('close')
  end
end

vim.keymap.set('n', '<C-w>,', ':tabprevious<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-w>.', ':tabnext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-w><', ':<C-u>execute "tabmove " . (tabpagenr() - 2)<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-w>>', ':<C-u>execute "tabmove " . tabpagenr()<CR>', { noremap = true, silent = true })

-- Better navigation
vim.keymap.set("n", "<C-w>h", "<Nop>")
vim.keymap.set("n", "<C-w>j", "<Nop>")
vim.keymap.set("n", "<C-w>k", "<Nop>")
vim.keymap.set("n", "<C-w>l", "<Nop>")
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Format and save
vim.keymap.set("n", "<leader>w", save, { desc = "Write without formatting" })
vim.keymap.set("n", "<leader>W", format_and_save, { desc = "Write with formatting" })

-- Windows
vim.keymap.set("n", "<C-w><C-v>", "<Nop>")
vim.keymap.set("n", "<C-w><C-c>", "<Nop>")
vim.keymap.set("n", "<C-w><C-t>", "<Nop>")
vim.keymap.set("n", "<C-w><C-p>", "<Nop>")
vim.keymap.set("n", "<C-w><C-n>", "<Nop>")
vim.keymap.set("n", "<C-w>v", vim.cmd.vsplit, { desc = "Split vertical", silent = true, })
vim.keymap.set("n", "<C-w>c", vim.cmd.split, { desc = "Split horizontal", silent = true, })
vim.keymap.set("n", "<C-w>t", vim.cmd.tabnew, { desc = "Tab new", silent = true, })
vim.keymap.set("n", "<C-w>p", vim.cmd.tabprevious, { desc = "Tab previous", silent = true, })
vim.keymap.set("n", "<C-w>n", vim.cmd.tabnext, { desc = "Tab next", silent = true, })
vim.keymap.set("n", "<C-w>q", close_window_with_confirm, { desc = "Close window with confirm" })
vim.keymap.set("n", "<C-w>]", "gt", { desc = "Goto next tab", silent = true })
vim.keymap.set("n", "<C-w>[", "gT", { desc = "Goto previous tab", silent = true })

for i = 1, 9 do
  vim.keymap.set("n", "<C-w>" .. i, function()
    if i <= #vim.api.nvim_list_tabpages() then
      vim.cmd("tabnext " .. i)
    end
  end, { desc = "Tab " .. i, silent = true })
end


-- Better indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move selected lines
-- vim.keymap.set("v", "J", ":m '>+1<CR>gv", { desc = "Move selected lines down" })
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv", { desc = "Move selected lines up" })

-- Keep cursor centered
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down, center cursor" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up, center cursor" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result, center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result, center" })

vim.keymap.set("n", "<leader>n", ":noh<CR>", { desc = "noh", silent = true })

require("clear_statusline").setup({ timeout = 3000 })

local telescope_builtin = require("telescope.builtin")

local function telescope_find_files()
  -- if not pcall(telescope_builtin.git_files) then
  telescope_builtin.find_files({
    hidden = true,
  })
  -- end
end

local function telescope_live_grep()
  require("telescope.builtin").live_grep({
    additional_args = { "--hidden" }
  })
end

vim.keymap.set("n", "<leader>ff", telescope_find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", telescope_live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", telescope_builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", telescope_builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>ft", telescope_builtin.treesitter, { desc = "Telescope treesitter" })
vim.keymap.set("n", "<leader>fs", telescope_builtin.current_buffer_fuzzy_find,
  { desc = "Telescope current buffer fuzzy find" })

vim.api.nvim_create_user_command("Source", function()
  vim.cmd('source ~/.config/nvim/init.lua')
  print('Configuration reloaded!')
end, { desc = "Reload configuration" })


-- Configure completion behavior
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
-- menu: Show popup menu
-- menuone: Show menu even with one item
-- noselect: Don't auto-select the first item
-- noinsert: Don't auto-insert text

-- Ctrl+Space to manually trigger omnifunc completion
vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { noremap = true })

-- [[ Lsp hotkeys ]]
--
-- GLOBAL DEFAULTS:
-- "gra" (Normal and Visual mode) is mapped to vim.lsp.buf.code_action()
-- "gri" is mapped to vim.lsp.buf.implementation()
-- "grn" is mapped to vim.lsp.buf.rename()
-- "grr" is mapped to vim.lsp.buf.references()
-- "grt" is mapped to vim.lsp.buf.type_definition()
-- "grx" is mapped to vim.lsp.codelens.run()
-- "gO" is mapped to vim.lsp.buf.document_symbol()
-- CTRL-S (Insert mode) is mapped to vim.lsp.buf.signature_help()
-- v_an and v_in fall back to LSP vim.lsp.buf.selection_range() if treesitter is not active.
-- gx handles textDocument/documentLink.
--
-- BUFFER-LOCAL DEFAULTS:
-- 'omnifunc' is set to vim.lsp.omnifunc(), use i_CTRL-X_CTRL-O to trigger completion.
-- 'tagfunc' is set to vim.lsp.tagfunc(). This enables features like go-to-definition, :tjump, and keymaps like CTRL-], CTRL-W_], CTRL-W_} to utilize the language server.
-- 'formatexpr' is set to vim.lsp.formatexpr(), so you can format lines via gq if the language server supports it.
-- To opt out of this use gw instead of gq, or clear 'formatexpr' on LspAttach.
-- K is mapped to vim.lsp.buf.hover() unless 'keywordprg' is customized or a custom keymap for K exists.

vim.keymap.set("n", "H", vim.diagnostic.open_float, { desc = "Show diagnostic in floating window" })

-- Go to definition
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

-- Go to declaration (often similar to definition)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })

vim.api.nvim_create_user_command("Format", format, { desc = "Format current buffer" })

-- [[ Surround
require("nvim-surround").setup()

require("mason").setup()
require("mason-lspconfig").setup {
  automatic_enable = true,    -- Automatically enable LSP for matching filetypes
  ensure_installed = {
    "bashls",                 -- Bash language server for shell scripts

    "ruff",                   -- Fast Python linter and formatter (replaces flake8, isort, etc.)
    "pyright",                -- Python type checker and language server (static type checking)

    "ts_ls",                  -- TypeScript/JavaScript language server (tsserver)
    "vtsls",                  -- Alternative TypeScript language server with more features (Volta)
    "eslint",                 -- ESLint language server for JavaScript/TypeScript

    "rust_analyzer",          -- Rust language server with full IDE features
    "gopls",                  -- Go language server from the Go team
    "clangd",                 -- C/C++ language server with clang tooling
    "omnisharp",              -- C# language server for .NET development (typo: should be "omnisharp")
    "jdtls",                  -- Eclipse JDT Language Server for Java
    "kotlin_language_server", -- Kotlin language server
    "phpactor",               -- PHP language server with refactoring tools
    "crystalline",            -- Crystal language server

    "jsonls",                 -- JSON language server with schema support
    "html",                   -- HTML language server
    "cssls",                  -- CSS language server
    "yamlls",                 -- YAML language server with schema support
    "marksman",               -- Markdown language server for writing documentation
    "dockerls",               -- Dockerfile language server
    "taplo",                  -- TOML language server (for Cargo.toml, pyproject.toml, etc.)
    "lemminx",                -- XML language server
    "sqlls",                  -- SQL language server

    -- "lua_ls", -- Lua language server with Neovim plugin support
    -- "terraformls",   -- Terraform language server
    -- "ansiblels",     -- Ansible language server
    -- "helm_ls",       -- Helm language server for Kubernetes
    -- "argocd_ls",     -- ArgoCD language server
    -- "swiftfs",       -- Swift language server
    -- "perlpls",       -- Perl language server
    -- "r_language_server", -- R language server
    -- "svelte",        -- Svelte language server for Svelte frameworks
    -- "vue",           -- Vue language server (Volar)
    -- "graphql",       -- GraphQL language server
    -- "prismals",      -- Prisma ORM language server
    -- "tailwindcss",   -- Tailwind CSS language server
    -- "emmet_ls",      -- Emmet language server for HTML/CSS abbreviations
    -- "sourcery",      -- Python code refactoring assistant

    -- "zls", -- Zig language server
  },
}
vim.lsp.enable("zls") -- enable this to use system zls instead of mason

require("conform").setup({
  formatters_by_ft = {
    -- Lua
    lua = { "stylua" },

    -- Python: run multiple formatters sequentially
    python = { "ruff_format", "ruff_fix", "isort", "black" },
    -- Alternative: use autopep8 or yapf instead of black [citation:2][citation:5]
    -- python = { "isort", "autopep8" },

    -- JavaScript/TypeScript: try prettierd first, fallback to prettier
    javascript = { "prettierd", "prettier" },
    typescript = { "prettierd", "prettier" },
    javascriptreact = { "prettierd", "prettier" },
    typescriptreact = { "prettierd", "prettier" },

    -- Web frontend
    html = { "prettierd", "prettier" },
    css = { "prettierd", "prettier" },
    scss = { "prettierd", "prettier" },
    json = { "prettierd", "prettier" },
    yaml = { "prettierd", "prettier" },
    markdown = { "prettierd", "prettier" },

    -- Go
    go = { "gofumpt", "goimports-reviser", "gci" },
    -- Alternative: gofmt, goimports [citation:2]
    -- go = { "gofmt", "goimports" },

    -- Rust
    rust = { "rustfmt" },

    -- C/C++
    c = { "clang-format" },
    cpp = { "clang-format" },
    -- Alternative: uncrustify [citation:5]

    -- Java
    java = { "google-java-format" },
    -- Alternative: ktfmt for Kotlin, ktlint [citation:2]

    -- Ruby
    ruby = { "htmlbeautifier" }, -- for ERB/HTML with Ruby
    erb = { "erb_format" },

    -- PHP
    php = { "mago_format" },
    -- Alternative: easy-coding-standard [citation:2]
    blade = { "blade-formatter" },

    -- C#
    -- cs = { "csharpier" },

    -- Dart
    dart = { "dart_format", "dcm_format" },

    -- Shell scripts
    sh = { "beautysh" },
    bash = { "beautysh" },
    zsh = { "beautysh" },

    -- Nix
    nix = { "alejandra" },

    -- Zig
    zig = { "zigfmt" } or { "zon" } or { "zigenv" },

    -- Swift
    swift = { "swiftformat" },

    -- Haskell
    haskell = { "fourmolu" }, -- or "hindent", "ormolu"

    -- Erlang
    erlang = { "erlfmt" }, -- or "efmt" [citation:2]

    -- Elixir
    elixir = { "mix" }, -- format with mix format

    -- Vue / Svelte (work with prettier via plugin)
    vue = { "prettierd", "prettier" },
    svelte = { "prettierd", "prettier" },

    -- SQL
    sql = { "sqlfluff" },

    -- Dockerfile
    dockerfile = { "dockerfmt" }, -- or "dockfmt" [citation:2]

    -- CMake
    cmake = { "gersemi" }, -- or "cmake_format" [citation:2]

    -- XML / SVG
    xml = { "xmlformat" },

    -- TOML
    toml = { "taplo" },

    -- YAML
    yaml = { "yamlfmt" },

    -- JSON
    json = { "fixjson" }, -- or "jq" [citation:2]

    -- Protocol Buffers
    proto = { "buf" },

    -- Markdown with table of contents
    markdown = { "prettierd", "prettier", "markdown-toc" },

    -- Misc / config files
    just = { "just" },
    dune = { "format-dune-file" },
    hcl = { "hcl" },
    tf = { "terraform" }, -- Terraform
    cue = { "cue_fmt" },
    kdl = { "kdlfmt" },

    -- Use a sub-list to run only the first available formatter
    -- '*' is a special key that runs for all filetypes not listed
    ["*"] = { "prettierd", "prettier" },
    -- '_' runs for filetypes that have no other formatters configured [citation:7]
  },
})

require("mason-conform").setup({
})

-- [[ Treesitter
-- vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- vim.wo[0][0].foldmethod = "expr"

require("nvim-treesitter").setup({
  highlight = { enable = true },
  incremental_selection = { enable = true },
  textobjects = { enable = true },
  indent = { enable = true },

  ensure_installed = "all",
  sync_install = false,
  auto_install = true,
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99 -- Start with all folds open

-- [[ Treesitter textobjects
require("nvim-treesitter-textobjects").setup {
  select = {
    -- Automatically jump forward to textobj, similar to targets.vim
    lookahead = true,
    -- You can choose the select mode (default is charwise 'v')
    --
    -- Can also be a function which gets passed a table with the keys
    -- * query_string: eg '@function.inner'
    -- * method: eg 'v' or 'o'
    -- and should return the mode ('v', 'V', or '<c-v>') or a table
    -- mapping query_strings to modes.
    selection_modes = {
      -- ['@parameter.outer'] = 'v', -- charwise
      -- ['@function.outer'] = 'V', -- linewise
      -- ['@class.outer'] = '<c-v>', -- blockwise
    },
    -- If you set this to `true` (default is `false`) then any textobject is
    -- extended to include preceding or succeeding whitespace. Succeeding
    -- whitespace has priority in order to act similarly to eg the built-in
    -- `ap`.
    --
    -- Can also be a function which gets passed a table with the keys
    -- * query_string: eg '@function.inner'
    -- * selection_mode: eg 'v'
    -- and should return true of false
    include_surrounding_whitespace = false,
  },
  move = {
    -- whether to set jumps in the jumplist
    set_jumps = true,
  },
}

local function is_in_fold()
  return vim.fn.foldclosed(".") ~= -1
end

vim.keymap.set({ "n", "x", "o" }, "]]", function()
  if is_in_fold() then
    vim.cmd("normal! zj") -- Move to next fold
  else
    require("nvim-treesitter-textobjects.move").goto_next_start("@block.outer", "textobjects")
  end
end, { desc = "Goto next start of block" })

vim.keymap.set({ "n", "x", "o" }, "]}", function()
  if is_in_fold() then
    vim.cmd("normal! zj") -- Move to next fold
  else
    require("nvim-treesitter-textobjects.move").goto_next_end("@block.outer", "textobjects")
  end
end, { desc = "Goto next end of block" })

vim.keymap.set({ "n", "x", "o" }, "[[", function()
  if is_in_fold() then
    vim.cmd("normal! zk") -- Move to prev fold
  else
    require("nvim-treesitter-textobjects.move").goto_previous_start("@block.outer", "textobjects")
  end
end, { desc = "Goto prev start of block" })

vim.keymap.set({ "n", "x", "o" }, "[{", function()
  if is_in_fold() then
    vim.cmd("normal! zk") -- Move to prev fold
  else
    require("nvim-treesitter-textobjects.move").goto_previous_end("@block.outer", "textobjects")
  end
end, { desc = "Goto prev end of block" })

require("chezmoi").setup {
  edit = {
    watch = false,
    force = false,
    ignore_patterns = {
      "run_onchange_.*",
      "run_once_.*", 
      "%.chezmoiignore",
      "%.chezmoitemplate",
      -- Add custom patterns here
    },
  },
  events = {
    on_open = {
      notification = {
        enable = true,
        msg = "Opened a chezmoi-managed file",
        opts = {},
      },
    },
    on_watch = {
      notification = {
        enable = true,
        msg = "This file will be automatically applied",
        opts = {},
      },
    },
    on_apply = {
      notification = {
        enable = true,
        msg = "Successfully applied",
        opts = {},
      },
    },
  },
  telescope = {
    select = { "<CR>" },
  },
}

-- The below configuration wll allow you to automatically apply changes on files under chezmoi source path.
--  e.g. ~/.local/share/chezmoi/*
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/*" },
    callback = function(ev)
        local bufnr = ev.buf
        local edit_watch = function()
            require("chezmoi.commands.__edit").watch(bufnr)
        end
        vim.schedule(edit_watch)
    end,
})

-- [[ Yazi
vim.keymap.set("n", "<leader>-", function()
  require("yazi").yazi()
end, { desc = "Open yazi at the current file" })

-- 👇 if you use `open_for_directories=true`, this is recommended.
--
-- mark netrw as loaded so it's not loaded at all.
-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
vim.g.loaded_netrwPlugin = 1
vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    require("yazi").setup({
      -- 'none', 'rounded', 'single', 'double', 'shadow'
      yazi_floating_window_border = 'rounded',
      -- Optional: other common settings you might want to include
      open_for_directories = true,          -- Set to true if you want yazi to replace netrw
      floating_window_scaling_factor = 0.8, -- Control window size (0.9 = 90%)
      yazi_floating_window_winblend = 0,    -- Transparency (0 = opaque)

      keymaps = {
        open_file_in_vertical_split = "<C-v>",
        open_file_in_horizontal_split = "<C-c>",
      },
    })
  end,
})

-- [[ Blink.cmp
require("blink.cmp").build():pwait()
require("blink.cmp").setup {
  completion = {
    documentation = { auto_show = true },
    list = { selection = { preselect = true, auto_insert = false } },
    ghost_text = { enabled = true },
  },
  cmdline = {
    enabled = true,
    keymap = { preset = 'inherit' },
    completion = {
      menu = { auto_show = true },
      list = { selection = { preselect = true, auto_insert = false } },
      ghost_text = { enabled = true },
    },
  },
  signature = {
    enabled = true,
  },
}
build = function() require('blink.cmp').build():pwait() end

-- [[ Gitsigns
require('gitsigns').setup {
  current_line_blame = true,

  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']h', function()
      if vim.wo.diff then
        vim.cmd.normal({ ']h', bang = true })
      else
        gitsigns.nav_hunk('next')
      end
    end, { desc = "Git: Next hunk" })

    map('n', '[h', function()
      if vim.wo.diff then
        vim.cmd.normal({ '[h', bang = true })
      else
        gitsigns.nav_hunk('prev')
      end
    end, { desc = "Git: Previous hunk" })

    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = "Git: Stage hunk" })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = "Git: Reset hunk" })

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, { desc = "Git: Stage hunk" })

    map('v', '<leader>hr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, { desc = "Git: Reset hunk" })

    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = "Git: Stage buffer" })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = "Git: Reset buffer" })

    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Git: Preview hunk" })
    map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = "Git: Preview hunk inline" })
  end
}

require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = "llama",
    },
    inline = {
      adapter = "llama",
    },
    agent = {
      adapter = "llama",
    },
  },
  adapters = {
    http = {
      llama = function()
        return require("codecompanion.adapters").extend("openai_compatible", {
          env = {
            url = "http://127.0.0.1:8080",
            api_key = "TERM",
            chat_url = "/v1/chat/completions",
          },
          schema = {
            model = {
              default = "gemma4:12B",
            },
            num_ctx = {
              default = 90000,
            },
          },
        })
      end,
    }
  },
})

vim.keymap.set({ "n", "v" }, "<LocalLeader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "<LocalLeader>aa", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])
