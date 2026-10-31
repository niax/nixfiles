{ config, lib, pkgs, ... }:
let
  repo = "niax/nixfiles";

  # Fails unless the running system was built from a commit that main contains,
  # so an upgrade can't silently replace something deployed by hand. Clear a
  # rejection by running nixos-rebuild from a clean, pushed commit.
  guard = pkgs.writeShellApplication {
    name = "nixos-upgrade-guard";
    runtimeInputs = [ pkgs.curl pkgs.jq ];
    text = ''
      rev="''${1:-$(/run/current-system/sw/bin/nixos-version --configuration-revision || true)}"

      reject() {
        echo "Refusing to upgrade: $1" >&2
        exit 1
      }

      case "$rev" in
        "" | null) reject "the running system has no recorded revision" ;;
        *-dirty) reject "the running system was built from a dirty tree ($rev)" ;;
      esac

      response="$(curl --silent --show-error --location --retry 3 \
        --write-out '\n%{http_code}' \
        "https://api.github.com/repos/${repo}/compare/$rev...main?per_page=1")" \
        || reject "could not reach GitHub to check $rev"
      code="''${response##*$'\n'}"
      body="''${response%$'\n'*}"

      case "$code" in
        200) ;;
        404) reject "the running system's revision $rev is not on GitHub" ;;
        *) reject "GitHub returned HTTP $code when checking $rev" ;;
      esac

      status="$(jq -r .status <<<"$body")"
      case "$status" in
        identical | ahead) echo "Running revision $rev is on main ($status)" ;;
        *) reject "the running system's revision $rev is not on main ($status)" ;;
      esac
    '';
  };
in {
  # Follows main on GitHub, honouring its flake.lock, which is bumped by
  # .github/workflows/update-flake-lock.yml. Anything pushed to main reaches
  # every host at its next run.
  system.autoUpgrade = {
    enable = true;
    flake = "github:${repo}#${config.networking.hostName}";
    # --upgrade only refreshes channels, which aren't used here.
    upgrade = false;
    dates = "04:40";
    randomizedDelaySec = "45min";
    # Missed runs (e.g. the WSL VM wasn't running) happen at next start.
    persistent = true;
  };

  systemd.services.nixos-upgrade.preStart = lib.getExe guard;

  nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 30d"; };
  nix.optimise.automatic = true;
}
