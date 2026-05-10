{ config, pkgs, lib, self, ... }:

let
  python-validity = pkgs.callPackage (self + /pkgs/python-validity.nix) {};
  factory-reset = pkgs.writeShellScriptBin "validity-factory-reset" ''
    INTERP=$(head -1 ${python-validity}/lib/python-validity/.dbus-service-wrapped | tr -d '#!')
    SITEPKGS=$(grep -o "'/nix/store[^']*site-packages'" ${python-validity}/lib/python-validity/.dbus-service-wrapped | tr -d "'" | tr '\n' ':')
    exec sudo PYTHONPATH=$SITEPKGS $INTERP ${python-validity}/share/python-validity/playground/factory-reset.py
  '';
in {
  environment.systemPackages = [ pkgs.open-fprintd pkgs.fprintd pkgs.innoextract python-validity factory-reset ];

  systemd.packages = [ pkgs.open-fprintd python-validity ];

  services.dbus.packages = [ pkgs.open-fprintd python-validity ];

  systemd.services.open-fprintd.wantedBy = [ "multi-user.target" ];
  systemd.services.python3-validity.wantedBy = [ "multi-user.target" ];

  security.pam.services = {
    sudo.fprintAuth = true;
    gnome-screensaver.fprintAuth = true;
  };
}
