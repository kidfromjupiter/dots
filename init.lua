-- Basic settings
vim.opt.compatible = false
vim.opt.showmatch = true
vim.opt.ignorecase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
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
  },
  -- Treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter").setup({
          -- List of languages you want parsers for
          ensure_installed = { "lua", "python", "javascript", "c", "rust", "cpp" }, -- add languages you use
          auto_install = true, -- automatically install missing parsers when opening a file
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
    "tpope/vim-fugitive",
    cmd = {
      "Git",
      "G",
      "Gdiffsplit",
      "Gvdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GRename",
      "GDelete",
      "GRemove",
      "GBrowse",
    },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
      { "<leader>gd", "<cmd>Gvdiffsplit<cr>", desc = "Git diff" },
    },
  },
})

-- ========================
-- LSP: clangd + pyright
-- ========================
local capabilities = require("cmp_nvim_lsp").default_capabilities()

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
vim.lsp.enable("clangd")

vim.lsp.config("pyright", {
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})
vim.lsp.enable("pyright")

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
