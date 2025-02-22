MCCL_admins <-
{
	/*
	"[U:1:926037446]" : // this is the SteamID3 of the player you can use the !steamid command to get your steamid
	{
		"forced_name" : "main_thing" // controls what name shows up in the announcement
		"should_announce" : true // controls if the player should be announced to the server
		"announcement" : "[VSCRIPT] Server Owner: %s has joined the game." // %s is where the player name is shown.
		"commands_list" : // Can be ommited to allow all commands to be used.
		{
			"list_type" : "whitelist", // whitelist or blacklist
			"list" : ["noclip", "giveweapon"]
		}
	}
	*/
	
	"DEFAULT_PERMISSIONS" : // default permissions for all players
	{
		"commands_list" : 
		{
			"list_type" : "blacklist", 
			"list" : ["deploybomb", "vscript"] //the !vscript command basically gives you access to all commands, do not set it on by default.
		}
	}
	
	"[U:1:926037446]" : 
	{
		"forced_name" : "main_thing",
		"should_announce" : true,
		"announcement" : "\x01[VSCRIPT]53b3ff Server Owner \"%s\" has joined the game."
	}
	
	/*
	"[U:1:926037446]" : 
	{
		"forced_name" : "main_thing",
		"should_announce" : true,
		"announcement" : "[VSCRIPT]53b3ff Script Creator \"%s\" has joined the game."
		"commands_list" : 
		{
			"list_type" : "whitelist", 
			"list" : ["help"]
		}
	}
	*/
}