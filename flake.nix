{
  description =
    "My personal config files for my daily environment, configured for Dell Inspiron 7590. Now with flakes!";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.external = {
    url = "github:nixos-cn/flakes";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.data.url = "github:Ninlives/data";

  outputs = { self, nixpkgs, home-manager, deploy-rs, flake-utils, external
    , sops-nix, data }@inputs:
    with flake-utils.lib;
    with nixpkgs.lib;
    let
      inherit (nixpkgs.legacyPackages.${system}) pkgs;
      out-of-world = import ./library/out-of-world.nix {
        inherit (nixpkgs) lib;
        inherit constant;
      };
      constant = import ./library/constant.nix {
        inherit (nixpkgs) lib;
        inherit (nixpkgs.legacyPackages.${system}) pkgs;
      };
      system = "x86_64-linux";
      entry = "${constant.user.config.home}/Emerge";
      secrets = "${constant.user.config.home}/Secrets";
      specialArgs = {
        inherit out-of-world constant system inputs;
        allSpecialArgs = specialArgs;
      };

      commitMsg = with pkgs;
        builtins.readFile
        (runCommandLocal "msg" { nativeBuildInputs = [ git coreutils ]; } ''
          cd ${self}
          git log --format=%B -n 1|tr -d '\n'|tr '[:space:]' '_' > ${
            placeholder "out"
          }
        '');

      mergedOverlays = [
        external.overlay
        (final: prev: {
          re-export = external.legacyPackages.${system}.re-export;
        })
      ] ++ map import (out-of-world.function.dotNixFilesFrom ./overlays);
      nixpkgsConfig = {
        allowUnfree = true;
        android_sdk.accept_license = true;
        allowUnsupportedSystem = true;
      };

      mkNixOS = extraConfig:
        let
          modules = [
            external.nixosModules.nixos-cn-registries
            external.nixosModules.nixos-cn
            home-manager.nixosModules.home-manager

            ({ ... }: {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
            })

            ({ ... }: {
              system.nixos.tags = mkAfter [ commitMsg ];
              nixpkgs.overlays = mergedOverlays;
              nixpkgs.config = nixpkgsConfig;

              nix.registry.emerge.to = {
                type = "path";
                path = toString entry;
              };
              revive.specifications.with-snapshot-home.boxes =
                [ entry secrets ];
            })

            ({ pkgs, ... }: {
              environment.systemPackages = [
                (pkgs.writeTextDir "share/zsh/site-functions/_nix" ''
                  # <<<sh>>>
                  function _nix() {
                    local ifs_bk="$IFS"
                    local input=("''${(Q)words[@]}")
                    IFS=$'\n'
                    local res=($(NIX_GET_COMPLETIONS=$((CURRENT - 1)) "$input[@]"))
                    IFS="$ifs_bk"
                    local tpe="''${''${res[1]}%%>	*}"
                    local -a suggestions
                    declare -a suggestions
                    for suggestion in ''${res:1}; do
                      # FIXME: This doesn't work properly if the suggestion word contains a `:`
                      # itself
                      suggestions+="''${suggestion/	/:}"
                    done
                    if [[ "$tpe" == filenames ]]; then
                      compadd -f
                    fi
                    _describe 'nix' suggestions
                  }
                  
                  _nix "$@"
                  # >>>sh<<<
                '')
                (pkgs.writeShellScriptBin "emerge" ''
                  app=$1
                  shift
                  nix run emerge#$app -- $@
                '')
              ];
            })
          ] ++ extraConfig;
          preprocess =
            nixpkgs.lib.nixosSystem { inherit system specialArgs modules; };
        in nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = modules ++ (builtins.attrValues
            preprocess.config.home-manager.users.${constant.user.name}.nixosConfig);
        };

    in with pkgs;
    with out-of-world; {

      nixosConfigurations.mlatus = mkNixOS [
        ./world-implementation
        ./secrets
        sops-nix.nixosModules.sops

        ({ config, ... }: {
          sops.encryptedSSHKeyPaths = [ "/var/lib/sops/local" ];
          system.activationScripts.pre-sops.deps =
            mkIf config.revive.enable [ "revive" ];
          users.users.${constant.user.name}.extraGroups =
            [ config.users.groups.keys.name ];

          home-manager.users.${constant.user.name} = import ./home-in-details;
        })
      ];

      nixosConfigurations.wsl = mkNixOS [
        ./world-implementation/wsl
        ({ config, ... }: {
          home-manager.users.${constant.user.name} =
            import ./home-in-details/wsl.nix;
        })
      ];

      deploy.nodes.cyber = let
        definition = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            ./cyber-definitions
            ./secrets
            (dirs.world.option + /secrets.nix)
            sops-nix.nixosModules.sops
            external.nixosModules.nixos-cn
            ({ ... }: { sops.sshKeyPaths = [ "/var/lib/sops/key" ]; })
          ];
        };
      in {
        sshUser = "root";
        hostname = definition.config.secrets.decrypted.v-host;
        profiles.system.path =
          deploy-rs.lib.${system}.activate.nixos definition;
      };

      legacyPackages.${system} = import nixpkgs {
        inherit system;
        overlays = mergedOverlays;
        config = nixpkgsConfig;
      };

      apps.${system} = let
        fire = os:
          mkApp {
            drv = let toplevel = os.config.system.build.toplevel;
            in writeShellScriptBin "world" ''
              if [[ $1 == "build" ]];then
                echo "Build finished"
              else
                if [[ $1 != "test" ]];then
                  sudo ${nixFlakes}/bin/nix-env -p /nix/var/nix/profiles/system --set ${toplevel}
                fi
                exec sudo ${toplevel}/bin/switch-to-configuration "$@"
              fi
            '';
          };
      in {
        world = fire self.nixosConfigurations.mlatus;
        wsl = fire self.nixosConfigurations.wsl;
        net = mkApp {
          drv = let
            def = toString self;
            key = "/var/lib/sops/key";
            dir = "/var/lib/sops";
            host = self.deploy.nodes.cyber.hostname;
          in writeShellScriptBin "net" ''
            export PATH=${
              makeBinPath [
                git
                openssh
                coreutils
                nixFlakes
                deploy-rs.packages.${system}.deploy-rs
              ]
            }
            # <<<sh>>>
            set -ex
            tmp=$(mktemp -d)

            function cleanup() {
              set +e
              if [[ -d "$tmp" ]];then
                rm -rf "$tmp"
              fi

              while true;do
                echo 'Removing keyfile on server...'
                ssh root@${host} 'if [[ -e ${key} ]];then rm ${key};fi' \
                && break || echo 'Failed, try again.'
              done
            }
            trap cleanup EXIT

            keyFile=$1
            shift
            cp "$keyFile" "$tmp/key"
            ssh-keygen -p -N "" -f "$tmp/key"
            ssh root@${host} 'mkdir -p ${dir};if [[ -e ${key} ]];then rm ${key};fi'
            scp "$tmp/key" root@${host}:${key}
            rm -rf "$tmp"
            deploy "${def}" -- --show-trace
            # >>>sh<<<
          '';
        };
      };

      devShell.${system} = mkShell {
        sopsPGPKeyDirs = [ "./secrets/keys/users" "./secrets/keys/hosts" ];
        nativeBuildInputs = [ sops-nix.packages.${system}.sops-pgp-hook ];
      };

      packages.${system} = {
        image = let
          os = nixpkgs.lib.nixosSystem {
            inherit system specialArgs;
            modules = [ ./cyber-definitions/image.nix ];
          };

        in os.config.system.build.image;
      };
    };
}
