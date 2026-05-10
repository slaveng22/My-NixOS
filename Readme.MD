# My NixOS — redpanda

Personal NixOS configuration for the `redpanda` host using flakes and Home Manager.

## Structure

```
.
├── flake.nix
├── hosts/
│   └── redpanda/
│       ├── default.nix
│       └── hardware-configuration.nix
├── modules/
│   ├── system/          # core, desktop, fonts, fingerprint
│   └── home/            # shell, terminal, editor, apps, zellij
├── dotfiles/            # fastfetch, oh-my-posh, yazi configs
├── pkgs/                # python-validity custom package
└── images/              # wallpapers and profile picture
```

## Install

```bash
sudo nixos-rebuild switch --flake .#redpanda
```

## Post-install

**Fingerprint (first time only)**

```bash
sudo validity-sensors-firmware   # firmware init
sudo systemctl start python3-validity
fprintd-enroll                   # enroll from multiple angles until successful
fprintd-verify                   # test
```

**GNOME tweaks**

Disable PaperWM workspace indicator (requires logout):

```bash
dconf write /org/gnome/shell/extensions/paperwm/show-workspace-indicator false
```

Bitwarden and Signal tray icons must be enabled in each app's settings.

## Updates

```bash
nix flake update          # updates flake.lock
sudo nixos-rebuild switch --flake .#redpanda
```
