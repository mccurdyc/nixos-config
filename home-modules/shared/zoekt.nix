{ ... }: {
  # https://github.com/sourcegraph/zoekt/blob/main/cmd/zoekt-indexserver/config.go
  # export CTAGS_COMMAND="ctags"; zoekt-indexserver -mirror_config ~/.config/zoekt/config.json -cpu_fraction 0.5 -mirror_duration 1h0m0s
  # zoekt-webserver -index /home/mccurdyc/zoekt-serving/index
  home.file.".config/zoekt/config.json".text = ''
    [
    	{
    		"GithubUser": "mccurdyc",
        "CredentialPath": "/home/mccurdyc/.github-token"
    	},
    	{
    		"GithubOrg": "fastly",
        "CredentialPath": "/home/mccurdyc/.github-token"
    	},
    	{
    		"GithubOrg": "fastly-def",
        "Name": "^configly-data$",
        "CredentialPath": "/home/mccurdyc/.github-token"
    	}
    ]
  '';
}
