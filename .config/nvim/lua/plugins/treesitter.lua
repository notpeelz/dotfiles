local keymap = require("core.keymap")
local plugins = require("core.plugins")

return plugins{
  {
    "nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "query",
        "bash",
        "c",
        "cpp",
        "vala",
        "rust",
        "zig",
        "lua",
        "python",
        "vim",
        "vimdoc",
        "diff",
        "javascript",
        "typescript",
        "c_sharp",
        "java",
        "cmake",
        "nix",
        "ruby",
        "scala",
        "html",
        "sql",
        "json",
        "jsonc",
        "json5",
        "xml",
        "toml",
        "yaml",
        "jq",
        "glsl",
        "hlsl",
        "ini",
        "latex",
        "ini",
        "kdl",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["as"] = {
              query = "@scope",
              query_group = "locals",
            },
          },
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@class.outer"] = "<C-v>",
          },
          include_surrounding_whitespace = true,
        },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          scope_incremental = false,
          node_decremental = "<BS>",
        },
      },
    },
  },
  {
    "nvim-treesitter-textobjects",
    dependencies = {
      "nvim-treesitter",
    },
  },
  {
    "nvim-treesitter-context",
    lazy = false,
    dependencies = {
      "nvim-treesitter",
    },
    opts = {
      enable = true,
      line_numbers = true,
      trim_scope = "outer",
      mode = "topline",
      separator = nil,
      zindex = 20,
      on_attach = nil,
    },
    keys = {
      keymap.mapping{ "n",
        "[p",
        function(...)
          local ctx = require("treesitter-context")
          return ctx.go_to_context(...)
        end,
      },
    },
  },
}
