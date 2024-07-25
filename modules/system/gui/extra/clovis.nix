{ config, pkgs, ... }:

let
  owner = "paysancorrezien";
  repo = "clovis";

  # Fetch the latest commit information
  latestCommit = builtins.fetchTree {
    type = "github";
    owner = owner;
    repo = repo;
    ref = "main";
  };

  clovisSrc = pkgs.fetchFromGitHub {
    inherit owner repo;
    rev = latestCommit.rev;
    hash = latestCommit.narHash;
  };
in {
  environment.systemPackages = with pkgs;
    [
      (pkgs.rustPlatform.buildRustPackage {
        pname = "clovis";
        version = latestCommit.rev;
        src = clovisSrc;

        cargoLock = { lockFile = "${clovisSrc}/Cargo.lock"; };

        buildInputs = [ pkgs.rustc pkgs.cargo ];

        meta = {
          description =
            "Clovis: A Rust project for launching programs by profiles";
          homepage = "https://github.com/${owner}/${repo}";
          license = pkgs.lib.licenses.mit;
        };
      })
    ];
}
