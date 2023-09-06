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

require("lazy").setup(
  {
    { import = "plugins" },
  },
  {
    ui = {
      icons = {
        cmd = "⌘",
        config = "🛠",
        event = "📅",
        ft = "📂",
        init = "⚙",
        keys = "🗝",
        plugin = "🔌",
        runtime = "💻",
        source = "📄",
        start = "🚀",
        task = "📌",
        lazy = "💤 ",
      },
    },
    change_detection = {
      enabled = false,
    },
  }
)

-- Default indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

-- Syncs the vim continuation indentation with shiftwidth
vim.g.vim_indent_cont = vim.opt.shiftwidth

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

-- Folds {{{
vim.opt.fillchars = {
  eob = " ",
  fold = " ",
  foldsep = " ",
  foldopen = "⏷",
  foldclose = "⏵"
}
vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
-- }}}

-- Highlight on yank {{{
au.group("HighlightOnYank", {
  TextYankPost = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 250 })
  end,
})
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
au.group("AutoSignColumn", {
  BufWinEnter = function(e)
    local buftype = vim.api.nvim_buf_get_option(e.buf, "buftype")
    vim.opt.signcolumn = buftype == "" and "yes:1" or "no"
  end
})
-- }}}

-- Git commit column hint {{{
au.group("GitMessageLength", {
  FileType = {
    pattern = "gitcommit",
    function()
      vim.opt.colorcolumn = "72"
    end,
  },
})
-- }}}

-- Disable automatic line continuation of comments {{{
au.group("DisableCommentContinuation", function()
  local cmd = function()
    vim.opt.formatoptions = "cljq"
  end

  return {
    BufEnter = cmd,
    BufNewFile = cmd,
  }
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

-- Enable emacs-style navigation {{{
keymap.map({ "c", "n" }, "<C-a>", "<Home>")
keymap.map({ "c", "n" }, "<C-e>", "<End>")
-- }}}

-- Scrolling {{{
keymap.map({ "n", "x" }, "<C-d>", "<C-d>")
keymap.map({ "n", "x" }, "<C-S-d>", "<C-u>")
keymap.map({ "n", "x" }, "<C-s>", "<C-e>")
keymap.map({ "n", "x" }, "<C-S-s>", "<C-y>")
-- }}}

-- Unmap undesirable keys {{{
keymap.map("", "<C-Space>", "<nop>")
keymap.map("", "<C-S-e>", "<nop>")
keymap.map("", "<C-y>", "<nop>")
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
keymap.map("n", ";;", ":.,$s~~~cg<Left><Left><Left><Left>", { silent = false })
-- }}}
