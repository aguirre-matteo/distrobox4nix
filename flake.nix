{
  description = "Manage your Distrobox's containers declaratively!";

  outputs = { self, ... }: {
    homeManagerModules = rec {
      distrobox4nix = import ./module.nix;
      default = distrobox4nix;
    };
    homeManagerModule = self.homeManagerModules.distrobox4nix;
  };
}
