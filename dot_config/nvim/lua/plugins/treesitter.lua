return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "query",
        "bash",
        "c",
        "cpp",
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
        "toml",
        "yaml",
        "jq",
        "glsl",
        "hlsl",
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
            ['@parameter.outer'] = 'v',
            ['@function.outer'] = 'V',
            ['@class.outer'] = '<C-v>',
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
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
