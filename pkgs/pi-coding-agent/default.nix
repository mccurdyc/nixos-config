{ buildNpmPackage, fetchurl, lib }:

buildNpmPackage {
  pname = "pi-coding-agent";
  version = "0.64.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-0.64.0.tgz";
    hash = "sha256-SSdIyhoK9DEa0qFNK3dAsTPcOhvhJQ/w7klVCB2kqZo=";
  };

  # Generated via:
  #   curl -sL <tarball> | tar -xzf - && cd package
  #   npm install --package-lock-only --ignore-scripts
  npmDepsHash = "sha256-eH3Z1iTclJaKkaA0blTTgs9gbVZJ/eEuOicNLgOkgn4=";

  # The tarball unpacks to a "package/" subdirectory.
  sourceRoot = "package";

  # package-lock.json is generated; patch it in at build time.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  # No build step: the package ships pre-compiled JS in dist/.
  npmBuildScript = null;
  dontNpmBuild = true;

  meta = {
    description = "Minimal terminal coding agent";
    homepage = "https://pi.dev";
    license = lib.licenses.mit;
    mainProgram = "pi";
  };
}
