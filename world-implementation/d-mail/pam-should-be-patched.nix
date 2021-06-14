{ config, lib, pkgs, alpha-world-line, out-of-world, ... }:
let
  inherit (out-of-world) dirs;
  inherit (lib) mkForce foldl;
  inherit (builtins) appendContext getContext;
  inherit (pkgs.nixos-cn) pam-python pam-device howdy;

  howdy-rule =
    "auth sufficient ${pam-python}/lib/security/pam_python.so ${howdy}/lib/security/howdy/pam.py";
  usb-guard =
    "auth [success=ok new_authtok_reqd=ok default=1] ${pam-python}/lib/security/pam_python.so ${pam-device}/lib/security/pam_device.py";
  inserted-rule = "${usb-guard}\\n${howdy-rule}";

  pam-service-config = alpha-world-line.security.pam.services;

  patched-pam-text = lib.mapAttrs (service: config:
    let
      patched-text = pkgs.runCommandLocal "${service}-pam" {
        passAsFile = [ "text" ];
        inherit (config) text;
      } ''
        # <<<sh>>>
        cat $textPath > $out
        if grep -q 'auth required pam_unix\.so' $out; then
          sed -i '/auth required pam_unix\.so/i ${inserted-rule}' $out
        elif grep -q 'auth sufficient pam_unix\.so' $out; then
          sed -i '/auth sufficient pam_unix\.so/i ${inserted-rule}' $out
        fi
        # >>>sh<<<
      '';
      result = appendContext (builtins.readFile patched-text)
        (getContext (toString patched-text));
    in { text = mkForce result; }) pam-service-config;
in {
  security.pam.services = patched-pam-text;
  revive.specifications.with-snapshot.boxes = [ /var/lib/howdy /var/lib/pam-device ];
}
