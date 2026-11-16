{
  description = "tmux with Kitty keyboard protocol support (PR #5615)";

  # PR: https://github.com/tmux/tmux/pull/5615
  # Patch: https://github.com/tmux/tmux/pull/5615.patch
  # The patch does not apply to tmux 3.8, so build the PR head instead.
  inputs.nixpkgs.url = "flake:nixpkgs";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = pkgs.tmux.overrideAttrs (old: {
        version = "3.9-pr5615";
        src = pkgs.fetchurl {
          url = "https://github.com/tmux/tmux/archive/3739dfeab3d20e9db4097a09ff5e63607b788df6.tar.gz";
          hash = "sha256-Ml38VtWWzInC+KlMIWwojGzJUpEF8Ob+p7MLS0lUbDM=";
        };
        doInstallCheck = false;
      });
    };
}
