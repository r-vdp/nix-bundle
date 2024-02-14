{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    bundlers = {
      nix-bundle = { program, system }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          nix-bundle = import self { nixpkgs = pkgs; };
          script = pkgs.writeScript "startup" ''
            #!/bin/sh
            .${nix-bundle.nix-user-chroot}/bin/nix-user-chroot -n ./nix -- ${program} "$@"
          '';
        in
        nix-bundle.makebootstrap {
          targets = [ script ];
          startup = ".${builtins.unsafeDiscardStringContext script} '\"$@\"'";
        };
    };

    defaultBundler = self.bundlers.nix-bundle;
  };
}
