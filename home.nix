{ config, pkgs, ... }:
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "dami";
  home.homeDirectory = "/Users/dami";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    neovim
    ripgrep
    zsh-completions
    zsh-autocomplete
  ];

  programs.zed-editor = {
    enable = true;
    userSettings = {
      base_keymap = "VSCode";
      vim_mode = true;
      ui_font_size = 16;
      buffer_font_size = 16;
      theme = {
        mode = "system";
        light = "One Light";
        dark = "Catppuccin Mocha";
      };
    };

  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
  };

  # todo, actual zsh things
  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    enableCompletion = false; # zsh-autocomplete wants this

    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      styles = {
        path = "fg=cyan"; # make paths blue
        path_pathseparator = "fg=cyan";
        precommand = "none"; # stop sudo underline
      };
    };

    zplug = {
      enable = true;
      plugins = [
        {
          name = "niraami/zsh-auto-notify"; # workaround for https://github.com/MichaelAquilina/zsh-auto-notify/pull/49
          tags = [ "at:f1b54479d2db1002f8823d1217509b3e29015acd" ];
        }
      ];
    };

    initContent = ''
      setopt nomatch notify interactivecomments
      # settings for marlonrichert/zsh-autocomplete
      zstyle ':autocomplete:*complete*:*' insert-unambiguous yes # insert common substring
      zstyle ':completion:*:*' matcher-list 'm:{[:lower:]-}={[:upper:]_}' '+r:|[.]=**' # use prefix as substring
      bindkey '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete # use tab/shift-tab to cycle completions

      # settings for zsh-auto-notify
      AUTO_NOTIFY_IGNORE+=("nvim" "vim" "fg")
      AUTO_NOTIFY_TITLE="\"%command\" completed"
      AUTO_NOTIFY_BODY="Total time: %elapsed seconds, Exit code: %exit_code"
    '';
  };

  programs.git = {
    enable = true;
    userName = "Oluwadamilola Oregunwa";
    userEmail = "moregunwa@gmail.com";
    aliases = {
      sw = "switch";
      st = "status";
      br = "branch";
      ci = "commit";
    };
    signing = {
      # for later
      # key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiGSjQcRY0rXoi9dRT4dZygGo8vjB/NYJXrAhnZ46NX";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICopVZhr5fvtDv1nRFd7Qu+E6Csr2fDuPHL0szM/UKmm dami@OluwadalolasAir";
      format = "ssh";
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      commit.gpgsign = true;
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };

      # gotten from https://blog.gitbutler.com/how-git-core-devs-configure-git/
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "version:refname";
      diff.algorithm = "histogram";
      diff.colorMoved = "plain";
      diff.renames = true;
      push.followTags = true;
      help.autocorrect = "prompt";
      commit.verbose = true;
      rerere.enabled = true;
      rerere.autoupdate = true;
      merge.conflictstyle = "zdiff3";
    };
  };
}
