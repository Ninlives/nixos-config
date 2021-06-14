{ lib, out-of-world, ... }:
let inherit (out-of-world.function) excludeDisabledFrom;
in { imports = excludeDisabledFrom ./source; }
