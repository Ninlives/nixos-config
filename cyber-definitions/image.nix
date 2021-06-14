{ pkgs, config, modulesPath, ... }:
with pkgs;
let
  toplevel = config.system.build.toplevel;
  db = closureInfo { rootPaths = [ toplevel ]; };
  rootfs = config.fileSystems."/";
in
{
  imports = [ 
    ./machine.nix
    (modulesPath + "/profiles/minimal.nix") 
  ];

  system.build.image = runCommandNoCC "nixos.img" { } ''
    export TERM=dumb
    export HOME=$TMPDIR/home
    export root=$TMPDIR/root
    export NIX_STATE_DIR=$TMPDIR/state
    ${nix}/bin/nix-store --load-db < ${db}/registration
    ${nix}/bin/nix copy --no-check-sigs --to $root ${toplevel}
    ${nix}/bin/nix-env --store $root -p $root/nix/var/nix/profiles/system --set ${toplevel}
    ${fakeroot}/bin/fakeroot ${libguestfs-with-appliance}/bin/guestfish -N $out=fs:${rootfs.fsType}:1G -m /dev/sda1 << EOT
    set-label /dev/sda1 ${rootfs.label}
    copy-in $root/nix /
    mkdir-mode /etc 0755
    command "/nix/var/nix/profiles/system/activate"
    command "/nix/var/nix/profiles/system/bin/switch-to-configuration boot"
    EOT
  '';

}
