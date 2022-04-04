-- vim:foldmethod=marker
-- Install packer
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local au = require('au')

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'tpope/vim-fugitive'
  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end,
  }
  use {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup({
        basic = true,
        extended = true,
      })
    end,
  }
  use {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup({
        options = {
          icons_enabled = true,
          theme = 'onedark',
          component_separators = '|',
          section_separators = '',
        },
      })
    end,
  }
  use 'navarasu/onedark.nvim'
  use {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('indent_blankline').setup({
        use_treesitter = false,
        buftype_exclude = {"terminal"},
        filetype_exclude = {
          "qf",
          "startify",
          "help",
          "coc-explorer",
          "coctree",
          "fzf",
          "Trouble",
        },
      })
    end,
    cond = function()
      return vim.g.vscode == nil
    end,
  }
  use 'editorconfig/editorconfig-vim'
  use 'tpope/vim-surround'
  use 'tpope/vim-repeat'
  use 'lambdalisue/suda.vim'
  use 'neoclide/jsonc.vim'
  use 'inkarkat/vim-ReplaceWithRegister'
end)

-- Default indentation
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.shiftround = true
vim.o.expandtab = true

-- Syncs the vim continuation indentation with shiftwidth
vim.g.vim_indent_cont = vim.o.shiftwidth

-- Special characters
vim.opt.list = true
-- vim.opt.listchars:append('space:⋅')
-- vim.opt.listchars:append("eol:↴")
vim.opt.listchars:append('trail:·')
vim.opt.listchars:append('tab: →')
vim.opt.listchars:append('nbsp:␣')
vim.opt.listchars:append('extends:▶')
vim.opt.listchars:append('precedes:◀')

-- Line wrapping
vim.opt.breakat = " 	!@*-+;:,./?"

-- Ignore case when searching (can be overridden with \C)
vim.opt.ignorecase = true

-- Insert-mode completion
vim.opt.completeopt = 'menuone,noselect'

-- Enable mouse support
vim.opt.mouse = 'a'

-- Highlight current line
vim.opt.cursorline = true

-- Show some context around the cursor
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 1

-- Prevent screen from redrawing while executing commands
vim.opt.lazyredraw = true

-- Enable persistent undo history
vim.opt.undofile = true

-- Reduce CursorHold latency (makes some plugins more responsive)
vim.opt.updatetime = 100

-- Enable true color (24-bit)
vim.opt.termguicolors = true

-- Highlight on yank {{{
au.group('HighlightOnYank', function(grp)
  grp.TextYankPost = {
    '*',
    function()
      vim.highlight.on_yank({ higroup = 'Visual', timeout = 250 })
    end,
  }
end)
-- }}}

-- Signcolumn {{{
au.group('AutoSignColumn', function(grp)
  grp.BufWinEnter = {
    '*',
    function()
      local config = vim.api.nvim_win_get_config(0)
      vim.opt.signcolumn = config.buftype ~= 'nofile' and 'yes:1' or 'no'
    end,
  }
end)
-- }}}

-- Git commit column hint {{{
au.group('GitMessageLength', function(grp)
  grp.FileType = {
    'gitcommit',
    function()
      vim.o.colorcolumn = "80"
    end,
  }
end)
-- }}}

-- Disable automatic line continuation of comments {{{
au.group('DisableCommentContinuation', function(grp)
  local cmd = {
    '*',
    function()
      vim.opt.formatoptions = 'cljq'
    end,
  }

  grp.BufEnter = cmd
  grp.BufNewFile = cmd
end)
-- }}}

-- Navigation with linewrap {{{
vim.api.nvim_set_keymap(
  '',
  'k',
  "v:count == 0 ? 'gk' : 'k'",
  { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap(
  '',
  'j',
  "v:count == 0 ? 'gj' : 'j'",
  { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap(
  '',
  '<Up>',
  "v:count == 0 ? 'gk' : 'k'",
  { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap(
  '',
  '<Down>',
  "v:count == 0 ? 'gj' : 'j'",
  { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap(
  'i',
  '<Up>',
  "v:count == 0 ? '<C-o>gk' : '<C-o>k'",
  { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap(
  'i',
  '<Down>',
  "v:count == 0 ? '<C-o>gj' : '<C-o>j'",
  { noremap = true, expr = true, silent = true })
-- }}}

-- Tab navigation {{{
vim.api.nvim_set_keymap('n', '<M-Left>', '<Cmd>tabprev<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<M-Right>', '<Cmd>tabnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<M-C-Left>', '<Cmd>tabprev<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<M-C-Right>', '<Cmd>tabnext<CR>', { noremap = true, silent = true })
-- }}}

-- Enable emacs-style navigation in command mode {{{
vim.api.nvim_set_keymap('c', '<C-a>', '<Home>', { noremap = true })
vim.api.nvim_set_keymap('c', '<C-e>', '<End>', { noremap = true })
-- }}}

-- Unmap undesirable keys {{{
vim.api.nvim_set_keymap('', '<C-a>', '<nop>', { noremap = true })
vim.api.nvim_set_keymap('', '<C-x>', '<nop>', { noremap = true })

vim.api.nvim_set_keymap(
  'i',
  '<M-Up>',
  '<nop>',
  { noremap = true, silent = true })
vim.api.nvim_set_keymap(
  'i',
  '<M-Down>',
  '<nop>',
  { noremap = true, silent = true })
vim.api.nvim_set_keymap(
  'i',
  '<M-S-Up>',
  '<nop>',
  { noremap = true, silent = true })
vim.api.nvim_set_keymap(
  'i',
  '<M-S-Down>',
  '<nop>',
  { noremap = true, silent = true })
vim.api.nvim_set_keymap(
  'i',
  '<S-Up>',
  '<nop>',
  { noremap = true, silent = true })
vim.api.nvim_set_keymap(
  'i',
  '<S-Down>',
  '<nop>',
  { noremap = true, silent = true })
-- }}}

-- Stay in visual mode when indenting {{{
vim.api.nvim_set_keymap('v', '<lt>', '<lt>gv', { noremap = true })
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true })
-- }}}

-- Replace-with mappings {{{
vim.api.nvim_set_keymap('n', 'r', '<nop>', { noremap = true })
vim.api.nvim_set_keymap('x', 'r', '<nop>', { noremap = true })
vim.api.nvim_set_keymap('n', 'rc', 'r', { noremap = true })
vim.api.nvim_set_keymap('x', 'rc', 'r', { noremap = true })
vim.api.nvim_set_keymap('n', 'rr', '<Plug>ReplaceWithRegisterOperator', {})
vim.api.nvim_set_keymap('x', 'rr', '<Plug>ReplaceWithRegisterVisual', {})
vim.api.nvim_set_keymap('x', 'r^', '<Plug>ReplaceWithRegisterLine', {})
-- }}}

-- Interactive replace {{{
vim.api.nvim_set_keymap(
  'n',
  ';;',
  ':.,$s~~~cg<Left><Left><Left><Left>', { noremap = true })
-- }}}

-- Color scheme {{{
require('onedark').load()
-- }}}
