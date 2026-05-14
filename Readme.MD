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

- Disable PaperWM workspace indicator (requires logout):

```bash
dconf write /org/gnome/shell/extensions/paperwm/show-workspace-indicator false
```
**LUKS TPM 2.0 unlock enroll**


```bash
sudo systemd-cryptenroll \
    --tpm2-device=auto \
    --tpm2-pcrs=0+7 \
    /dev/disk/by-uuid/9480f720-39f1-4bc5-9807-34f3c9ace63b
```

- Bitwarden and Signal tray icons must be enabled in each app's settings.

## Updates

```bash
nix flake update          # updates flake.lock
sudo nixos-rebuild switch --flake .#redpanda
```
