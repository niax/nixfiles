require('nvim-treesitter.configs').setup {
  highlight = {
	  enable = false
  },
}

-- kanagawa options:
require('kanagawa').setup({
    compile = false,             -- enable compiling the colorscheme
    undercurl = false,            -- enable undercurls
    commentStyle = { italic = false },
    functionStyle = {},
    keywordStyle = { italic = false },
    statementStyle = { bold = false },
    typeStyle = {},
    transparent = false,         -- do not set background color
    dimInactive = false,         -- dim inactive window `:h hl-NormalNC`
    terminalColors = true,       -- define vim.g.terminal_color_{0,17}
    colors = {                   -- add/modify theme and palette colors
        palette = {},
        theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
    },
    overrides = function(colors) -- add/modify highlights
        return {}
    end,
    theme = "wave",              -- Load "wave" theme when 'background' option is not set
    background = {               -- map the value of 'background' option to a theme
        dark = "wave",
        light = "lotus"
    },
})

-- setup must be called before loading
vim.cmd("colorscheme kanagawa")
