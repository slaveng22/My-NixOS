- Backup original config

```bash
sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.BAK
sudo mv /etc/nixos/hardware-configuration.nix /etc/nixos/hardware-configuration.nix.BAK
```

- Symlink configs

```bash
sudo ln -s $(pwd)/configuration.nix /etc/nixos/configuration.nix
sudo ln -s $(pwd)/hardware-configuration.nix /etc/nixos/hardware-configuration.nix
``` 

- Bitwarden and Signal desktop tray should be configured in app settings itslef

- Disable workspace indiator in PaperWM (requires logout)

```bash
dconf write /org/gnome/shell/extensions/paperwm/show-workspace-indicator false
```

- Allow unstable channel for Nix

```bash
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --update
```