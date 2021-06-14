final: prev: {
  rstudio-for-baby = prev.rstudioWrapper.override{
    packages = with prev.rPackages; [
      xlsx
      haven
      labelled
      RSQLite
    ];
  };
}
