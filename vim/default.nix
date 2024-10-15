{ config, pkgs, lib, ... }:
let
  # installs a vim plugin from git with a given commit
  plugin = repo: rev: pkgs.vimUtils.buildVimPlugin {
    name = "${lib.strings.sanitizeDerivationName repo}";
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      rev = rev;
    };
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
      (plugin "rebelot/kanagawa.nvim" "08ed29989834f5f2606cb1ef9d5b24c5ea7b8fa5")
      (plugin "itchyny/lightline.vim" "58c97bc21c6f657d3babdd4eefce7593e30e75ce")

      (plugin "preservim/nerdtree" "fbb71fcd90602e3ec77f40b864b5f9b437c496c5")
      (plugin "preservim/nerdcommenter" "7bb1f72e802a80e37bdda5f6906c69b5a93de1eb")
      (plugin "tpope/vim-fugitive" "4f59455d2388e113bd510e85b310d15b9228ca0d")

      # Treesitter
      (nvim-treesitter.withAllGrammars)

      # LSP/Completion
      (plugin "neovim/nvim-lspconfig" "74e14808cdb15e625449027019406e1ff6dda020")
      (plugin "hrsh7th/cmp-nvim-lsp" "39e2eda76828d88b773cc27a3f61d2ad782c922d")
      (plugin "hrsh7th/cmp-buffer" "3022dbc9166796b644a841a02de8dd1cc1d311fa")
      (plugin "hrsh7th/cmp-path" "91ff86cd9c29299a64f968ebb45846c485725f23")
      (plugin "hrsh7th/cmp-cmdline" "d250c63aa13ead745e3a40f61fdd3470efde3923")
      (plugin "hrsh7th/nvim-cmp" "5260e5e8ecadaf13e6b82cf867a909f54e15fd07")
      (plugin "mfussenegger/nvim-jdtls" "ad5ab1c9246caa9e2c69a7c13d2be9901b5c02aa")

      # Snippets
      (plugin "hrsh7th/cmp-vsnip" "989a8a73c44e926199bfd05fa7a516d51f2d2752")
      (plugin "hrsh7th/vim-vsnip" "02a8e79295c9733434aab4e0e2b8c4b7cea9f3a9")
      (plugin "rafamadriz/friendly-snippets" "e11b09bf10706bb74e16e4c3d11b2274d62e687f")

      # Search/Ctrl-P
      (plugin "nvim-lua/popup.nvim" "b7404d35d5d3548a82149238289fa71f7f6de4ac")
      (plugin "nvim-lua/plenary.nvim" "a3e3bc82a3f95c5ed0d7201546d5d2c19b20d683")
      (plugin "nvim-telescope/telescope.nvim" "dfa230be84a044e7f546a6c2b0a403c739732b86")

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
