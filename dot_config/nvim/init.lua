-- vim:foldmethod=marker
-- Install lazy.nvim
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

-- Floating term {{{
do
  local function percentbbox(h, w)
    local row, col, height, width
    if h <= 1 then
      row = math.floor(vim.o.lines / 2 * (1 - h)) - 1
      height = math.floor(vim.o.lines * h)
    else
      row = math.floor(vim.o.lines / 2 - h / 2) - 1
      height = h
    end

    if w <= 1 then
      col = math.floor(vim.o.columns / 2 * (1 - w))
      width = math.floor(vim.o.columns * w)
    else
      col = math.floor(vim.o.columns / 2 - w / 2)
      width = w
    end
    return row, col, height, width
  end

  local instance = {}
  function get_or_create_term_buf()
    if instance.bufnr == nil then
      assert(instance.winid == nil, "terminal window wasn't cleaned up properly")
      assert(instance.termid == nil, "terminal job wasn't cleaned up properly")

      local bufnr = vim.api.nvim_create_buf(true, false)
      local termid = vim.api.nvim_buf_call(bufnr, function()
        vim.fn.termopen({ vim.o.shell, "-l" }, {
          detach = 1,
          on_exit = function()
            instance.termid = nil
            if instance == nil then
              return
            end

            if instance.winid ~= nil
              and instance.bufnr ~= nil
              and vim.api.nvim_win_get_buf(instance.winid) == instance.bufnr
            then
              vim.api.nvim_win_close(instance.winid, true)
              instance.winid = nil
            end

            if instance.bufnr ~= nil then
              vim.api.nvim_buf_delete(instance.bufnr, {
                force = true,
              })
              instance.bufnr = nil
            end
          end,
        })
      end)

      instance = {
        bufnr = bufnr,
      }
    end
    return instance.bufnr
  end

  au.group("FloatTerm", {
    BufDelete = function(e)
      if instance.bufnr == nil then
        return
      end
      local bufnr = tonumber(e.buf)
      if bufnr == instance.bufnr then
        instance.bufnr = nil
      end
    end,
    WinClosed = function()
      if instance.winid == nil then
        return
      end

      if not vim.api.nvim_win_is_valid(instance.winid) then
        instance.winid = nil
      end
    end,
    WinLeave = function()
      local winid = vim.api.nvim_get_current_win()
      if instance.winid == nil then
        return
      end

      if winid == instance.winid then
        vim.api.nvim_win_close(instance.winid, true)
        instance.winid = nil
      end
    end,
  })

  keymap.map({ "", "t" }, "<C-t>", function()
    local bufnr = get_or_create_term_buf()
    if instance.winid ~= nil then
      vim.api.nvim_win_close(instance.winid, true)
      instance.winid = nil
    else
      local row, col, height, width = percentbbox(0.8, 0.8)
      instance.winid = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        focusable = true,
        style = "minimal",
        border = "rounded",
      })
      vim.api.nvim_set_option_value(
        "winhighlight",
        "FloatBorder:TelescopePromptBorder,NormalFloat:Normal",
        { win = instance.winid }
      )
      vim.cmd.startinsert{ bang = true }
    end
  end)
end
-- }}}

-- Synchronize shell working directory on exit {{{
au.group("UpdateParentShellPwd", {
  ExitPre = function(e)
    pcall(function()
      local new_pwd_path = os.getenv("NVIM_SHELL_PWD_PATH")
      if new_pwd_path == nil then
        return
      end

      local f = io.open(new_pwd_path, "w")
      f:write(vim.loop.cwd())
      f:close()
    end)
  end
})
-- }}}
