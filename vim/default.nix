{ config, pkgs, lib, ... }:
let
  # installs a vim plugin from git with a given tag / branch
  pluginGit = ref: repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
    };
  };
  # always installs latest version
  plugin = pluginGit "HEAD";
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withPython3 = true;
    withRuby = true;
    withNodeJs = true;

    extraPackages = with pkgs; [
      tree-sitter

      # Language servers
      nodePackages.vim-language-server
      gopls
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.pyright
      black
      clang-tools
      jdt-language-server
      lombok
    ];
    plugins = with pkgs.vimPlugins; [
      # Style
      (plugin "ryanoasis/vim-devicons")
      (plugin "altercation/vim-colors-solarized")
      (plugin "itchyny/lightline.vim")

      (plugin "preservim/nerdtree")
      (plugin "preservim/nerdcommenter")
      (plugin "tpope/vim-fugitive")

      (nvim-treesitter.withPlugins (
        plugins: with plugins; [
          tree-sitter-bash
          tree-sitter-c
          tree-sitter-cpp
          tree-sitter-go
          tree-sitter-gomod
          tree-sitter-css
          tree-sitter-html
          tree-sitter-javascript
          tree-sitter-json
          tree-sitter-tsx
          tree-sitter-java
          tree-sitter-kotlin
          tree-sitter-dockerfile
          tree-sitter-nix
          tree-sitter-yaml
          tree-sitter-cmake
          tree-sitter-perl
          tree-sitter-python
          tree-sitter-ruby
          tree-sitter-rust
          tree-sitter-lua
          tree-sitter-vim
        ]
      ))

      # LSP/Completion
      (plugin "neovim/nvim-lspconfig")
      (plugin "hrsh7th/cmp-nvim-lsp")
      (plugin "hrsh7th/cmp-buffer")
      (plugin "hrsh7th/cmp-path")
      (plugin "hrsh7th/cmp-cmdline")
      (plugin "hrsh7th/nvim-cmp")
      (plugin "mfussenegger/nvim-jdtls")

      # Snippets
      (plugin "hrsh7th/cmp-vsnip")
      (plugin "hrsh7th/vim-vsnip")
      (plugin "rafamadriz/friendly-snippets")

      # Search/Ctrl-P
      (plugin "nvim-lua/popup.nvim")
      (plugin "nvim-lua/plenary.nvim")
      (plugin "nvim-telescope/telescope.nvim")

    ];

    extraConfig = builtins.concatStringsSep "\n" [
      (lib.strings.fileContents ./base.vim)
      (lib.strings.fileContents ./plugins.vim)
      (lib.strings.fileContents ./ft.vim)

      ''
        lua << EOF
        ${lib.strings.fileContents ./config.lua}
        ${lib.replaceStrings ["@openjdk@" "@jdt-language-server@" "@lombok-root@"] ["${pkgs.openjdk}" "${pkgs.jdt-language-server}" "${pkgs.lombok}"] (lib.strings.fileContents ./lsp.lua)}
        EOF
      ''
    ];
  };
}
