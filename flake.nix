{

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, flake-utils
  }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system;
    };

    python-env = pkgs.python312.withPackages (ps: with ps; [pandas geopandas]);


    our-poetry = pkgs.writeShellScriptBin "poetry" ''
      # Wrap in libraries expected by numpy etc
      export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
      export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.zlib ]}:$LD_LIBRARY_PATH"
      exec ${pkgs.poetry}/bin/poetry $@
    '';


  in {
    packages = { };

    devShell =  pkgs.mkShell {
      buildInputs = with pkgs; [
        bashInteractive
        pkg-config
        openssl
        clang
        rustup
        rustc
        cargo
        uv
        python-env
        our-poetry
      ] ++ lib.optionals (stdenv.isDarwin) [
        darwin.apple_sdk.frameworks.CoreServices # needed for all?
        zlib
        hdf5
      ]
      ;
      shellHook = ''
        poetry shell
      '';
    };
  }
  );
}
