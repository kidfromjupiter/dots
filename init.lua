-- Basic settings
vim.opt.compatible = false
vim.opt.showmatch = true
vim.opt.ignorecase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.autoindent = true
vim.opt.number = true
vim.opt.wildmode = { "longest", "list" }
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.ttyfast = true
vim.opt.number = true
vim.opt.relativenumber = true

-- 1. Set the folding method to use a custom expression
vim.opt.foldmethod = "expr"
-- 2. Tell Neovim to use Tree-sitter to calculate the fold levels
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- 3. Optional: Keep folds open by default (prevents everything from being collapsed)
vim.opt.foldlevel = 99

vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")

-- Leader key
vim.g.mapleader = " "

-- Transparent background tweaks
vim.cmd([[
hi NonText ctermbg=none guibg=NONE
hi Normal guibg=NONE ctermbg=NONE
hi NormalNC guibg=NONE ctermbg=NONE
hi SignColumn ctermbg=NONE ctermfg=NONE guibg=NONE
hi Pmenu ctermbg=NONE ctermfg=NONE guibg=NONE
hi FloatBorder ctermbg=NONE ctermfg=NONE guibg=NONE
hi NormalFloat ctermbg=NONE ctermfg=NONE guibg=NONE
hi TabLine ctermbg=None ctermfg=None guibg=None
]])



-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup({

  -- Python LSP
  {
    "mason-org/mason.nvim",
    opts = {},
  },

  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "pyright",
        "ruff",
        "ts_ls",        -- TypeScript / JavaScript
        "tailwindcss",  -- Tailwind CSS
        "eslint",       -- ESLint for Next.js linting/formatting
        "cssls",        -- CSS language server
      },
      automatic_enable = false,
    },
  },
  -- LSP base
  {
    "neovim/nvim-lspconfig",
  },
  -- telescope 
    {
      'nvim-telescope/telescope.nvim',
      dependencies = { 
          'nvim-lua/plenary.nvim',
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
        },
      branch="master",
      config = function()
        local telescope = require("telescope")
        local builtin = require("telescope.builtin")

        telescope.setup({
          defaults = {
            file_sorter = require("telescope.sorters").get_fzy_sorter,
            generic_sorter = require("telescope.sorters").get_fzy_sorter,
            mappings = {
              i = {
                  ["<c-d>"] = require('telescope.actions').delete_buffer,
              },
              n = {
                  ["<c-d>"] = require('telescope.actions').delete_buffer,
              },
            },
            preview = {
              treesitter = false,
            },
          },

          extensions = {
            fzf = {
              fuzzy = true,
              override_generic_sorter = true,
              override_file_sorter = true,
              case_mode = "smart_case",
            },
          },
        })

        telescope.load_extension("fzf")
      end,
    },
    -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        -- Configure how the completion menu behaves
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(), -- Trigger completion manually
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept current selection
          
          -- Tab navigation through the completion menu
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        -- Tell nvim-cmp where to fetch completion items from
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- LSP suggestions (clangd, pyright, etc.)
          { name = "path" },     -- File system paths
        }, {
          { name = "buffer" },   -- Text from current buffer
        }),
      })
    end,
  },
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "python",
          "javascript",
          "typescript",
          "tsx",
          "html",
          "css",
          "c",
          "cpp",
          "rust",
          "qmljs"
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
 -- Theme
  {
    "folke/tokyonight.nvim",
    priority = 1000, -- load before everything else
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({})
    end,
  },
  {
    'rhysd/vim-clang-format',
  },
  {
    "3rd/image.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
        },
        neorg = {
          enabled = true,
        },
      },
      max_height_window_percentage = 95,
      max_width_window_percentage = 95,
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
      },
  
      signcolumn = true, -- shows signs in the left gutter
      numhl = true,      -- highlights line numbers for changed lines
      linehl = false,    -- set true if you want whole-line highlight
      word_diff = false, -- toggle when needed
  
      on_attach = function(bufnr)
        local gs = require("gitsigns")
  
        vim.keymap.set("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, { buffer = bufnr })
  
        vim.keymap.set("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, { buffer = bufnr })
  
        vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gi", gs.preview_hunk_inline, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gb", gs.blame_line, { buffer = bufnr })
  
        vim.keymap.set("n", "<leader>tw", gs.toggle_word_diff, { buffer = bufnr })
        vim.keymap.set("n", "<leader>tl", gs.toggle_linehl, { buffer = bufnr })
        vim.keymap.set("n", "<leader>tn", gs.toggle_numhl, { buffer = bufnr })
        vim.keymap.set("n", "<leader>ts", gs.toggle_signs, { buffer = bufnr })
      end,
    },
  }
})

-- ========================
-- LSP: clangd + pyright + ruff
-- ========================

local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("qmlls", {
  cmd = { "/usr/bin/qmlls" }, -- Full system path to the QML Language Server
  filetypes = { "qml" },
  root_markers = {
    "BUILD", -- Captures your Bazel environment root
    "resources.qrc",
    ".git",
  },
  capabilities = capabilities,
})

vim.lsp.config("clangd", {
  cmd = { "clangd", "--background-index" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_markers = {
    "compile_commands.json",
    "compile_flags.txt",
    ".git",
  },
  capabilities = capabilities,
})

vim.lsp.config("pyright", {
  capabilities = capabilities,
  settings = {
    pyright = {
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        extraPaths = {
          "/usr/lib/python3.14/site-packages",
          "/usr/lib64/python3.14/site-packages",
        },
        typeCheckingMode = "off",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
})

vim.lsp.config("ruff", {
  capabilities = capabilities,
})

vim.lsp.config("ts_ls", {
  capabilities = capabilities,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
})

vim.lsp.config("tailwindcss", {
  capabilities = capabilities,
  filetypes = { "html", "css", "javascriptreact", "typescriptreact" },
  root_markers = { "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "package.json" },
})

vim.lsp.config("eslint", {
  capabilities = capabilities,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { ".eslintrc.json", "eslint.config.js", "package.json" },
})

vim.lsp.config("cssls", {
  capabilities = capabilities,
  filetypes = { "css", "scss", "less" },
  root_markers = { "package.json", ".git" },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
  end,
})

vim.lsp.enable({ "clangd", "pyright", "ruff", "qmlls", "ts_ls", "tailwindcss", "eslint", "cssls" })
-------------------------------------

vim.api.nvim_set_hl(0, 'LineNrAbove', { fg='#51B3EC' })
vim.api.nvim_set_hl(0, 'LineNr', { fg='white', bold=true })      -- The current line number
vim.api.nvim_set_hl(0, 'LineNrBelow', { fg='#FF8800' })

-- Keymaps
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle reveal<cr>", { desc = "Toggle Neo-tree" })
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")


-- telescope kb
local builtin = require('telescope.builtin')

-- Key mappings
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })

vim.keymap.set("n", "<leader>tt", ":botright split | terminal<CR>", { desc = "Open terminal split" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })


vim.keymap.set('n', '<S-Tab>', ':bprev<CR>')

vim.keymap.set('n', '<leader>cf', '<cmd>ClangFormat<CR>')


-- Ruff / LSP Keybindings
vim.keymap.set("n", "<leader>rf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Ruff/LSP Format file" })

vim.keymap.set("n", "<leader>rx", function()
  vim.lsp.buf.code_action({
    context = { only = { "source.fixAll.ruff" } },
    apply = true,
  })
end, { desc = "Ruff Fix all auto-fixable issues" })

vim.keymap.set("n", "<leader>ri", function()
  vim.lsp.buf.code_action({
    context = { only = { "source.organizeImports.ruff" } },
    apply = true,
  })
end, { desc = "Ruff Organize imports" })

-- Automatically run Ruff formatting and fixes on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    -- 1. Organize imports using Ruff LSP
    vim.lsp.buf.code_action({
      context = { only = { "source.organizeImports.ruff" } },
      apply = true,
    })

    -- 2. Run auto-fixes (like removing unused imports)
    vim.lsp.buf.code_action({
      context = { only = { "source.fixAll.ruff" } },
      apply = true,
    })

    -- 3. Format the document
    -- We use synchronous formatting (async = false) to guarantee it finishes before the write occurs
    vim.lsp.buf.format({ async = false })
  end,
})
--
-- Add QML Format Keybinding
vim.keymap.set('n', '<leader>qf', function()
  local file = vim.api.nvim_buf_get_name(0)
  vim.fn.jobstart({ "/usr/bin/qmlformat-qt6", "-i", file }, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.cmd("edit!") -- Reload the buffer silently to show the changes
      else
        print("qmlformat failed")
      end
    end
  })
end, { desc = "Format QML file" })
