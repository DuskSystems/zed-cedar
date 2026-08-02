{
  lib,
  extension,
  runCommand,
  buildZedRustExtension,
  tree-sitter-cedar,
  tree-sitter-cedarschema,
  tree-sitter-cedarentities,
}:

buildZedRustExtension {
  inherit (extension) version;
  name = extension.id;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./Cargo.lock
      ./Cargo.toml
      ./extension.toml
      ./languages
      ./src
    ];
  };

  cargoHash = "sha256-BQiwCOovVh9OrtqHt3iJrMimc1pizO6sh9O8Pqu8Aak=";

  grammars = [
    (runCommand "zed-grammar-cedar" { } ''
      install -Dm644 ${tree-sitter-cedar.wasm}/parser.wasm $out/share/zed/grammars/cedar.wasm
    '')

    (runCommand "zed-grammar-cedarentities" { } ''
      install -Dm644 ${tree-sitter-cedarentities.wasm}/parser.wasm $out/share/zed/grammars/cedarentities.wasm
    '')

    (runCommand "zed-grammar-cedarschema" { } ''
      install -Dm644 ${tree-sitter-cedarschema.wasm}/parser.wasm $out/share/zed/grammars/cedarschema.wasm
    '')
  ];
}
