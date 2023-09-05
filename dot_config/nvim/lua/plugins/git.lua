local keymap = require("core.keymap")

return {
  "tpope/vim-fugitive",
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(...) keymap.map_buf(bufnr, ...) end

        map("n", "]c", function()
          vim.schedule(function() gs.next_hunk() end)
        end)
        map("n", "[c", function()
          vim.schedule(function() gs.prev_hunk() end)
        end)
        map({ "n", "v" }, "<Space>hs", ":Gitsigns stage_hunk<CR>")
        map({ "n", "v" }, "<Space>hr", ":Gitsigns reset_hunk<CR>")
        map("n", "<Space>hS", gs.stage_buffer)
        map("n", "<Space>hu", gs.undo_stage_hunk)
        map("n", "<Space>hR", gs.reset_buffer)
        map("n", "<Space>hp", gs.preview_hunk)
        map("n", "<Space>hb", function() gs.blame_line({full = true}) end)
        map("n", "<Space>tb", gs.toggle_current_line_blame)
        map("n", "<Space>hd", gs.diffthis)
        map("n", "<Space>hD", function() gs.diffthis("~") end)
        map("n", "<Space>td", gs.toggle_deleted)
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
      end,
    },
  },
}
