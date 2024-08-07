{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [
    pkgs.ffmpeg
    pkgs.git
    pkgs.gitleaks
    # JDK is required for shadow-cljs compilation. Without it, shadow-cljs fails with "Unable to locate a Java Runtime."
    pkgs.jdk
    pkgs.nodejs
  ];

  # https://devenv.sh/scripts/
  scripts.hello.exec = "echo hello from $GREET";
  scripts.build.exec = "shadow-cljs compile :main :renderer";
  scripts.accent.exec = ''
    nodemon --watch out --exec 'pkill -f "node_modules/electron"; electron .'
  '';

  enterShell = ''
    hello
    git --version
    export PATH="$DEVENV_ROOT/node_modules/.bin:$PATH"
    npm i
  '';

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    shadow-cljs compile :test
  '';

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/languages/
  # languages.nix.enable = true;

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;
  pre-commit.hooks = {
    cljfmt.enable = true;
    eslint = {
      enable = true;
      # https://github.com/cachix/pre-commit-hooks.nix/blob/9d3d7e18c6bc4473d7520200d4ddab12f8402d38/modules/hooks.nix#L1649
      entry = lib.mkForce "eslint --fix";
    };
    gitleaks = {
      enable = true;
      # https://github.com/gitleaks/gitleaks/blob/39947b0b0d3f1829438000819c1ba9dbeb023a89/.pre-commit-hooks.yaml#L4
      entry = "gitleaks protect --verbose --redact --staged";
    };
    nixpkgs-fmt.enable = true;
    prettier.enable = true;
    # https://github.com/cachix/git-hooks.nix/issues/31#issuecomment-744657870
    trailing-whitespace = {
      enable = true;
      # https://github.com/pre-commit/pre-commit-hooks/blob/4b863f127224b6d92a88ada20d28a4878bf4535d/.pre-commit-hooks.yaml#L201-L207
      entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/trailing-whitespace-fixer";
      types = [ "text" ];
    };
  };

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";

  # See full reference at https://devenv.sh/reference/options/
}
