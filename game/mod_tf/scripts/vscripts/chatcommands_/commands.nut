local cc_scope = this
local helptable =
{
	"help" : "Displays all commands available, and takes an argument of a command name.\nUsage: !help noclip"
	"noclip" : "Toggles noclip.\nUsage: !noclip"
	"tp" : "Sets your camera to be in thirdperson.\nUsage: !tp"
	"fp" : "Sets your camera to be in firstperson.\nUsage: !fp"
	"toggletp" : "Toggles between firstperson and thirdperson.\nUsage: !toggletp"
	"thirdperson" : "Sets your camera to be in thirdperson.\nUsage: !thirdperson"
	"firstperson" : "Sets your camera to be in firstperson.\nUsage: !firstperson"
	"togglethirdperson" : "Toggles between firstperson and thirdperson.\nUsage: !togglethirdperson"
	"addattribute" : "Adds an attribute of your choosing to your active weapon.\nUsage: !addattribute 'fire rate bonus' 0.5"
	"findattribute" : "Find an attribute via text input.\nUsage: !findattribute damage"
	"giveweapon" : "Gives you a weapon by its weapon id and classname.\nUsage: !giveweapon tf_weapon_sniperrifle 14"
	"giveweaponcustom" : "Gives you a custom weapon from the custom weapon list.\nUsage: !giveweaponcustom name"
	"givecustomweapon" : "Gives you a custom weapon from the custom weapon list.\nUsage: !givecustomweapon name"
	"customweaponlist" : "Lists all custom weapons into the console.\nUsage: !customweaponlist"
	"setclass" : "Sets your class to a class of your choosing by name.\nUsage: !setclass scout"
	"joinblue" : "Join the robots in MVM.\nUsage: !joinblue"
	"vsentrybuster" : "Turns you into the MVM sentrybuster.\nUsage: !vsentrybuster"
	"setfov" : "Sets your FOV to a number you specify.\nUsage: !setfov 120"
	"score" : "Gives you an amount of score you specify.\nUsage: !score 100"
	"hhh" : "Become the headless horseless horsemann.\nUsage: !hhh"
	"bonk" : "Stuns you for a specified duration in seconds.\nUsage: !bonk 0.1"
	"deploybomb" : "Deploys the bomb in Mann Vs Machine."
	"giant" : "Makes you an Mann Vs Machine giant.\nUsage: !giant"
	"boss" : "Makes you a boss from !bosslist.\nUsage: !boss sirnuke"
	"bosslist" : "Lists all custom bosses into the console.\nUsage: !bosslist"
	"vscript" : "Runs vscript code via specified input.\nUsage: !vscript ClientPrint(self,3,`Hello World!`)"
	"toolgun" : "Gives you a gun that can manipulate objects in the world.\nUsage: !toolgun"
	"dropweapon" : "Attempts to drop your active weapon.\nUsage: !dropweapon"
	"buffweapon" : "Multiplies the stats of your active weapon by 2.\nUsage: !buffweapon"
	"afk" : "Makes you unkillable and unable to shoot.\nUsage: !afk"
	"vtaunt" : "Makes you taunt via a taunt id or taunt name you specify.\nUsage: !vtaunt 1118\nor !vtaunt conga"
	"tauntlist" : "Lists all taunt names you can use with the !vtaunt command to the console, in the format of [id] name.\nUsage: !tauntlist"
	"meem" : "Toggles your model to a target dummy model.\nUsage: !meem"
	"robot" : "Toggles your model to a robot model.\nUsage: !robot"
	"tank" : "Makes you an MVM tank.\nUsage: !tank"
	"noweapons" : "Removes all your weapons.\nUsage: !noweapons"
	"nohats" : "Removes all your hats.\nUsage: !nohats"
	"noloadout" : "Removes all your hats and weapons.\nUsage: !noloadout"
	"randomweapon" : "Gives you a random weapon.\nUsage: !randomweapon"
	"randomloadout" : "Gives you a random primary, secondary and melee weapon.\nUsage: !randomloadout"
	"steamid" : "Outputs your steamid in steamid3 form.\nUsage: !steamid"
	"disablekick" : "Disables automatic kicks from being afk.\nUsage: !disablekick"
	"decoy" : "Spawns a bot_npc_decoy with you as the owner.\nUsage: !decoy"
}

local cc_scope = this
IncludeScript("chatcommands_/helperfunctions.nut", cc_scope)
IncludeScript("chatcommands_/precaches.nut", cc_scope)
IncludeScript("chatcommands_/generalfunctions.nut", cc_scope)
IncludeScript("chatcommands_/weaponfunctions.nut", cc_scope)
IncludeScript("chatcommands_/mvmfunctions.nut", cc_scope)
IncludeScript("chatcommands_/mvmchatfix.nut", cc_scope)
IncludeScript("chatcommands_/headless_hatman_damage_hook.nut", cc_scope)
IncludeScript("chatcommands_/toolgun.nut", cc_scope)
IncludeScript("chatcommands_/data/admins.nut", cc_scope)
IncludeScript("chatcommands_/data/tauntlist.nut", cc_scope)
IncludeScript("chatcommands_/data/attribs.nut", cc_scope)
IncludeScript("chatcommands_/data/weapons.nut", cc_scope)
IncludeScript("chatcommands_/data/bosses.nut", cc_scope)
IncludeScript("chatcommands_/data/cweapons.nut", cc_scope)
// currently unusused, was meant for the !forcecommand command
function util_findplayer(text)
{
	if(text.find("@") == 0)
	{
		return find_selector(split(text, "@")[1])
	}
	local players = []
	for(local i = 1;i<=MaxClients();i++){
		local player = PlayerInstanceFromIndex(i);
		if(player==null) continue;
		if(NetProps.GetPropString(player,"m_szNetname").find(rstrip(text))>-1) players.append(player)
	}
	return players
}

function find_selector(text)
{
	local players = []
	if(text.tolower().find("me") == 0)
	{
		players.append(self)
	}
	if(text.tolower().find("all") == 0)
	{
		for(local i = 1; i <= MaxClients(); i++){
			local player = PlayerInstanceFromIndex(i);
			if(player == null) continue;
			players.append(player)
		}
	}
	if(text.tolower().find("alive") == 0)
	{
		for(local i = 1; i <= MaxClients(); i++){
			local player = PlayerInstanceFromIndex(i);
			if(player == null) continue;
			if(NetProps.GetPropInt("m_lifeState") != 0) continue;
			players.append(player)
		}
	}
	if(text.tolower().find("dead") == 0)
	{
		for(local i = 1; i <= MaxClients(); i++){
			local player = PlayerInstanceFromIndex(i);
			if(player == null) continue;
			if(NetProps.GetPropInt("m_lifeState") != 2) continue;
			players.append(player)
		}
	}
	if(text.tolower().find("specators") == 0)
	{
		for(local i = 1; i <= MaxClients(); i++){
			local player = PlayerInstanceFromIndex(i);
			if(player == null) continue;
			if(player.GetTeam() > 1) continue;
			players.append(player)
		}
	}
	if(text.tolower().find("red") == 0 || text.tolower().find("defenders") == 0)
	{
		for(local i = 1; i <= MaxClients(); i++){
			local player = PlayerInstanceFromIndex(i);
			if(player == null) continue;
			if(player.GetTeam() != 2) continue;
			players.append(player)
		}
	}
	if(text.tolower().find("blue") == 0 || text.tolower().find("blu") == 0 || text.tolower().find("robots") == 0)
	{
		for(local i = 1; i <= MaxClients(); i++){
			local player = PlayerInstanceFromIndex(i);
			if(player == null) continue;
			if(player.GetTeam() != 3) continue;
			players.append(player)
		}
	}
	return players;
}

/*
function MCC_test(...)
{
	ClientPrint(self, 3, "Args: ")
	foreach(i,val in vargv)
    {
        if(i == vargv.len() - 1) break;
		ClientPrint(self, 3, val)
    }
	local input = ""
	foreach(i, item in vargv) { if(i == vargv.len() - 1) break;input += item + " "}
	input = rstrip(input)
	ClientPrint(self, 3, "INPUT: " + input)
	
	input = ""
	foreach(i, item in vargv) { if(i == vargv.len() - 1) break;input += item + " "}
	input = rstrip(input.tolower())
	ClientPrint(self, 3, "INPUT (lowered): " + input)
}
*/

function MCC_help(...)
{
	if(vargv.len() < 2)
	{
		local helpstring = "[VSCRIPT] "
		foreach(k, item in cc_scope)
		{
			if(k.find("MCC_") == 0)
			{
				if((helpstring + "!" + k.slice(4) + " ").len() < 200)
				{
					helpstring += "!" + k.slice(4) + " "
				} 
				else 
				{
					ClientPrint(self, 3, helpstring)
					helpstring = "!" + k.slice(4) + " "
				}
			}
		}
		ClientPrint(self, 3, helpstring)
	}
	else
	{
		local input = ""
		foreach(i, item in vargv) { if(i == vargv.len() - 1) break; input += item + " "}
		input = rstrip(input.tolower())
		if(input.find("!") == 0) input = input.slice(1)
		if("MCC_" + input in cc_scope)
		{
			local helptext = "No help available for this command."
			if(input in helptable)
				helptext = helptable[input]
			return ClientPrint(self, 3, "[VSCRIPT] " + helptext)
		}
		return ClientPrint(self, 3, "\x01[VSCRIPT] No such command.")
	}
}

local cmds = "MCCM_cmds_main"//UniqueString("MCC")
getroottable()[cmds] <- 
{
	OnGameEvent_player_say = function(data)
	{
		local player = GetPlayerFromUserID(data.userid)
		if(!player)
			return
		if(!player.IsPlayer())
			return
		player.ValidateScriptScope()
		local playerscope = player.GetScriptScope()
		if(!("MCCD_steamid" in playerscope))
			playerscope.MCCD_steamid <- NetProps.GetPropString(player, "m_szNetworkIDString")
		local steamid = playerscope.MCCD_steamid
		if(startswith(data.text, "!") || startswith(data.text, "/")) 
		{
			local list_type = "blacklist"
			local list = []
			if(steamid in MCCL_admins)
			{
				if("commands_list" in MCCL_admins[steamid])
				{
					if("list" in MCCL_admins[steamid].commands_list)
						list = MCCL_admins[steamid].commands_list.list
					if("list_type" in MCCL_admins[steamid].commands_list)
						list_type = MCCL_admins[steamid].commands_list.list_type
				}
			}
			else if("DEFAULT_PERMISSIONS" in MCCL_admins)
			{
				if("commands_list" in MCCL_admins.DEFAULT_PERMISSIONS)
				{
					if("list" in MCCL_admins.DEFAULT_PERMISSIONS.commands_list)
						list = MCCL_admins.DEFAULT_PERMISSIONS.commands_list.list
					if("list_type" in MCCL_admins.DEFAULT_PERMISSIONS.commands_list)
						list_type = MCCL_admins.DEFAULT_PERMISSIONS.commands_list.list_type
				}
			}
			local args = split(data.text, " ")
			local arg_array = split(args[0], data.text.slice(0,1))
			if(arg_array.len() > 1)
			{
				local command = arg_array[1].tolower()
				if(list_type == "blacklist")
				{
					if(list.find(command) != null) 
					{
						return ClientPrint(player, 3, "\x01[VSCRIPT]d13b30 You do not have permission to use this command.")
					}
				}
				if(list_type == "whitelist")
				{
					if(list.find(command) == null) 
					{
						return ClientPrint(player, 3, "\x01[VSCRIPT]d13b30 You do not have permission to use this command.")
					}
				}
				args[0] = playerscope
				args.append(data.text)
				if("MCC_" + command in this)
				{
					this["MCC_" + command].acall(args)
				}
			}
		}
		if(!startswith(data.text, "/"))
		{
			mvmchatfix(player, data)
		}
	}
	OnGameEvent_player_connect_client = function(data)
	{
		if(!("networkid" in data))
			return
		local steamid = data.networkid
		if(steamid in MCCL_admins)
		{
			if("should_announce" in MCCL_admins[steamid])
			{
				if(MCCL_admins[steamid].should_announce)
				{
					if("announcement" in MCCL_admins[steamid])
					{
						local name = data.name
						if("forced_name" in MCCL_admins[steamid])
							name = MCCL_admins[steamid].forced_name
						local announcement = format(MCCL_admins[steamid].announcement, name)
						ClientPrint(null, 3, announcement)
						printl(announcement)
					}
				}
			}
		}
	}
	OnGameEvent_player_activate = function(data)
	{
		local player = GetPlayerFromUserID(data.userid)
		if(!player)
			return
		if(!player.IsPlayer())
			return
		ClientPrint(player, 3, "\x01[VSCRIPT]53b3ff Type !help to see a list of commands.")
	}
	
	OnGameEvent_scorestats_accumulated_update = function(data)
	{
		EntFireByHandle(Entities.FindByClassname(null, "worldspawn"), "runscriptcode", "MCCF_UPDATE()", 0.0, null, null)
	}
	
	OnScriptHook_OnTakeDamage = function(data)
	{
		MCCH_Headless_Hatman(data)
	}
}
function MCCF_UPDATE()
{
	local EventsTable = getroottable()[cmds]
	foreach(name, callback in EventsTable) EventsTable[name] = callback.bindenv(cc_scope)
	__CollectGameEventCallbacks(EventsTable)
}
MCCF_UPDATE()