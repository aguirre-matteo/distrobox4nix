# Distrobox on Nix

![logo](./logo.png)

## What is this?

This repository offers a Home-Manager module for configurating
your [Distrobox's](https://github.com/89luca89/distrobox) containers declaratively.

## General notes

Since containers cannot be built during Home-Manager's config evaluation,
because no container backend is available, this module also provides a
Systemd Unit that looks for changes after switching the config and at boot time.

There's already an open pull request for merging this module. [#6528](https://github.com/nix-community/home-manager/pull/6528)

# Installation

This guide assumes you have flakes enabled on your NixOS or Nix config.

## First step

Add this flake as an input in your `flake.nix` that contains your NixOS configuration.

```flake.nix 
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ...
    distrobox4nix.url = "github:aguirre-matteo/distrobox4nix";
  };
}
```
The provided Home-Manager module can be found at `inputs.distrobox4nix.homeManagerModule`.

## Second step

Add the module to Home-Manager's `sharedModules` list.

```flake.nix
outputs = { self, nixpkgs, home-manager, ... }@inputs: {
  nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
    modules = [
      ./configuration.nix
      ./hardware-configuration.nix 
      
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExntesion = "bkp";

          sharedModules = [
            inputs.distrobox4nix.homeManagerModule       # <--- this will enable the module
          ];

          user.yourUserName = import ./path/to/home.nix
        };
      }
    ]; 
  };
};
```

# Configuration

The following options are available at `programs.distrobox`:

`enable`

Whatever to enable or not Distrobox. Default: false

`package`

The Distrobox package will be used. This option is usefull when
overriding the original package. Default: `pkgs.distrobox`

`containers`

A set of containers and all its respective configurations. Each option can be either a
bool, a string or a list of strings. If passed a list, the option will be repeated for each
element. See `common-debian` in the [example config](#example-config). All the available options
for the containers can be found in the [distrobox-assemble documentation](https://github.com/89luca89/distrobox/blob/main/docs/usage/distrobox-assemble.md). Default: {} 

## Example config 

```home.nix
{
  programs.distrobox = {
    enable = true;
    containers = {

      python-project = {
        image = "fedora:40";
        additional_packages = "python3 git";
        init_hooks = "pip3 install numpy pandas torch torchvision";
      };

      common-debian = {
        image = "debian:13";
        entry = true;
        additional_packages = "git";
        init_hooks = [
          "ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker"
          "ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker-compose"
        ];
      };

      office = {
        clone = "common-debian";
        additional_packages = "libreoffice onlyoffice";
        entry = true;
      };

      random-things = {
        clone = "common-debian";
        entry = false;
      };

    };
  };
}
```


