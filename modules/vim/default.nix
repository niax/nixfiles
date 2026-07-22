{ config, pkgs, lib, ... }:
let
  plugin = repoPath: rev: sha256:
    let
      parts = lib.strings.splitString "/" repoPath;
      owner = builtins.elemAt parts 0;
      repoName = builtins.elemAt parts 1;
    in
    pkgs.vimUtils.buildVimPlugin {
      name = lib.strings.sanitizeDerivationName repoPath;
      src = pkgs.fetchFromGitHub {
        inherit owner rev sha256;
        repo = repoName;
      };
      doCheck = false;
    };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withPython3 = true;
    withNodeJs = true;
    withRuby = true;

    extraPackages = with pkgs; [
      tree-sitter

      # Language servers
      vim-language-server
      gopls
      typescript
      typescript-language-server
      pyright
      black
      clang-tools
      jdt-language-server
      lombok
      nil

      # Rust things
      rust-analyzer
    ];
    plugins = with pkgs.vimPlugins; [
      # Style
      (plugin "ryanoasis/vim-devicons" "71f239af28b7214eebb60d4ea5bd040291fb7e33" "0kshppxgi63wn96a8h9zv7drwqcbljin5jhszh8q7pqw2xsd83gn")
      (plugin "nvim-tree/nvim-web-devicons" "0ca28b61a04fe7426cefbdd52c2647ef0e335b5f" "0lfbbqz7wsjzhxy7icychppb0299dy3jv7rmbvn1mcvqa6mv7w4q")
      (plugin "rebelot/kanagawa.nvim" "debe91547d7fb1eef34ce26a5106f277fbfdd109" "02108bvbrd1a4n6kip7qk1xfzrg789cyd8xz4pi58400zr6j37lb")
      (plugin "itchyny/lightline.vim" "e358557e1a9f9fc860416c8eb2e34c0404078155" "07d61nd3k4gmfxa8j17imlwakgj1iw485w880bjfdms347jaklvc")

      (plugin "preservim/nerdtree" "9b465acb2745beb988eff3c1e4aa75f349738230" "1j9b7f1b1pdb2v7z0b4mnfvcir4z1ycs3l2xh4rvrl7gzhlc56y5")
      (plugin "preservim/nerdcommenter" "02a3b6455fa07b61b9440a78732f1e9b7876c991" "0sx0xbn6qwm6pj3w9ny9f2ksjxwwlchbkxypk842q21dr146shlb")
      (plugin "tpope/vim-fugitive" "61b51c09b7c9ce04e821f6cf76ea4f6f903e3cf4" "1fk02wb2g52lqxxp1gx551bbv7nmambwjiqfgcp4ypn2n4wnhzxv")

      # Treesitter
      (nvim-treesitter.withAllGrammars)

      # LSP/Completion
      (plugin "neovim/nvim-lspconfig" "f0c6ccf43997a1c7e9ec4aea36ffbf2ddd9f15ef" "11pl7fw16nx5mm6dj8c41wp1sls58ls0b3s6vqk5g4qm59vlpx58")
      (plugin "hrsh7th/nvim-cmp" "b5311ab3ed9c846b585c0c15b7559be131ec4be9" "07674djcyac9wlj08y9p5gsmdpsm8zxjfgk3fwyvvx8j7qyzx74p")
      (plugin "hrsh7th/cmp-nvim-lsp" "a8912b88ce488f411177fc8aed358b04dc246d7b" "08q5mf5jrqjjcl1s4h9zj2vd1kcizz0a5a6p65wv1rc5s1fa3a49")
      (plugin "hrsh7th/cmp-buffer" "b74fab3656eea9de20a9b8116afa3cfc4ec09657" "1cwx8ky74633y0bmqmvq1lqzmphadnhzmhzkddl3hpb7rgn18vkl")
      (plugin "hrsh7th/cmp-path" "c642487086dbd9a93160e1679a1327be111cbc25" "0p6rc6bv68qz0pd200f8ayg8313sjik4rsc6d9xllyjn5pdmv13v")
      (plugin "hrsh7th/cmp-cmdline" "d126061b624e0af6c3a556428712dd4d4194ec6d" "0f47h8rm6s5awcmy640gx3xww580b011z6v6h65iqpgbbm3z0lf3")
      (plugin "mfussenegger/nvim-jdtls" "4d77ff02063cf88963d5cf10683ab1fd15d072de" "16sdq2ymrdnbm8667yairfji3md0w6c34qhssgahwb867185akzl")

      # Snippets
      (plugin "hrsh7th/cmp-vsnip" "989a8a73c44e926199bfd05fa7a516d51f2d2752" "1hs1gv7q0vfn82pwdwpy46nsi4n5z6yljnzl0rpvwfp8g79hssfs")
      (plugin "hrsh7th/vim-vsnip" "02a8e79295c9733434aab4e0e2b8c4b7cea9f3a9" "06j0fph91x3gdhbf9bb0yv95j34gf827p97vak0l4jb0ib7vmyc2")
      (plugin "rafamadriz/friendly-snippets" "e11b09bf10706bb74e16e4c3d11b2274d62e687f" "0d0f2slxi2j1y4l8swzhgwba10w9y835nff1ml14pdfqr0nmhw66")

      # Search/Ctrl-P
      (plugin "folke/snacks.nvim" "882c996cf28183f4d63640de0b4c02ec886d01f2" "14hhnbivyqmvkj42iccjlqq6484s7i0bmazpcxq976974y61fkc1")
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
