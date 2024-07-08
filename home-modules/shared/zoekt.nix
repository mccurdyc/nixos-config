{ ... }: {
  home.file.".config/zoekt/config.json".text = ''
    [
    	{
    		"GithubUser": "mccurdyc"
    	},
    	{
    		"GithubOrg": "fastly"
    	}
    ]
  '';
}
