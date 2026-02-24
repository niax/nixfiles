{ config, pkgs, lib, ... }:
let
  # installs a vim plugin from git with a given commit
  plugin = repo: rev: pkgs.vimUtils.buildVimPlugin {
    name = "${lib.strings.sanitizeDerivationName repo}";
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      rev = rev;
    };
    doCheck = false;
  };
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
      pyright
      black
      clang-tools
      jdt-language-server
      lombok

      # Rust things
      rust-analyzer
      rustup
    ];
    plugins = with pkgs.vimPlugins; [
      # Style
      (plugin "ryanoasis/vim-devicons" "71f239af28b7214eebb60d4ea5bd040291fb7e33")
      (plugin "rebelot/kanagawa.nvim" "debe91547d7fb1eef34ce26a5106f277fbfdd109")
      (plugin "itchyny/lightline.vim" "e358557e1a9f9fc860416c8eb2e34c0404078155")

      (plugin "preservim/nerdtree" "9b465acb2745beb988eff3c1e4aa75f349738230")
      (plugin "preservim/nerdcommenter" "02a3b6455fa07b61b9440a78732f1e9b7876c991")
      (plugin "tpope/vim-fugitive" "61b51c09b7c9ce04e821f6cf76ea4f6f903e3cf4")

      # Treesitter
      (nvim-treesitter.withAllGrammars)

      # LSP/Completion
      (plugin "neovim/nvim-lspconfig" "f0c6ccf43997a1c7e9ec4aea36ffbf2ddd9f15ef")
      (plugin "hrsh7th/nvim-cmp" "b5311ab3ed9c846b585c0c15b7559be131ec4be9")
      (plugin "hrsh7th/cmp-nvim-lsp" "a8912b88ce488f411177fc8aed358b04dc246d7b")
      (plugin "hrsh7th/cmp-buffer" "b74fab3656eea9de20a9b8116afa3cfc4ec09657")
      (plugin "hrsh7th/cmp-path" "c642487086dbd9a93160e1679a1327be111cbc25")
      (plugin "hrsh7th/cmp-cmdline" "d126061b624e0af6c3a556428712dd4d4194ec6d")
      (plugin "mfussenegger/nvim-jdtls" "4d77ff02063cf88963d5cf10683ab1fd15d072de")

      # Snippets
      (plugin "hrsh7th/cmp-vsnip" "989a8a73c44e926199bfd05fa7a516d51f2d2752")
      (plugin "hrsh7th/vim-vsnip" "02a8e79295c9733434aab4e0e2b8c4b7cea9f3a9")
      (plugin "rafamadriz/friendly-snippets" "e11b09bf10706bb74e16e4c3d11b2274d62e687f")

      # Search/Ctrl-P
      (plugin "nvim-lua/popup.nvim" "b7404d35d5d3548a82149238289fa71f7f6de4ac")
      (plugin "nvim-lua/plenary.nvim" "b9fd5226c2f76c951fc8ed5923d85e4de065e509")
      (plugin "nvim-telescope/telescope.nvim" "b4da76be54691e854d3e0e02c36b0245f945c2c7")

      # Slop
      (plugin "olimorris/codecompanion.nvim" "879e0511161c59e45ff04aff2bce6bcb6b86642b") # 18.5.0
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
