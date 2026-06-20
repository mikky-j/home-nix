{
  pkgs,
  inputs,
  config,
  ...
}:
{
  # In order to enable homebrew to know the primary user
  system.primaryUser = "dami";

  users.users.dami.home = "/Users/dami";
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.vim
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    interval = [
      {
        Hour = 0;
        Minute = 0;
        Weekday = 7;
      }
    ];
    options = "--delete-older-than 1w";
  };

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # vscode etc.
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.lilex
  ];

  # -- MANUALLY ADDED SETTINGS --
  # Set sudo to use touch id
  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    enable = true;
    enableZshIntegration = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    # so that nix-darwin knows about the taps nix-homebrew brings in
    taps = builtins.attrNames config.nix-homebrew.taps;
    brews = [
      "mas" # stop uninstalling it lol
    ];
    greedyCasks = true;
    casks = [
      "orbstack"
      "keepingyouawake"
      "zen"
      "cloudflare-warp"
      "lulu"
      "ghostty"
      "tailscale-app"
      "motrix"
    ];
    masApps = {
      Bitwarden = 1352778147;
      Telegram = 747648890;
    };
  };
}
