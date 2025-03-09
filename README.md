# Distrobox on Nix

![logo](./logo.png)

## What is this?

This repository offers a Home-Manager module for configurating
your [Distrobox's](https://github.com/89luca89/distrobox) containers declaratively.

## General notes

Since containers cannot be built during Home-Manager's config evaluation,
because no container backend (like Docker or Podman) is available, this 
module also provides a Shell integration that prompts the user to build
the containers if some changes are detected.

This works storing the sha256sum of the `containers.ini` file, and comparing
it with the current file.

There's already an open pull request for merging this module. [#6528](https://github.com/nix-community/home-manager/pull/6528)

### Supported Shells

- Bash ✅
- Zsh ✅
- Fish ✅
- Nushell ✅

# Installation

## Flakes

### First step

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

### Second step

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

## Traditional

The best (or at least the easier) way to install the module without using flakes
is manually downloading `module.nix`.

```shell
curl https://github.com/aguirre-matteo/distrobox4nix/blob/<hash>/README.md
```

And importing it in our `configuration.nix` file. 

```configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./path/to/module.nix
  ];
  # ...
}
```

# Configuration

The following options are available at `programs.distrobox`:

`enable`

Whatever to enable or not Distrobox. Default: false

`package`

The Distrobox package will be used. This option is usefull when
overriding the original package. Default: `pkgs.distrobox`

`containers`

A set of containers (sets) and all its respective configurations. All the available options for each container 
can be found in the [distrobox-assemble documentation](https://github.com/89luca89/distrobox/blob/main/docs/usage/distrobox-assemble.md). Default: {} 

`enableBashIntegration`

Whatever to enable or not the Bash integration. Default: true

`enableZshIntegration`

Whatever to enable or not the Zsh integration. Default: true

`enableFishIntegration`

Whatever to enable or not the Fish integration. Default: true

`enableNushellIntegration`

Whatever to enable or not the Nushell integration. Default: true

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
        additional_packages = "git";
        entry = false;
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


