{
  description = "zed-cedar";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";

      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    zed-extensions = {
      url = "github:DuskSystems/nix-zed-extensions";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };

    tree-sitter-cedar = {
      url = "github:DuskSystems/tree-sitter-cedar";

      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  # nix flake show
  outputs =
    {
      self,
      nixpkgs,
      zed-extensions,
      tree-sitter-cedar,
      ...
    }:

    let
      perSystem = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;

      systemPkgs = perSystem (
        system:

        import nixpkgs {
          inherit system;

          overlays = [
            self.overlays.default
          ];
        }
      );

      perSystemPkgs = f: perSystem (system: f (systemPkgs.${system}));
      extension = fromTOML (builtins.readFile ./extension.toml);
    in
    {
      overlays = {
        default = nixpkgs.lib.composeManyExtensions [
          tree-sitter-cedar.overlays.default
          zed-extensions.overlays.default

          (_final: prev: {
            zed-cedar = prev.callPackage ./package.nix { inherit extension; };
          })
        ];
      };

      packages = perSystemPkgs (pkgs: {
        default = pkgs.zed-cedar;
        zed-cedar = pkgs.zed-cedar;
      });

      devShells = perSystemPkgs (pkgs: {
        # nix develop
        default = pkgs.mkShell {
          name = "zed-cedar-shell";

          env = {
            # Nix
            NIX_PATH = "nixpkgs=${nixpkgs.outPath}";
          };

          buildInputs = with pkgs; [
            # Rust
            (rust-bin.stable.latest.minimal.override {
              extensions = [
                "clippy"
                "rust-analyzer"
                "rust-src"
                "rustfmt"
              ];
            })

            # Nix
            deadnix
            nil
            nixd
            nixfmt

            # Tree Sitter
            ts_query_ls

            # Spellchecking
            typos
            typos-lsp

            # TOML
            tombi

            # GitHub
            zizmor
          ];
        };
      });
    };
}
