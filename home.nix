{ pkgs, ... }:
let
  # ssh only ever sees the host, never the repo path, so per-group gitlab keys have to be
  # chosen by git. gitlab logs in as whichever account owns the first key it accepts, so only
  # `pubKey` may be offered: -F /dev/null drops ~/.ssh/config, whose gitlab.com IdentityFile
  # would be tried before -i, and IdentitiesOnly stops the agent offering its other keys.
  sshWithKey = pubKey: "ssh -F /dev/null -o IdentitiesOnly=yes -i ${pubKey}";

  # Work identity, applied only to gitlab.com/luminovo repos (see programs.git.includes
  # below). The default identity in programs.git.settings stays personal, covering github,
  # personal gitlab.com repos, and everything else.
  luminovoIdentity = {
    user.email = "oluwadamilola.oregunwa@luminovo.com";
    credential.username = "oluwadamilola.oregunwa";
    core.sshCommand = sshWithKey "~/.ssh/luminovo-gitlab.pub";
  };
  servloopeIdentity = {
    user.email = "moregunwa@gmail.com";
    credential.username = "mikky-j";
    core.sshCommand = sshWithKey "~/.ssh/servloope.pub";
  };

  # Every stored form a gitlab.com remote under `group` can take, scoped to that group so
  # other gitlab.com repos are left alone. Verified against git 2.54's includeIf `hasconfig`
  # globbing: the literal `<group>/` segment plus `/**` matches every repo nested under the
  # group (and correctly rejects e.g. `luminovo-personal/...`).
  gitlabGroupIncludes =
    group: contents:
    map
      (pat: {
        condition = "hasconfig:remote.*.url:${pat}";
        inherit contents;
      })
      [
        "git@gitlab.com:${group}/**"
        "ssh://git@gitlab.com/${group}/**"
        "https://gitlab.com/${group}/**"
        "gl:${group}/**"
      ];
in
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
  home.stateVersion = "26.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    neovim
    ripgrep
    zsh-completions
    libnotify
    nixd
    nil
    gh
    dbeaver-bin
    yaak
    spotify
    opencode
    glab
  ];

  # Enable fonts
  # fonts.fontconfig.enable = true; we're using nix-darwin for fonts so that they're shared among users

  # DirEnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Atuin
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      dialect = "uk";
      inline_height = 0;
      style = "auto";
      enter_accept = false;
      sync = {
        records = true;
      };
    };
  };

  # Zed
  programs.zed-editor = {
    enable = true;
    package = null;
    extensions = [
      "nix"
      "catppuccin"
    ];
    userSettings = {
      agent_servers = {
        cursor = {
          default_config_options = {
            mode = "agent";
            model = "default[]";
          };
          type = "registry";
        };
      };
      project_panel = {
        dock = "left";
      };
      outline_panel = {
        dock = "left";
      };
      collaboration_panel = {
        dock = "left";
      };
      git_panel = {
        dock = "left";
      };
      agent = {
        dock = "right";
        default_profile = "ask";
        inline_assistant_model = {
          provider = "zed.dev";
          model = "claude-sonnet-4-thinking";
        };
        model_parameters = [ ];
        default_model = {
          provider = "zed.dev";
          model = "claude-sonnet-4-thinking";
        };
      };
      base_keymap = "VSCode";
      diagnostics = {
        inline = {
          enabled = true;
        };
      };
      languages = {
        TSX = {
          show_edit_predictions = false;
        };
        Nix = {
          show_edit_predictions = false;
        };
      };
      restore_on_startup = "none";
      theme = {
        dark = "Catppuccin Mocha";
        light = "One Light";
        mode = "system";
      };
      ui_font_size = 16;
      vim_mode = true;

      buffer_font_size = 16;
      buffer_font_family = "FiraCode Nerd Font Mono";

      diff_view_style = "unified";

      terminal.blinking = "on";
      terminal.font_family = "Lilex Nerd Font Mono";
      terminal.option_as_meta = true;

      which_key.enabled = true;
      which_key.delay_ms = 0;
    };
    userKeymaps = [
      # tab to cycle through completions: https://github.com/zed-industries/zed/discussions/11474
      {
        context = "Editor && showing_completions";
        bindings = {
          tab = "editor::ContextMenuNext";
          shift-tab = "editor::ContextMenuPrevious";
        };
      }
      {
        context = "Editor && vim_mode == insert";
        bindings = {
          "j k" = "vim::NormalBefore";
        };
      }
    ];
  };

  # SSH
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    includes = [
      "~/.orbstack/ssh/config"
      "~/.ssh/luminovo.config"
    ];

    settings = {
      "github.com".IdentityFile = "~/.ssh/github.pub";
      "gitlab.com".IdentityFile = "~/.ssh/luminovo-gitlab.pub";
      "codeberg.org".IdentityFile = "~/.ssh/codeberg.pub";
    };

  };

  # Starship
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      command_timeout = 1000;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✖](bold red)";
      };
      hostname = {
        ssh_only = false;
        format = "[$hostname](bold green): ";
      };
      username = {
        show_always = true;
        format = "[$user](bold #c09bf6)[@](bold yellow)";
      };
    };
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

    plugins = [
      {
        # workaround for https://github.com/marlonrichert/zsh-autocomplete/issues/857
        name = "zsh-autocomplete";
        src = pkgs.fetchFromGitHub {
          owner = "SaeGon-Heo";
          repo = "zsh-autocomplete";
          rev = "0c321a7cfaeb3eccbaee3ada1a82c8651cec7f54";
          hash = "sha256-MUXbgiTBoZWNULl4A0Qgl1IR5nsvB7iK0vT5wQYw1Is=";
        };
      }
      {
        # workaround for https://github.com/MichaelAquilina/zsh-auto-notify/pull/49
        name = "auto-notify";
        src = pkgs.fetchFromGitHub {
          owner = "niraami";
          repo = "zsh-auto-notify";
          rev = "f1b54479d2db1002f8823d1217509b3e29015acd";
          hash = "sha256-17w+I74Cgo9n73gZvVRNO2sWEcbbEH/TnyaIJJxEG8M=";
        };
      }
      {
        # from https://github.com/direnv/direnv/issues/443#issuecomment-2380714786
        #
        # tried updating to 7f0a68e5fa8081554161d0d330d7f2a52683705e but some of the new settings
        # made zsh-autocomplete fail with `command not found: _autocomplete__unambiguous` and
        # `command not found: _autocomplete__should_add_space` when `ls *.typ` in ~/Downloads
        # todo: look into the new settings anf fix i guess?
        name = "zsh-completion-sync";
        src = pkgs.fetchFromGitHub {
          owner = "BronzeDeer";
          repo = "zsh-completion-sync";
          rev = "f6e95baf8cd87d9065516d1fa0bf0cb33b4235f3";
          hash = "sha256-XhZ7l8e2H1+W1oUkDrr8pQVPVbb3+1/wuu7MgXsTs+8=";
        };
      }
    ];

    initContent = ''
      setopt nomatch notify interactivecomments

      bindkey '^[[3~' delete-char

      # settings for zsh-auto-notify
      AUTO_NOTIFY_IGNORE+=("nvim" "vim" "nano" "fg")
      AUTO_NOTIFY_URGENCY_ON_ERROR="normal"
      AUTO_NOTIFY_TITLE="\"%command\" completed"
      AUTO_NOTIFY_BODY="Total time: %elapsed seconds, Exit code: %exit_code"

      # settings for marlonrichert/zsh-autocomplete
      zstyle ':autocomplete:*complete*:*' insert-unambiguous yes # insert common substring
      zstyle ':completion:*:*' matcher-list 'm:{[:lower:]-}={[:upper:]_}' '+r:|[.]=**' # use prefix as substring
      bindkey '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete # use tab/shift-tab to cycle completions

      # this is slow and sad :(
      # but you gotta do what you gotta do for those completions
      reload_autocomplete_and_atuin() {
        source $HOME/.zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

        # settings for marlonrichert/zsh-autocomplete
        zstyle ':autocomplete:*complete*:*' insert-unambiguous yes # insert common substring
        zstyle ':completion:*:*' matcher-list 'm:{[:lower:]-}={[:upper:]_}' '+r:|[.]=**' # use prefix as substring
        bindkey '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete # use tab/shift-tab to cycle completions

        eval "$(${pkgs.atuin}/bin/atuin init zsh)"
      }

      # settings for zsh-completion-sync
      zstyle ':completion-sync:compinit:custom' enabled true
      zstyle ':completion-sync:compinit:custom' command reload_autocomplete_and_atuin
    '';
  };

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
    settings = {
      shell-integration-features = true;
    };
  };

  # Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Oluwadamilola Oregunwa";
        email = "moregunwa@gmail.com";
      };
      alias = {
        sw = "switch";
        st = "status";
        br = "branch";
        ci = "commit";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      commit.gpgsign = true;
      url = {
        "ssh://git@github.com/" = {
          insteadOf = [
            "https://github.com/"
            "gh:"
          ];
        };
        "ssh://git@gitlab.com/" = {
          insteadOf = [
            "https://gitlab.com/"
            "gl:"
          ];
        };
        "ssh://git@codeberg.org/" = {
          insteadOf = [
            "https://codeberg.org/"
            "co:"
          ];
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
    # Conditional identity per gitlab group (email, username, ssh key). home-manager renders
    # includes after `settings`, so these win over the personal defaults above.
    includes =
      gitlabGroupIncludes "luminovo" luminovoIdentity
      ++ gitlabGroupIncludes "servloope" servloopeIdentity;
    lfs = {
      enable = true;
    };
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1c2DEN/PVsaAxpBJVh8b7xdEg2iLRU9uZkdAAZcc5p";
      format = "ssh";
    };

  };

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock";
    EDITOR = "vim";
  };

  home.file = {
    ".ssh/github.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1c2DEN/PVsaAxpBJVh8b7xdEg2iLRU9uZkdAAZcc5p";
    ".ssh/luminovo-gitlab.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAWjBHedGLBALrMyPiBzjeKc6tfk5JVhWqS0vjolOxW2";
    ".ssh/codeberg.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1c2DEN/PVsaAxpBJVh8b7xdEg2iLRU9uZkdAAZcc5p";
    ".ssh/servloope.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF1c2DEN/PVsaAxpBJVh8b7xdEg2iLRU9uZkdAAZcc5p";
    ".ssh/luminovo.pub".text =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID3Cr86sPZv4KahpviCiwzVJ7virBRXVunQ09kcZ08f+";
  };
}
