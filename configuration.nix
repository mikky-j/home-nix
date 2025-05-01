{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  users.users.dami.home = "/Users/dami";
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.vim
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # -- MANUALLY ADDED SETTINGS --
  # Set sudo to use touch id
  security.pam.services.sudo_local.touchIdAuth = true;

  # security.pam.services.sudo_local.text = "auth sufficient pam_tid.so.2";
}
