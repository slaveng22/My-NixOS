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