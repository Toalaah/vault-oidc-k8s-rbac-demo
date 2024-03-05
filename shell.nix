let
  pkgs = import <nixpkgs> {config.allowUnfree = true;};
in
  pkgs.mkShell {
    buildInputs = with pkgs; [mkcert openssl vault terraform kind kubectl];
  }
