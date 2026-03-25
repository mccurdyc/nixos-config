{ ... }:
{
  home.file.".claude/settings.json".text = builtins.toJSON {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";
    permissions = {
      allow = [];
      deny = [];
    };
  };
}
