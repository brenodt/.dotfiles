return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        --install GO parsers
        "go",
        "gomod",
        "gowork",
        "gosum",

        --install Dart parser
        "dart",

        -- install Utility parsers
        "bash",
        "vimdoc",
        "html",
        "json",
        "lua",
        --"python",
        "query",
        "regex",
        "vim",
        "yaml",
        --"bicep",
        --"terraform",
      },
    },
  },
}
