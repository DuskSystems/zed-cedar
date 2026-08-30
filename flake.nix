{
  description = "zed-cedar";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";

      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    zed-extensions = {
      url = "github:SwornSystems/nix-zed-extensions";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };

    tree-sitter-cedar = {
      url = "github:SwornSystems/tree-sitter-cedar";

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
            (final: _prev: {
              tree-sitter-parsers = final.linkFarm "tree-sitter-parsers" {
                "cedar.so" = "${final.tree-sitter-cedar}/parser";
                "cedarentities.so" = "${final.tree-sitter-cedarentities}/parser";
                "cedarschema.so" = "${final.tree-sitter-cedarschema}/parser";
              };

              vale-styles = final.symlinkJoin {
                name = "vale-styles";
                paths = with final.valeStyles; [
                  proselint
                  write-good
                  redhat
                ];
              };
            })
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

            # Tree Sitter
            TREE_SITTER_PARSERS = "${pkgs.tree-sitter-parsers}";

            # Vale
            VALE_STYLES_PATH = "${pkgs.vale-styles}/share/vale/styles";

            # Cargo
            CARGO_UNSTABLE_MIN_PUBLISH_AGE = "true";
          };

          buildInputs = with pkgs; [
            # Rust
            (rust-bin.nightly.latest.minimal.override {
              extensions = [
                "clippy"
                "rust-analyzer"
                "rust-src"
                "rustfmt"
              ];
            })
            cargo-deny
            cargo-outdated
            cargo-shear

            # Git
            committed

            # GitHub
            gh
            pinact
            zizmor

            # Tree Sitter
            ts_query_ls

            # Spellchecking
            typos
            typos-lsp

            # Markdown
            lychee
            vale
            vale-ls

            # TOML
            tombi

            # Nushell
            nushell
            nufmt
            nu-lint

            # Nix
            deadnix
            nil
            nixd
            nixfmt
          ];
        };

        # nix develop .#ci
        ci = pkgs.mkShell {
          name = "zed-cedar-ci-shell";

          env = {
            # Tree Sitter
            TREE_SITTER_PARSERS = "${pkgs.tree-sitter-parsers}";

            # Vale
            VALE_STYLES_PATH = "${pkgs.vale-styles}/share/vale/styles";

            # Cargo
            CARGO_UNSTABLE_MIN_PUBLISH_AGE = "true";
          };

          buildInputs = with pkgs; [
            # Rust
            (rust-bin.nightly.latest.minimal.override {
              extensions = [
                "clippy"
                "rustfmt"
              ];
            })
            cargo-deny
            cargo-shear

            # Git
            committed

            # GitHub
            zizmor

            # Tree Sitter
            ts_query_ls

            # Spellchecking
            typos

            # Markdown
            lychee
            vale

            # TOML
            tombi

            # Nushell
            nushell
            nufmt
            nu-lint

            # Nix
            deadnix
            nixfmt
          ];
        };
      });
    };
}
