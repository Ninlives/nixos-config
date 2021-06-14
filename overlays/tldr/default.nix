final: prev: {
  tldr = prev.tldr.overrideAttrs(a: {
    src = final.fetchFromGitHub {
      owner = "tldr-pages";
      repo  = "tldr-c-client";
      rev   = "252340772e1b5c5abf9cd33e022077abfbc8ccbc";
      sha256 = "06aj9cywnrkgij6vscz08r111gsflcddy0lmrlgsia2lsx51ifw2";
    };
    patches = a.patches or [] ++ [ ./move-to-dot-local.patch ];
  });
}
