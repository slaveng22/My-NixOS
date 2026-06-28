{ pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 524288000; # 500 MB

  # Garbage collector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--keep-last 5 --delete-older-than 14d";
  };

  nix.optimise.automatic = true;

  # Allow running regular Linux libraries on NixOS
  programs.nix-ld.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      USB_AUTOSUSPEND = 1;
      RUNTIME_PM_ON_BAT = "auto";
      RUNTIME_PM_ON_AC = "on";
      PCIE_ASPM_ON_BAT = "powersave";
      NMI_WATCHDOG = 0;
      WIFI_PWR_ON_BAT = "on";
      # Battery charge thresholds — intentional, extends battery lifespan by
      # avoiding full charges. Laptop is mostly used plugged in.
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
  services.power-profiles-daemon.enable = false;

  services.thermald.enable = true;
  services.fwupd.enable = true;
  services.earlyoom.enable = true;

  zramSwap.enable = true;

  boot.kernel.sysctl."vm.swappiness" = 10;

  environment.systemPackages = with pkgs; [
    fzf
    ripgrep
    wl-clipboard
    bat
    trash-cli
    nmap
    tealdeer
    fastfetch
    python3
    neovide
    mpv
    libreoffice-fresh
    rpi-imager
    transmission_4-gtk
    thunderbird
    gnome-keyring
  ];

  environment.sessionVariables = {
    TERMINAL = "alacritty";
    NO_AT_BRIDGE = "1";
  };
}
