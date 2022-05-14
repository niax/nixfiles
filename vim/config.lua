require('nvim-treesitter.configs').setup {
  -- "all", "maintained" or a list
  ensure_installed = {
    "bash",
    "c", "cpp",
    "go", "gomod",
    "css", "html", "javascript", "json", "tsx",
    "java", "kotlin",
    "dockerfile", "nix", "yaml",
    "cmake", "ninja",
    "perl", "python", "ruby",
    "rust",
    "lua", "vim",
  },
  sync_install = "false",
  highlight = {
	  enable = false
  },
}
