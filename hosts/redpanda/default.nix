{ ... }:

{
  imports = [
    ./../../hardware-configuration.nix
    ./../../modules/system/core.nix
    ./../../modules/system/desktop.nix
    ./../../modules/system/fonts.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "redpanda";
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  time.timeZone = "Europe/Belgrade";
  i18n.defaultLocale = "en_US.UTF-8";

  powerManagement.cpuFreqGovernor = "schedutil";

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  users.users.slaven = {
    isNormalUser = true;
    description = "Slaven Gugolj";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.11";
}
