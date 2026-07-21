{
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

  src = ./.;
  cargoHash = "sha256-RQV3E4e8S4HXZnEXpTNy+7o6OEs4kTNxbiiRKd0AyMU=";

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
