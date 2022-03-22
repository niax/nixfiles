{ config, pkgs, lib, ... }: {
  programs.zsh = {
      enable = true;

      defaultKeymap = "emacs";

      history = {
        extended = true; # Save timestamps of commands in history
        expireDuplicatesFirst = true;
        ignoreDups = true;
        ignoreSpace = true;
        save = 10000;
        share = true; # Share command history between shells
        size = 50000;
      };

      initExtraFirst = ''
        if [ -e "$HOME/.zshrc-local-early" ]; then
          source "$HOME/.zshrc-local-early"
        fi
      '';

      initExtra = ''
        if [ -e "$HOME/.zshrc-local" ]; then
          source "$HOME/.zshrc-local"
        fi

        export PAGER="less -R"
      '';

      shellAliases = {
        gc = "git commit -v";
        gca = "git commit -va";
      };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = lib.concatStrings [
          "[┌─\\(](cyan)"
          "$username"
          "$hostname"
          "$shlvl"
          "[\\)─\\(](cyan)"
          "$directory"
          "[\\)](cyan)"
          "$jobs"
          "$status"
          "\n"
          "[└─\\(](cyan)"
          "$time"
          "$git_branch"
          "$git_commit"
          "$git_state"
          "$git_metrics"
          "$git_status"
          "[\\)──](cyan)"
          "$character"
      ];

      username = {
        show_always = true;
        format = "[$user]($style)@";
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname]($style)";
      };

      directory = {
        format = "[$path]($style)[$read_only]($read_only_style)";
        read_only = "";
        truncate_to_repo = false;
        truncation_length = 5;
        truncation_symbol = "…/";
      };

      jobs = {
        disabled = false;
        format = "[─\\(](cyan)[$symbol$number]($style)[\\)](cyan)";
      };

      status = {
        disabled = false;
        format = "[─\\(](cyan)[$symbol$status]($style)[\\)](cyan)";
      };

      time = {
        disabled = false;
        format = "[$time]($style)";
      };

      git_branch = {
        format = " on [$symbol$branch]($style)";
        symbol = "";
      };

      git_commit = {
        format = "[@$hash]($style)";
      };
    };
  };
}
