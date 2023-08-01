-- vim:foldmethod=marker
-- Install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local au = require("core.au")
local keymap = require("core.keymap")

require("lazy").setup({
  "nvim-lua/plenary.nvim",
  "tpope/vim-fugitive",
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(...) keymap.map_buf(bufnr, ...) end

        map("n", "]c", function()
          vim.schedule(function() gs.next_hunk() end)
        end)
        map("n", "[c", function()
          vim.schedule(function() gs.prev_hunk() end)
        end)
        map({"n", "v"}, "<leader>hs", ":Gitsigns stage_hunk<CR>")
        map({"n", "v"}, "<leader>hr", ":Gitsigns reset_hunk<CR>")
        map("n", "<leader>hS", gs.stage_buffer)
        map("n", "<leader>hu", gs.undo_stage_hunk)
        map("n", "<leader>hR", gs.reset_buffer)
        map("n", "<leader>hp", gs.preview_hunk)
        map("n", "<leader>hb", function() gs.blame_line({full = true}) end)
        map("n", "<leader>tb", gs.toggle_current_line_blame)
        map("n", "<leader>hd", gs.diffthis)
        map("n", "<leader>hD", function() gs.diffthis("~") end)
        map("n", "<leader>td", gs.toggle_deleted)
        map({"o", "x"}, "ih", ":<C-U>Gitsigns select_hunk<CR>")
      end
    },
  },
  {
    "numToStr/Comment.nvim",
    tag = (function()
      if vim.fn.has("nvim-0.7") == 0 then
        return "v0.6"
      end
    end)(),
    opts = {
      basic = true,
      extended = true,
    },
  },
  {
    "navarasu/onedark.nvim",
    event = "VimEnter",
    config = function()
      require("onedark").load()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "onedark.nvim",
    },
    opts = {
      options = {
        icons_enabled = false,
        theme = "onedark",
        component_separators = "\u{2502}",
        section_separators = "",
      },
      sections = {
        lualine_a = {"mode"},
        lualine_b = {
          {"branch", icons_enabled = true},
          "diff",
          "diagnostics"
        },
        lualine_c = {"filename"},
        lualine_x = {"encoding", "fileformat", "filetype"},
        lualine_y = {"progress"},
        lualine_z = {"location"}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {"filename"},
        lualine_x = {"location"},
        lualine_y = {},
        lualine_z = {}
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
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
    },
    cond = function()
      return vim.g.vscode == nil
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    keys = function()
      local Terminal = require("toggleterm.terminal").Terminal
      local term = Terminal:new({
        direction = "float",
        hidden = true,
        float_opts = {
          border = "curved",
        },
        on_open = function(term)
          vim.cmd("startinsert!")
        end,
      })

      function toggle()
        term:toggle()
      end

      return {
        keymap.mapping{ { "n", "t" }, "<C-t>", toggle }
      }
    end,
  },
  "editorconfig/editorconfig-vim",
  "tpope/vim-surround",
  "tpope/vim-repeat",
  "neoclide/jsonc.vim",
  {
    "inkarkat/vim-ReplaceWithRegister",
    keys = {
      keymap.mapping{ "n", "r", "<nop>" },
      keymap.mapping{ "x", "r", "<nop>" },
      keymap.mapping{ "n", "rc", "r" },
      keymap.mapping{ "x", "rc", "r" },
      keymap.mapping{ "n", "rr", "<Plug>ReplaceWithRegisterOperator" },
      keymap.mapping{ "n", "r^", "<Plug>ReplaceWithRegisterLine" },
      keymap.mapping{ "x", "rr", "<Plug>ReplaceWithRegisterVisual" },
    },
  },
  -- Filetypes
  "LnL7/vim-nix",
  "fladson/vim-kitty",
  "tikhomirov/vim-glsl",
})

-- Default indentation
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.shiftround = true
vim.o.expandtab = true

-- Syncs the vim continuation indentation with shiftwidth
vim.g.vim_indent_cont = vim.o.shiftwidth

-- Special characters
vim.opt.list = true
-- vim.opt.listchars:append("space:⋅")
-- vim.opt.listchars:append("eol:↴")
vim.opt.listchars:append("trail:·")
vim.opt.listchars:append("tab: →")
vim.opt.listchars:append("nbsp:␣")
vim.opt.listchars:append("extends:▶")
vim.opt.listchars:append("precedes:◀")

-- Line wrapping
vim.opt.breakat = " 	!@*-+;:,./?"

-- Ignore case when searching (can be overridden with \C)
vim.opt.ignorecase = true

-- Insert-mode completion
vim.opt.completeopt = "menuone,noselect"

-- Enable mouse support
vim.opt.mouse = "a"

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
au.group("HighlightOnYank", function(grp)
  grp.TextYankPost = {
    "*",
    function()
      vim.highlight.on_yank({ higroup = "Visual", timeout = 250 })
    end,
  }
end)
-- }}}

-- Clipboard {{{
do
  local uname = vim.loop.os_uname()
  if uname ~= nil
    and uname.sysname == "Linux"
    and uname.release:find("microsoft") then
    vim.g.clipboard = {
      name = "win32yank-wsl",
      copy = {
        ["+"] = "win32yank.exe -i --crlf",
        ["*"] = "win32yank.exe -i --crlf",
      },
      paste = {
        ["+"] = "win32yank.exe -o --lf",
        ["*"] = "win32yank.exe -o --lf",
      },
      cache_enabled = 0,
    }
  end
end
-- }}}

-- Signcolumn {{{
au.group("AutoSignColumn", function(grp)
  grp.BufWinEnter = {
    "*",
    function()
      local config = vim.api.nvim_win_get_config(0)
      vim.opt.signcolumn = config.buftype ~= "nofile" and "yes:1" or "no"
    end,
  }
end)
-- }}}

-- Git commit column hint {{{
au.group("GitMessageLength", function(grp)
  grp.FileType = {
    "gitcommit",
    function()
      vim.o.colorcolumn = "80"
    end,
  }
end)
-- }}}

-- Disable automatic line continuation of comments {{{
au.group("DisableCommentContinuation", function(grp)
  local cmd = {
    "*",
    function()
      vim.opt.formatoptions = "cljq"
    end,
  }

  grp.BufEnter = cmd
  grp.BufNewFile = cmd
end)
-- }}}

-- Navigation with linewrap {{{
keymap.map("", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
keymap.map("", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
keymap.map("", "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true })
keymap.map("", "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true })
keymap.map("i", "<Up>", "v:count == 0 ? '<C-o>gk' : '<C-o>k'", { expr = true })
keymap.map("i", "<Down>", "v:count == 0 ? '<C-o>gj' : '<C-o>j'", { expr = true })
-- }}}

-- Tab navigation {{{
keymap.map("n", "<M-Left>", "<Cmd>tabprev<CR>")
keymap.map("n", "<M-Right>", "<Cmd>tabnext<CR>")
keymap.map("n", "<M-C-Left>", "<Cmd>tabprev<CR>")
keymap.map("n", "<M-C-Right>", "<Cmd>tabnext<CR>")
-- }}}

-- Enable emacs-style navigation in command mode {{{
keymap.map("c", "<C-a>", "<Home>")
keymap.map("c", "<C-e>", "<End>")
-- }}}

-- Unmap undesirable keys {{{
keymap.map("", "<C-a>", "<nop>")
keymap.map("", "<C-x>", "<nop>")

keymap.map("i", "<M-Up>", "<nop>")
keymap.map("i", "<M-Down>", "<nop>")
keymap.map("i", "<M-S-Up>", "<nop>")
keymap.map("i", "<M-S-Down>", "<nop>")
keymap.map("i", "<S-Up>", "<nop>")
keymap.map("i", "<S-Down>", "<nop>")
-- }}}

-- Stay in visual mode when indenting {{{
keymap.map("v", "<lt>", "<lt>gv")
keymap.map("v", ">", ">gv")
-- }}}

-- Interactive replace {{{
keymap.map("n", ";;", ":.,$s~~~cg<Left><Left><Left><Left>")
-- }}}
