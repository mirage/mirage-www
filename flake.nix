{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    opam-nix.url = "github:tweag/opam-nix";
    hillingar.url = "github:RyanGibb/hillingar";

    hillingar.inputs.opam-nix.follows = "opam-nix";

    # maintain different repositories to those pinned in upstream repositories
    opam-nix.inputs.opam-repository.follows = "opam-repository";
    hillingar.inputs.opam-repository.follows = "opam-repository";
    hillingar.inputs.opam-overlays.follows = "opam-overlays";
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };
    opam-overlays = {
      url = "github:dune-universe/opam-overlays";
      flake = false;
    };

    # follow this flake's nixpkgs
    # useful if pinning nixos system nixpkgs with
    #   `nix.registry.nixpkgs.flake = nixpkgs;`
    opam-nix.inputs.nixpkgs.follows = "nixpkgs";
    hillingar.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, opam-nix, hillingar, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        opam-nix-lib = opam-nix.lib.${system};
        query = {
          # find non-trunk version https://github.com/tweag/opam-nix/issues/35
          ocaml-base-compiler = "*";
          mirage = "4.3.3";
        };

        devPackagesQuery = {
          ocaml-lsp-server = "*";
          ocamlformat = "*";
        };
        overlay = final: prev: {
          # dream-httpaf is vendored in dream, so we don't detect dream's depdnancy on gluten and gluten's depenancy on ke
          "dream-httpaf" = prev."dream-httpaf".overrideAttrs (oa: {
            buildInputs = oa.buildInputs ++ [ prev.ke ];
          });
          # dream uses mirage-crypto-rng.wt, so we need mirage-crypto-rng.0.10.7 before lwt was split
          "dream" = prev."dream".overrideAttrs (oa: {
            buildInputs = oa.buildInputs ++ [ prev.mirage-crypto-rng ];
          });
        };
        queryForOverlay = {
          ke = "*";
          mirage-crypto-rng = "0.10.7";
        };
        scope =
          let scope = opam-nix-lib.buildOpamProject' { } ./. (query // devPackagesQuery // queryForOverlay); in
          scope.overrideScope' overlay;

        unikernelPkgs = let
          mirage-nix = (hillingar.lib.${system});
          inherit (mirage-nix) mkUnikernelPackages;
        in
          mkUnikernelPackages {
            unikernelName = "www";
            mirageDir = "mirage";
            # depexts for ocaml-gmp
            depexts = with pkgs; [ opam gnum4 ];
            monorepoQuery = {
              # isn't picked up by `opam admin list`
              gmp = "*";

              # workaround https://github.com/RyanGibb/hillingar/issues/3
              ptime = "1.0.0+dune"; # ptime 1.1.0 doesn't have an overlay
              omd = "1.3.2"; # omd.2.0.0 introduces a dependancy on non-dune uunf
            };
            inherit query;
          } self;
      in {
        packages = { inherit scope; unikernel = unikernelPkgs; };

        defaultPackage = self.packages.${system}.scope.mirageio-bin;

        devShells.default =
          let
            devPackages = builtins.attrValues
              (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope);
          in pkgs.mkShell {
            inputsFrom = [ scope.mirageio-bin ];
            buildInputs = devPackages;
          };
      }
    );
}
