{ buildPythonPackage, fetchPypi, psutil }:
buildPythonPackage rec {
  pname = "powerline-mem-segment";
  version = "2.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0k744wmp5mw6xq9c54y24kv22m525ipjpl6xzr67cq0vbz4728k8";
  };

  propagatedBuildInputs = [ psutil ];
}
