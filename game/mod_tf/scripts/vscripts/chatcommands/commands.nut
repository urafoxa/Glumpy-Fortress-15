///////////////////VARIABLES/////////////////////
local weaponlistname = "chatcommands/cweapons.txt" //Change this to the custom weapons filename.
local ownersteamid = "[U:1:926037446]"
local adminsenabled = false
announcejoins <- true //Controls if the game should announce owner / client joins to the clients.
chatcommandsenabled <- true //Controls if the chatcommands are avaibleable, it can be modified via the script command.
tauntenabled <- true //Controls if the !taunt commands are enabled
/////////////////////////////////////////////////
//////////////////DEPENDANCIES///////////////////
IncludeScript("chatcommands/mvmchatfix.nut",null)
IncludeScript("chatcommands/weaponfunctions.nut",null)
IncludeScript("chatcommands/miscfunctions.nut",null)
IncludeScript("chatcommands/toolgun.nut",null)
/////////////////////////////////////////////////
///////////////////custom weapons documentation/////////////////////
//*deflector*{
//"classname" "tf_weapon_minigun"
//"itemindex" 850
//"attributes" ("damage bonus",1.5;"attack projectiles",1)
//}
// DO NOT COPY ANY "//" OR ANY LINE OF TEXT PAST THIS LINE TO SAVE YOU FROM A HEADACHE.
// In the tf2 directory locate the "scriptdata" (no quotes) folder.
// In the folder make a new file named cweapons.txt (If my mod does not already inclue it)
// open the file and add your custom weapon. Template is seen above.
// *deflector* is the line which contains the weapon name that will be used with the !giveweaponcustom command. NOTE: the weapon name should always be in lowercase
// "itemindex" is the weapon ID which can be found here: https://wiki.alliedmods.net/Team_fortress_2_item_definition_indexes
// "classname" is the weapon entity name which starts with "tf_weapon".
// "attributes" contains all the weapon attributes. If you dont want to have any extra attributes type "attributes" () instead of leaving the line out.
////////////////////////////////////////////////////////////////////
PrecacheScriptSound("mvm/sentrybuster/mvm_sentrybuster_step_01.wav")
PrecacheScriptSound("mvm/sentrybuster/mvm_sentrybuster_step_02.wav")
PrecacheScriptSound("mvm/sentrybuster/mvm_sentrybuster_step_03.wav")
PrecacheScriptSound("mvm/sentrybuster/mvm_sentrybuster_step_04.wav")
PrecacheScriptSound("mvm/sentrybuster/mvm_sentrybuster_intro.wav")
PrecacheScriptSound("mvm/sentrybuster/mvm_sentrybuster_loop.wav")
PrecacheScriptSound("mvm/sentrybuster/mvm_sentrybuster_spin.wav")
PrecacheScriptSound("mvm/sentrybuster/mvm_sentrybuster_explode.wav")
function validateadmin(player, steamid, is_command = false) {
	local adminscfg = FileToString("chatcommands/admins.txt")
	local adminslist = split(adminscfg,"\n")
	foreach (item in adminslist) {
		if (item.find("adminsenabled") != null) {
			if (item.find("0","adminsenabled".len()) != null) {
				adminsenabled = false
			} else if (item.find("1","adminsenabled".len()) != null) {
				adminsenabled = true
			}
		}
	}
	if (adminslist.find(steamid) != null || steamid == ownersteamid && adminsenabled) {
		return true
	} else {
		if(is_command && player != null){
			ClientPrint(player,3,"[VSCRIPT] You do not have permission to use this command.")
		}
		return false
	}
}
if(chatcommandsenabled){
	PrecacheModel("models/weapons/c_models/c_bigaxe/c_bigaxe.mdl")
	StringToFile("chatcommands/steamids.txt","")
	function OnGameEvent_player_say(data) { 
		local ply = GetPlayerFromUserID(data.userid);
		local plyname = NetProps.GetPropString(ply,"m_szNetname").tostring()
		local plysteamid = NetProps.GetPropString(ply,"m_szNetworkIDString").tostring()
		if (ply != null) {
		if (validateadmin(ply,plysteamid) || adminsenabled == false) {
		//a quick fix for mvm chat
		mvmchatfix(ply,plyname,data)
		if (data.text.tolower() == "!dropweapon") {
		local plywep = ply.GetActiveWeapon()
			if (plywep != null) {
				local weapon = SpawnEntityFromTable("tf_dropped_weapon", {model ="models/weapons/c_models/c_saxxy/c_saxxy.mdl" origin = ply.EyePosition()})
				NetProps.SetPropInt(weapon,"m_nModelIndex",NetProps.GetPropInt(plywep,"m_iWorldModelIndex"))
				NetProps.SetPropInt(weapon,"m_Item.m_iItemDefinitionIndex",NetProps.GetPropInt(plywep,"m_AttributeManager.m_Item.m_iItemDefinitionIndex"))
				NetProps.SetPropInt(weapon,"m_Item.m_iEntityQuality",NetProps.GetPropInt(plywep,"m_AttributeManager.m_Item.m_iEntityQuality"))
				NetProps.SetPropInt(weapon,"m_Item.m_bInitialized",1)
				ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffDropped Player weapon.")
			} else {
				ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30Player is not holding a weapon to be dropped.")
			}
			// I have not found out how to clone the attribs yet.
			// Tried to use netprops to get the attrib but its giving me consistant gibberish?
		}
		if (data.text.tolower() == "!tp" || data.text.tolower() == "!thirdperson") {
			ply.SetForcedTauntCam(1)
		}
		if (data.text.tolower() == "!fp" || data.text.tolower() == "!firstperson") {
			ply.SetForcedTauntCam(0)
		}
		if (data.text.tolower() =="!noclip") {
		
			if (ply.GetMoveType() != 8) {
				ply.SetMoveType(8, 0)
			} else {
				ply.SetMoveType(2, 0)
			}
		ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffToggled Noclip On " + plyname)
		}
		if (data.text.tolower().find("!noclip") == 0) {
			if (strip(data.text.tolower()) !="!noclip") {
				local foundplayer = null
				local target = null
				while(target = Entities.FindByClassname(target, "player"))
				{
					if (NetProps.GetPropString(target,"m_szNetname").tostring() == data.text.slice("!noclip ".len())) {
					if (target.GetMoveType() != 8) {
						target.SetMoveType(8, 0)
						} else {
						target.SetMoveType(2, 0)
					}
					foundplayer = 1
					ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffToggled Noclip On " + data.text.slice("!noclip ".len()))
					}
				}
				if (foundplayer != 1) {
					ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30"+format("player named '%s' is not found.", data.text.slice("!noclip ".len())))
				}
			}
		}
		
		if (data.text.tolower().find("!setclass") == 0) {
			if (strip(data.text.tolower()) != "!setclass") {
				local substring = data.text.slice("!setclass ".len()).tolower()
				local classfound = 0
				if (substring == "scout") {
					ply.SetPlayerClass(1)
					classfound = 1
				}
				if (substring == "sniper") {
					ply.SetPlayerClass(2)
					classfound = 1
				}
				if (substring == "soldier") {
					ply.SetPlayerClass(3)
					classfound = 1
					}
				if (substring == "demo"||substring == "demoman") {
					ply.SetPlayerClass(4)
					classfound = 1
				}
				if (substring == "medic") {
					ply.SetPlayerClass(5)
					classfound = 1
				}
				if (substring == "heavy"||substring == "heavyweapons") {
					ply.SetPlayerClass(6)
					classfound = 1
				}
				if (substring == "pyro") {
					ply.SetPlayerClass(7)
					classfound = 1
				}
				if (substring == "spy") {
					ply.SetPlayerClass(8)
					classfound = 1
				}
				if (substring == "engineer") {
					ply.SetPlayerClass(9)
					classfound = 1
				}
				if (substring == "civillian"||substring == "civilian") {
					ply.SetPlayerClass(10)
					classfound = 1
				}
				if (classfound != 1) {
					ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30"+format("no class named '%s'.", substring))
				} else {
					ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ff"+format("Player's class has been set to '%s'.", substring))
				}
				ply.Regenerate(true)
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","",0,ply,ply)
			} else {
			ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ff"+"Usage: !setclass spy")
		}
	}
		if (data.text.tolower() =="!joinblu"||data.text.tolower() =="!joinblue") {
			if(IsMannVsMachineMode()){
				ply.ForceChangeTeam(1,true) //This prevents ghost players stacking up.
				NetProps.SetPropInt(ply,"m_iTeamNum",3)
				ply.ForceRespawn()
			} else {
				ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30Command Only Available In MvM.")
			}
		}
		if (data.text.tolower() == "!powerplay") {
			if (NetProps.GetPropInt(ply,"m_bInPowerPlay") == 1) {
			ply.RemoveCond(57)
			ply.RemoveCond(33)
			ply.RemoveCond(28)
			ply.RemoveCond(58)
			ply.RemoveCond(59)
			ply.RemoveCond(60)
			ply.RemoveCond(61)
			ply.RemoveCond(62)
			ply.RemoveCond(63)
			ply.RemoveCond(73)
			ply.AddCond(8)
			NetProps.SetPropInt(ply,"m_bInPowerPlay", 0)
			return;
			}
			ply.AddCond(57)
			ply.AddCond(33)
			ply.AddCond(28)
			ply.AddCond(58)
			ply.AddCond(59)
			ply.AddCond(60)
			ply.AddCond(61)
			ply.AddCond(62)
			ply.AddCond(63)
			ply.AddCond(73)
			NetProps.SetPropInt(ply,"m_bInPowerPlay", 1)
			ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffToggled PowerPlay On " + plyname)
		}	
		/*	if (data.text.tolower().find("!powerplay") == 0) {
			if (strip(data.text.tolower()) !="!powerplay") {
				local foundplayer = null
				local target = null
				while(target = Entities.FindByClassname(target, "player"))
				{
					if (NetProps.GetPropString(target,"m_szNetname").tostring() == data.text.slice("!powerplay ".len())) {
					target.AddCond(33)
					target.AddCond(28)
					target.AddCond(58)
					target.AddCond(59)
					target.AddCond(60)
					target.AddCond(61)
					target.AddCond(62)
					target.AddCond(63)
					target.AddCond(73)
					NetProps.SetPropInt(target,"m_bInPowerPlay",1)
					foundplayer = 1
					ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffToggled PowerPlay On " + data.text.slice("!powerplay ".len()))
					}
				}
				if (foundplayer != 1) {
					ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30"+format("player named '%s' is not found.", data.text.slice("!powerplay ".len())))
				}
			}
		}*/
		if (data.text.tolower() == "!buffweapon") {
		local plywep = ply.GetActiveWeapon()
			if (plywep == null) {
			ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30Player is not holding a weapon.")
			return;
			}
			if (plywep.GetClassname().tostring() != "tf_weapon_sapper" && plywep.GetClassname().tostring() != "tf_weapon_builder") {
			local weapon = SpawnEntityFromTable(plywep.GetClassname().tostring(),{})
			NetProps.SetPropInt(weapon, "m_bValidatedAttachedEntity", 1)
			NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex",NetProps.GetPropInt(plywep,"m_AttributeManager.m_Item.m_iItemDefinitionIndex"))
			NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_bInitialized",1)
			weapon.AddAttribute("damage bonus HIDDEN",10099,-1) //Do not use normal damage bonus or mvm will freeze due to too many upgrade points being displayed.
			weapon.AddAttribute("clip size bonus",1099,-1)
			weapon.AddAttribute("fire rate bonus",0.25,-1)
			weapon.AddAttribute("heal on hit for rapidfire",250,-1)
			weapon.AddAttribute("critboost on kill",10,-1)
			weapon.AddAttribute("Projectile speed increased",1.5,-1)
			weapon.AddAttribute("move speed bonus",2,-1)
			weapon.AddAttribute("hidden primary max ammo bonus",200,-1)
			weapon.AddAttribute("ammo regen",2000,-1)
			weapon.AddAttribute("reload time increased hidden",0.1,-1)
			weapon.AddAttribute("attach particle effect",2,-1)
			ClientPrint(ply,3,plywep.GetClassname().tostring())
			plywep.Kill()
			ply.Weapon_Equip(weapon)
			ply.Weapon_Switch(weapon)
			//doing this to make it not presist after death.
			} else {
			ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30Sappers cannot be buffed.")
			}
		}
		if (data.text.tolower() == "!kill") {
		NetProps.SetPropInt(ply,"m_lifeState",1)
		}
		if (data.text.tolower().find("!kill") == 0) {
			if (strip(data.text.tolower()) !="!kill") {
				local foundplayer = null
				local target = null
				while(target = Entities.FindByClassname(target, "player"))
				{
					//Say(null, data.text.slice("!kill ".len()), false) //debug
					if (data.text.slice("!kill ".len()) == "@all" && validateadmin(ply,plysteamid)) {
						if (NetProps.GetPropInt(target,"m_lifeState") != 2) {
							target.TakeDamage(target.GetHealth(),0 , target)
							foundplayer = 1
						}
					} else if (data.text.slice("!kill ".len()).find(NetProps.GetPropString(target,"m_szNetname").tostring()) && validateadmin(ply,plysteamid)) {
					if (NetProps.GetPropInt(target,"m_lifeState") != 2) {
						NetProps.SetPropInt(target,"m_lifeState",1)
					} else {
						ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30Target must be alive to kill.")
					}
						foundplayer = 1
					//Say(null,NetProps.GetPropInt(target,"m_lifeState").tostring(),false) //debug
					}
				}
				if (foundplayer != 1) {
				ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30"+format("player named '%s' is not found.", data.text.slice("!kill ".len())))
				}
			}
		}	
		if (data.text.tolower() == "!deploybomb") {
			if (Entities.FindByName(null, "cap_destroy_relay") && validateadmin(ply,plysteamid)) {
				EntFire("cap_destroy_relay","trigger",null,2)
			}
		}
		if (data.text.tolower() == "!steamid") {
			ClientPrint(ply, 3, "\x0004Current SteamID: \x0001" + plysteamid.tostring())
		}
		if (data.text.tolower() == "!bonk") {
			local stun = SpawnEntityFromTable("trigger_stun",{origin = ply.GetOrigin() stun_type = 1 stun_duration = 10 spawnflags = 9})
			EntFireByHandle(stun,"addoutput","mins -1 -1 -1",0,stun,stun)
			EntFireByHandle(stun,"addoutput","maxs 1 1 1",0,stun,stun)
			EntFireByHandle(stun,"addoutput","solid 2",0,stun,stun)
			EntFireByHandle(stun,"kill","",0.1,stun,stun)
		}
			if (data.text.tolower().find("!bonk") == 0) {
			if (strip(data.text.tolower()) !="!bonk") {
				local foundplayer = null
				local target = null
				while(target = Entities.FindByClassname(target, "player"))
				{
					//Say(null,NetProps.GetPropString(target,"m_szNetname").tostring(),false)
					//Say(null, data.text.slice("!kill ".len()), false) //debug
					if (data.text.slice("!bonk ".len()) == "@all") {
					if (NetProps.GetPropInt(target,"m_lifeState") != 2) {
					local stun = SpawnEntityFromTable("trigger_stun",{origin = target.GetOrigin() stun_type = 1 stun_duration = 10 spawnflags = 9 OnStunPlayer = "!self,kill"})
					EntFireByHandle(stun,"addoutput","mins -1 -1 -1",0,stun,stun)
					EntFireByHandle(stun,"addoutput","maxs 1 1 1",0,stun,stun)
					EntFireByHandle(stun,"addoutput","solid 2",0,stun,stun)
					foundplayer = 1
					}
					} else if (NetProps.GetPropString(target,"m_szNetname").tostring() == data.text.slice("!bonk ".len())) {
					if (NetProps.GetPropInt(target,"m_lifeState") != 2) {
						local stun = SpawnEntityFromTable("trigger_stun",{origin = target.GetOrigin() stun_type = 1 stun_duration = 10 spawnflags = 9})
						EntFireByHandle(stun,"addoutput","mins -1 -1 -1",0,stun,stun)
						EntFireByHandle(stun,"addoutput","maxs 1 1 1",0,stun,stun)
						EntFireByHandle(stun,"addoutput","solid 2",0,stun,stun)
						EntFireByHandle(stun,"kill","",0.1,stun,stun)
					} else {
					ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30Target must be alive to bonk.")
					}
					foundplayer = 1
					//Say(null,NetProps.GetPropInt(target,"m_lifeState").tostring(),false) //debug
					}
				}
				if (foundplayer != 1) {
					ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30"+format("player named '%s' is not found.", data.text.slice("!bonk ".len())))
				}
			}
		}
		if (tauntenabled == true) {
			local rweapon = ply.GetActiveWeapon()
			if (data.text.tolower() == "!taunt") {
				if (ply.IsAllowedToTaunt()){
					local weapon = weapongive(ply,"tf_weapon_base", 463)
					ply.HandleTauntCommand(0)
					TauntKillandSwitch()
				} else {
					ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30Cant taunt now.")
				}
			}
			if (data.text.tolower().find("!taunt ") == 0) {
				if (strip(data.text.tolower()) !="!taunt") {
					if (data.text.slice("!taunt ".len()).tointeger() > 1) {
						if (ply.IsAllowedToTaunt()){
							local weapon = weapongive(ply,"tf_weapon_base", data.text.slice("!taunt ".len()).tointeger())
							ply.HandleTauntCommand(0)
							TauntKillandSwitch()
						} else{
							ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30Cant taunt now.")
							}
						}
					} else {
					ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30Invalid taunt index.")
				}
			}
			if (data.text.tolower().find("!spawnweapon ") == 0) {
				if (strip(data.text.tolower()) !="!spawnweapon") {
					if (data.text.slice("!spawnweapon ".len()).tointeger() > 1) {
						local weapon = Entities.CreateByClassname("tf_dropped_weapon");
						NetProps.SetPropInt(weapon, "m_Item.m_iItemDefinitionIndex", data.text.slice("!spawnweapon ".len()).tointeger());
						NetProps.SetPropInt(weapon, "m_Item.m_iEntityLevel", 5);
						NetProps.SetPropInt(weapon, "m_Item.m_iEntityQuality", 6);
						NetProps.SetPropInt(weapon, "m_Item.m_bInitialized", 1);
						weapon.SetOrigin(ply);

						weapon.DispatchSpawn();
					}
				}
			}
		}
		/*if (data.text.tolower() == "!ping") {
			ClientPrint(ply, 3, "\x0004Current Ping: \x0001" + NetProps.GetPropIntArray(Entities.FindByClassname(null,"tf_player_manager"), "m_iPing", data.userid).tostring())
		}
		*/
		if (data.text.tolower().find("!giveweapon ") == 0) {
			if (strip(data.text.tolower()) !="!giveweapon") {
			if (data.text.find("tf_weapon_") != null) {
			//ClientPrint(ply,3,data.text.find("tf_weapon_")+"||"+data.text.find(" ","!giveweapon ".len()).tostring())
			//ClientPrint(ply,3,data.text.slice(data.text.find("tf_weapon_"),data.text.find(" ","!giveweapon ".len()))+"||"+data.text.slice(data.text.find(" ","!giveweapon ".len()+1)).tointeger())
			local weaponent = data.text.slice(data.text.find("tf_weapon_"),data.text.find(" ","!giveweapon ".len()))
			local weaponindex = data.text.slice(data.text.find(" ","!giveweapon ".len()+1)).tointeger()
			weapongive(ply,weaponent,weaponindex)
				} else {
				ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30INVALID WEAPON CLASSNAME.")
				printl("[VSCRIPT] INVALID WEAPON CLASSNAME.")
				}
			}
		}
		
		if (data.text.tolower() == "!giant") {
			ply.AddCustomAttribute("max health additive penalty",4000,-1)
			ply.AddCustomAttribute("move speed bonus",0.5,-1)
			ply.AddCustomAttribute("damage force reduction",0.5,-1)
			ply.AddCustomAttribute("airblast vulnerability multiplier",0.5,-1)
			ply.AddCustomAttribute("override footstep sound set",3,-1)
			NetProps.SetPropInt(ply,"m_bIsMiniBoss",1)
			ply.SetModelScale(1.75,0)
			ply.Regenerate(false)
		}
		if (data.text.tolower() == "!deflector") {
			//Might move this to a dedicated !boss command. For now I'll just keep it like this.
			ply.SetPlayerClass(6)
			ply.Regenerate(true)
			local index = 0
			while(index <= 46) {
			local plyw = NetProps.GetPropEntityArray(ply,"m_hMyWeapons",index)
			if (plyw != null) {
			plyw.Kill()
			}
			index += 1
			}
			local weapong = SpawnEntityFromTable("tf_weapon_minigun",{})
			NetProps.SetPropInt(weapong, "m_bValidatedAttachedEntity", 1)
			NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 850)
			NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_bInitialized", 1)
			weapong.AddAttribute("damage bonus",1.5,-1)
			weapong.AddAttribute("attack projectiles",1,-1)
			weapong.AddAttribute("max health additive bonus",4700,-1)
			weapong.AddAttribute("move speed bonus",0.5,-1)
			weapong.AddAttribute("airblast vulnerability multiplier",0.3,-1)
			weapong.AddAttribute("damage force reduction",0.3,-1)
			weapong.AddAttribute("override footstep sound set",2,-1)
			ply.Weapon_Equip(weapong)	
			ply.Weapon_Switch(weapong)
			NetProps.SetPropInt(ply,"m_bIsMiniBoss",1)
			EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/heavy_boss/bot_heavy_boss.mdl",0,ply,ply)
			ply.SetModelScale(1.75,0.1)
			ply.SetHealth(5000)
			}
		if (data.text.tolower() == "!samuraidemo") {
			ply.SetPlayerClass(4)
			ply.Regenerate(true)
			local index = 0
			while(index <= 46) {
				local plyw = NetProps.GetPropEntityArray(ply,"m_hMyWeapons",index)
				if (plyw != null) {
					plyw.Kill()
				}
				index += 1
			}
			local weapong = SpawnEntityFromTable("tf_weapon_katana",{})
			NetProps.SetPropInt(weapong, "m_bValidatedAttachedEntity", 1)
			NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 357)
			NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_bInitialized", 1)
			weapong.AddAttribute("charge time increased",2,-1)
			weapong.AddAttribute("charge recharge rate increased",7,-1)
			weapong.AddAttribute("increased jump height",2.3,-1)
			weapong.AddAttribute("bot custom jump particle",1,-1)
			weapong.AddAttribute("damage bonus",15,-1)
			weapong.AddAttribute("max health additive bonus",475,-1) 
			ply.Weapon_Equip(weapong)	
			ply.Weapon_Switch(weapong)
			NetProps.SetPropInt(ply,"m_bIsMiniBoss",1)
			EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/demo_boss/bot_demo_boss.mdl",0,ply,ply)
			ply.SetModelScale(1.3,0.1)
			ply.SetHealth(650)
			}
		if (data.text.tolower() == "!sirnuke") {
			ply.SetPlayerClass(4)
			ply.Regenerate(true)
			local index = 0
			while(index <= 46) {
				local plyw = NetProps.GetPropEntityArray(ply,"m_hMyWeapons",index)
				if (plyw != null) {
				plyw.Kill()
				}
				index += 1
			}
			local weapong = SpawnEntityFromTable("tf_weapon_cannon",{})
			NetProps.SetPropInt(weapong, "m_bValidatedAttachedEntity", 1)
			NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 996)
			NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_bInitialized", 1)
			weapong.AddAttribute("grenade launcher mortar mode",0,-1)
			weapong.AddAttribute("faster reload rate",1.8,-1)
			weapong.AddAttribute("fire rate bonus",2,-1)
			weapong.AddAttribute("clip size penalty",0.5,-1)
			weapong.AddAttribute("Projectile speed increased",0.8,-1)
			weapong.AddAttribute("projectile spread angle penalty",5,-1)
			weapong.AddAttribute("damage bonus",7,-1)
			weapong.AddAttribute("damage causes airblast",1,-1)
			weapong.AddAttribute("blast radius increased",1.2,-1)
			weapong.AddAttribute("use large smoke explosion",1,-1)
			weapong.AddAttribute("move speed bonus",0.35,-1)
			weapong.AddAttribute("damage force reduction",0.4,-1)
			weapong.AddAttribute("airblast vulnerability multiplier",0.4,-1)
			weapong.AddAttribute("override footstep sound set",4,-1)
			weapong.AddAttribute("max health additive bonus",49825,-1)
			ply.Weapon_Equip(weapong)	
			ply.Weapon_Switch(weapong)
			NetProps.SetPropInt(ply,"m_bIsMiniBoss",1)
			EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/demo_boss/bot_demo_boss.mdl",0,ply,ply)
			ply.SetModelScale(1.75,0.1)
			ply.SetHealth(50000)
			}
		if (data.text.tolower() == "!superscout") {
			ply.SetPlayerClass(1)
			ply.Regenerate(true)
			local index = 0
			while(index <= 46) {
				local plyw = NetProps.GetPropEntityArray(ply,"m_hMyWeapons",index)
				if (plyw != null) {
					plyw.Kill()
				}
				index += 1
			}
			local weapong = SpawnEntityFromTable("tf_weapon_bat_fish",{})
			NetProps.SetPropInt(weapong, "m_bValidatedAttachedEntity", 1)
			NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 221)
			NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_bInitialized", 1)
			weapong.AddAttribute("move speed bonus",2,-1)
			weapong.AddAttribute("damage force reduction",0.7,-1)
			weapong.AddAttribute("airblast vulnerability multiplier",0.7,-1)
			weapong.AddAttribute("override footstep sound set",5,-1)
			weapong.AddAttribute("max health additive bonus",1075,-1)
			ply.Weapon_Equip(weapong)	
			ply.Weapon_Switch(weapong)
			NetProps.SetPropInt(ply,"m_bIsMiniBoss",1)
			EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/scout_boss/bot_scout_boss.mdl",0,ply,ply)
			ply.SetModelScale(1.75,0.1)
			ply.SetHealth(1200)
			}
		if (data.text.tolower() == "!sergeantcrits") {
			ply.SetPlayerClass(3)
			ply.Regenerate(true)
			local index = 0
			while(index <= 46) {
				local plyw = NetProps.GetPropEntityArray(ply,"m_hMyWeapons",index)
				if (plyw != null) {
					plyw.Kill()
				}
				index += 1
			}
			local weapong = SpawnEntityFromTable("tf_weapon_rocketlauncher",{})
			NetProps.SetPropInt(weapong, "m_bValidatedAttachedEntity", 1)
			NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 18)
			NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_bInitialized", 1)
			weapong.AddAttribute("damage bonus",1.5,-1)
			weapong.AddAttribute("faster reload rate",0.6,-1)
			weapong.AddAttribute("fire rate bonus",0.2,-1)
			weapong.AddAttribute("clip size upgrade atomic",7,-1)
			weapong.AddAttribute("Projectile speed increased",1.3,-1)
			weapong.AddAttribute("health regen",250,-1)
			weapong.AddAttribute("move speed bonus",0.5,-1)
			weapong.AddAttribute("damage force reduction",0.4,-1)
			weapong.AddAttribute("airblast vulnerability multiplier",0.1,-1)
			weapong.AddAttribute("override footstep sound set",3,-1)
			weapong.AddAttribute("max health additive bonus",59800,-1)
			weapong.AddAttribute("rage giving scale",0.1,-1)
			ply.AddCond(37)
			ply.Weapon_Equip(weapong)	
			ply.Weapon_Switch(weapong)
			NetProps.SetPropInt(ply,"m_bIsMiniBoss",1)
			EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/soldier_boss/bot_soldier_boss.mdl",0,ply,ply)
			ply.SetModelScale(1.9,0.1)
			ply.SetHealth(60000)
			}
		if (data.text.tolower() == "!hhh") {
			function hatman() 
			{
				ply.SetModelScale(1,0.1)
				NetProps.SetPropInt(ply,"m_bIsMiniBoss",0)
				ply.SetPlayerClass(10)
				ply.Regenerate(true)
				ply.SetPlayerClass(4)
				local index = 0
				while(index <= 46) {
					local plyw = NetProps.GetPropEntityArray(ply,"m_hMyWeapons",index)
					if (plyw != null) {
						plyw.Kill()
					}
				index += 1
				}
					local headtaker = GetModelIndex("models/weapons/c_models/c_bigaxe/c_bigaxe.mdl")
					local weapong = weapongive(ply,"tf_weapon_sword", 266)
					weapong.AddAttribute("damage bonus",10000,-1)
					weapong.AddAttribute("melee range multiplier",1.8,-1)
					weapong.AddAttribute("melee bounds multiplier",1.4,-1)
					weapong.AddAttribute("max health additive bonus",2500,-1)
					weapong.AddAttribute("move speed bonus",2,-1)
					weapong.AddAttribute("fire retardant",1,-1)
					weapong.AddAttribute("decapitate type",1,-1)
					ply.Weapon_Equip(weapong)	
					ply.Weapon_Switch(weapong)
					NetProps.SetPropInt(weapong,"m_nModelIndexOverrides.000",headtaker)
					NetProps.SetPropInt(weapong,"m_iWorldModelIndex",headtaker)
					EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/headless_hatman.mdl",0,ply,ply)
					ply.SetHealth(3000)
					ply.GetScriptScope().isheadlesshatman = 1
			}
				if(ply.ValidateScriptScope()) {
					if("isheadlesshatman" in ply.GetScriptScope()) { 
						if(ply.GetScriptScope().isheadlesshatman == 0) {
							hatman()
						} else {
							EntFireByHandle(ply,"SetCustommodelWithClassAnimations","",0,ply,ply)
							ply.Regenerate(true)
							ply.SetHealth(400)
							ply.GetScriptScope().isheadlesshatman = 0
						}
					} else {
						local plyscope = ply.GetScriptScope()
						plyscope.isheadlesshatman <- 1
						hatman()
					}
				}
			}
		if (data.text.tolower() == "!vsentrybuster") {
			NetProps.SetPropInt(ply,"m_bIsMiniBoss",1)
			ply.SetModelScale(Convars.GetFloat("tf_mvm_miniboss_scale"),0.1)
			ply.SetPlayerClass(10)
			ply.Regenerate(true)
			ply.SetPlayerClass(4)
			local index = 0
			while(index <= 46) {
				local plyw = NetProps.GetPropEntityArray(ply,"m_hMyWeapons",index)
				if (plyw != null) {
					plyw.Kill()
				}
			index += 1
			}
			local weapong = weapongive(ply,"tf_weapon_stickbomb", 307)
			weapong.AddAttribute("move speed bonus",2,-1)
			weapong.AddAttribute("damage force reduction",0.5,-1)
			weapong.AddAttribute("airblast vulnerability multiplier",0.5,-1)
			weapong.AddAttribute("override footstep sound set",7,-1)
			weapong.AddAttribute("cannot be backstabbed",1,-1)
			weapong.AddAttribute("max health additive bonus",2500 - 175,-1)
			ply.Weapon_Equip(weapong)	
			ply.Weapon_Switch(weapong)
			EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/demo/bot_sentry_buster.mdl",0,ply,ply)
			ply.SetHealth(2500)
			EmitAmbientSoundOn("mvm/sentrybuster/mvm_sentrybuster_intro.wav", 1, 0, 100, ply)
			EmitAmbientSoundOn("mvm/sentrybuster/mvm_sentrybuster_loop.wav", 1, 0, 100, ply)
			EntFireByHandle(ply,"runscriptfile","chatcommands/sentrybuster",0,ply,ply)
		}
	/*	if (data.text.tolower() == "!joinwhite") {
				local rememberedpos = ply.GetOrigin()
				ply.ForceChangeTeam(1, true)
				NetProps.SetPropInt(ply,"m_iTeamNum",1)
				ply.ForceRespawn()
				ply.SetOrigin(rememberedpos)
				// VERY UNSTABLE, LEADS TO CRASHES
			}*/
		if (data.text.tolower() == "!disablekick") {
				NetProps.SetPropInt(ply,"m_autoKickDisabled",1)
			}
		if (data.text.tolower() == "!toolgun") {
			addtoolgun(ply)
		}
		if (data.text.tolower() == "!tauntlist") {
				local tauntfile = FileToString("chatcommands/tauntlist.txt")
				local taunts = split(tauntfile,"\n")
				foreach (item in taunts) {
				ClientPrint(ply,2,item)
				}
				ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffOutput In Console")
			}
			if (data.text.tolower() == "!giveweaponcustom"||data.text.tolower() == "!givecustomweapon") {
			ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffUsage: !giveweaponcustom batsaber")
			}
		if (data.text.tolower().find("!giveweaponcustom ") == 0||data.text.tolower().find("!givecustomweapon ") == 0) { //This code is terrible but it gets the job done.
		 if (strip(data.text.tolower()) != "!giveweaponcustom"||strip(data.text.tolower()) != "!givecustomweapon") {
			giveweaponcustomCHAT(ply,data)
				}
			}
			if (data.text.tolower() == "!customweaponlist") {
				local weaponlist = FileToString(weaponlistname)
				local weaponsinlist = split(weaponlist,"\n")
				local weaponnames = ""
				foreach (item in weaponsinlist) {
					if (item.find("*") != null) {
						weaponnames = weaponnames + item.slice(item.find("*") + 1,item.find("*", 1)) + ","
					}
				}
				local weaponnamesarray = split(weaponnames,",")
				ClientPrint(ply,2,"======================")
				foreach (item in weaponnamesarray) {
					ClientPrint(ply,2,item.tostring())
				}
				ClientPrint(ply,2,"======================")
				ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffOutput In Console")
			}
			if (data.text.tolower() == "!tank") {
				EntFireByHandle(ply,"runscriptfile","chatcommands/tank",0,ply,ply)
				//Prevents the tank suddenly loosing controls on script refresh.
			}
			if (data.text.tolower() == "!identify") {
			local trace =
			{
				start = ply.EyePosition(),
				end = ply.EyePosition() + (ply.EyeAngles().Forward() * 32768.0),
				ignore = ply
			};
		
			if (!TraceLineEx(trace))
			{
				ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30No Entities Present.");
				return null;
			}
			if (Entities.FindInSphere(null,trace.pos,5) != null) {
			ClientPrint(ply,3,Entities.FindInSphere(null,trace.pos,5).tostring())
			} else {
				ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30No Entities Present.");
				}
			}
			if (data.text.tolower() == "!help") {
				ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ff!dropweapon !tp !fp !noclip !joinblue !joinblu !powerplay !buffweapon !kill !deploybomb !bonk !taunt !hhh !setclass !giveweapon !deflector !giant !sirnuke !sergeantcrits !customweaponlist !giveweaponcustom !superscout !tank")
				ClientPrint(ply,3,"53b3ff!noweapons !nohats !randomweapon !randomloadout !addattribute !decoy !setfov !vsentrybuster !toolgun")
				//ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ff!taunt 123 Change 123 to the taunt id. Can be found in tauntlist.txt")
				//ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ff!giveweapon tf_weapon_minigun 850. First value is the weapon classname, second value is the weapon item definition index.")
			}
			if (data.text.tolower() == "!noweapons") {
			local index = 0
			while(index <= 46) {
				local plyw = NetProps.GetPropEntityArray(ply,"m_hMyWeapons",index)
				if (plyw != null) {
					plyw.Kill()
				}
				index += 1
				}
			}
			if (data.text.tolower() == "!nohats") {
			local wearable = null
			if (Entities.FindByClassname(null,"tf_wearable") != null) {
			while(wearable = Entities.FindByClassname(wearable,"tf_wearable*")) {
				if (NetProps.GetPropEntity(wearable,"m_hOwnerEntity") == ply) {
					wearable.Kill()
						}
					}
				}
			if (Entities.FindByClassname(null,"tf_powerup_bottle") != null) {
			while(wearable = Entities.FindByClassname(wearable,"tf_powerup_bottle")) {
				if (NetProps.GetPropEntity(wearable,"m_hOwnerEntity") == ply) {
					wearable.Kill()
						}
					}
				}
			}
			if (data.text.tolower() == "!noloadout") {
			local wearable = null
			local bottle = null
			local index = 0
			if (Entities.FindByClassname(null,"tf_wearable*") != null) {
			while(wearable = Entities.FindByClassname(wearable,"tf_wearable*")) {
				if (NetProps.GetPropEntity(wearable,"m_hOwnerEntity") == ply) {
					wearable.Kill()
						}
					}
				}
			if (Entities.FindByClassname(null,"tf_powerup_bottle") != null) {
			while(wearable = Entities.FindByClassname(wearable,"tf_powerup_bottle")) {
				if (NetProps.GetPropEntity(wearable,"m_hOwnerEntity") == ply) {
					wearable.Kill()
						}
					}
				}
			while(index <= 46) {
				local plyw = NetProps.GetPropEntityArray(ply,"m_hMyWeapons",index)
				if (plyw != null) {
					plyw.Kill()
				}
				index += 1
				}
			}
			if (data.text.tolower() == "!meem") {
				if (ply.GetPlayerClass() == 1) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/props_training/target_scout.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 2) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/props_training/target_sniper.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 3) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/props_training/target_soldier.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 4) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/props_training/target_demoman.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 5) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/props_training/target_medic.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 6) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/props_training/target_heavy.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 7) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/props_training/target_pyro.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 8) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/props_training/target_spy.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 9) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/props_training/target_engineer.mdl",0,ply,ply)
				}
				if(ply.GetModelName().find("models/props_training/target_") == 0) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","",0,ply,ply)
				}
				ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffToggled !meem on you successfully.")
			}
			if (data.text.tolower() == "!robot") {
				if(ply.GetModelName().find("models/bots/") == 0) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","",0,ply,ply)
				} else {
				if (ply.GetPlayerClass() == 1) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/scout/bot_scout.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 2) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/sniper/bot_sniper.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 3) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/soldier/bot_soldier.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 4) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/demo/bot_demo.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 5) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/medic/bot_medic.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 6) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/heavy/bot_heavy.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 7) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/pyro/bot_pyro.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 8) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/spy/bot_spy.mdl",0,ply,ply)
				}
				if (ply.GetPlayerClass() == 9) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/engineer/bot_engineer.mdl",0,ply,ply)
					}
				}
				ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffToggled !robot on you successfully.")
			}
			if (data.text.tolower() == "!afk") {
				if (ply.GetMoveType() != 0 && ply.GetFlags() < 8388608) {
					ply.SetMoveType(0, 0)
					ply.AddSolidFlags(4)
					ply.AddFlag(32768)
					ply.AddFlag(65536)
					ply.AddFlag(8388608)
					NetProps.SetPropInt(ply,"m_autoKickDisabled",1)
				}
				else {
					ply.SetMoveType(2, 0)
					ply.RemoveSolidFlags(4)
					ply.RemoveFlag(32768)
					ply.RemoveFlag(65536)
					ply.RemoveFlag(8388608)
					NetProps.SetPropInt(ply,"m_autoKickDisabled",0)
				}
			}
			if (data.text.tolower().find("!setfov") == 0) {
			local substring = data.text.slice("!setfov ".len()).tointeger()
			if (substring > 179||substring < 1) {
				return ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30Invalid FOV range. Available range 1-179")
			}
			NetProps.SetPropInt(ply,"m_iFOV",substring)
			ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffFOV has been set to " + substring + ".")
			}
			if (data.text.tolower().find("!addattribute ") == 0) {
				if (data.text.tolower().find("'") == null||data.text.tolower().find("'",data.text.tolower().find("'")+1) < 1 || data.text.tolower().find("'",data.text.tolower().find("' ")+1)) {
					return ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffUsage: !addattribute 'hand scale' 2");
				}
				if (ply.GetActiveWeapon() == null) {
					return ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30Player is currently not holding a weapon.");
				}
				local attribname = data.text.slice(data.text.tolower().find("\'")+1,data.text.tolower().find("\'",data.text.tolower().find("\'")+1))
				local attribvalue = data.text.slice(data.text.tolower().find("\'",data.text.tolower().find("\'")+1)+2).tofloat()
				if(attribname == "bullets per shot bonus" && attribvalue > 50) {
					attribvalue = 50
				}
				ply.GetActiveWeapon().AddAttribute(attribname,attribvalue,-1)
				ply.GetActiveWeapon().ReapplyProvision()
			}
			if (data.text.tolower().find("!warpaint ") == 0) {
				if (data.text.tolower().find("'") == null||data.text.tolower().find("'",data.text.tolower().find("'")+1) < 1 || data.text.tolower().find("'",data.text.tolower().find("' ")+1)) {
					return ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffUsage: !addattribute 'hand scale' 2");
				}
				if (ply.GetActiveWeapon() == null) {
					return ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30Player is currently not holding a weapon.");
				}
				local attribname = data.text.slice(data.text.tolower().find("\'")+1,data.text.tolower().find("\'",data.text.tolower().find("\'")+1))
				local attribvalue = data.text.slice(data.text.tolower().find("\'",data.text.tolower().find("\'")+1)+2).tofloat()
				if(attribname == "bullets per shot bonus" && attribvalue > 50) {
					attribvalue = 50
				}
				ply.GetActiveWeapon().AddAttribute(attribname,attribvalue,-1)
				ply.GetActiveWeapon().ReapplyProvision()
			}
			if (data.text.tolower() == "!decoy") {	
				local decoy = Entities.CreateByClassname("bot_npc_decoy")
				decoy.SetAbsAngles(ply.GetAbsAngles())
				decoy.SetOrigin(ply.GetOrigin())
				decoy.SetOwner(ply)
				Entities.DispatchSpawn(decoy)
				decoy.SetModelSimple(ply.GetModelName())
				decoy.SetModelScale(ply.GetModelScale(),0)
			}
			/*if (data.text.tolower() == "!testcommand") {
			//give wearable, might be useful later.
			local hat = Entities.CreateByClassname("tf_wearable")
			NetProps.SetPropInt(hat,"m_bValidatedAttachedEntity",1)
			NetProps.SetPropInt(hat,"m_AttributeManager.m_Item.m_iItemDefinitionIndex",126)
			NetProps.SetPropInt(hat, "m_iTeamNum", NetProps.GetPropInt(ply,"m_iTeamNum"))
			NetProps.SetPropInt(hat, "m_AttributeManager.m_Item.m_bInitialized", 1)
			hat.SetOwner(ply)
			Entities.DispatchSpawn(hat)
			NetProps.SetPropEntity(hat,"moveparent",ply)
			} */
			if (data.text.tolower() == "!randomweapon") {
				giverandomweapon(ply,true)
			}
			if (data.text.tolower() == "!randomloadout") {
				giverandomloadout(ply,true)
			}
			if (data.text.tolower() == "!score") {
				local i = 0
				while(i < 100) {
					local score = SpawnEntityFromTable("mapobj_cart_dispenser",{})
					EntFireByHandle(score,"RemoveHealth", "380", 0, ply, ply)
					i++
					}
				}
			}
		}
	}	
	function OnGameEvent_player_spawn(data) {
		local ply = GetPlayerFromUserID(data.userid);
		//NetProps.SetPropInt(ply,"m_iFOV",Convars.GetClientConvarValue("fov_desired",ply.GetEntityIndex()).tointeger()) //breaks !setfov and fixes spectator fov sync
		if (IsMannVsMachineMode() && ply.GetTeam() == 3 && IsPlayerABot(ply) == false) {
		//handles the skin change for the players on blue
			if (ply.GetPlayerClass() == 1) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/scout/bot_scout.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 2) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/sniper/bot_sniper.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 3) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/soldier/bot_soldier.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 4) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/demo/bot_demo.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 5) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/medic/bot_medic.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 6) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/heavy/bot_heavy.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 7) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/pyro/bot_pyro.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 8) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/spy/bot_spy.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 9) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/engineer/bot_engineer.mdl",0,ply,ply)
			}
			ply.AddFlag(512)
		}
		if(IsMannVsMachineMode() && ply.GetTeam() == 2 && NetProps.GetPropString(ply,"m_szNetworkIDString").len() > 3){
			ply.RemoveFlag(512)
		}
		if (IsMannVsMachineMode() && ply.GetTeam() == 2 && IsPlayerABot(ply) == false) {
			EntFireByHandle(ply,"SetCustommodelWithClassAnimations","",0,ply,ply)
		}
		
	}
	function OnGameEvent_post_inventory_application(data) {
		local ply = GetPlayerFromUserID(data.userid);
		if (IsMannVsMachineMode() && ply.GetTeam() == 3 && IsPlayerABot(ply) == false) {
		//handles the skin change for the players on blue. (when the player touches a func_regenerate)
			if (ply.GetPlayerClass() == 1) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/scout/bot_scout.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 2) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/sniper/bot_sniper.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 3) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/soldier/bot_soldier.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 4) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/demo/bot_demo.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 5) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/medic/bot_medic.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 6) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/heavy/bot_heavy.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 7) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/pyro/bot_pyro.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 8) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/spy/bot_spy.mdl",0,ply,ply)
			}
			if (ply.GetPlayerClass() == 9) {
				EntFireByHandle(ply,"SetCustommodelWithClassAnimations","models/bots/engineer/bot_engineer.mdl",0,ply,ply)
			}
			ply.AddFlag(512)
		}
		if(IsMannVsMachineMode() && ply.GetTeam() == 2 && NetProps.GetPropString(ply,"m_szNetworkIDString").len() > 3){
			ply.RemoveFlag(512)
		}
		if (IsMannVsMachineMode() && ply.GetTeam() == 2 && IsPlayerABot(ply) == false) {
			EntFireByHandle(ply,"SetCustommodelWithClassAnimations","",0,ply,ply)
		}
	}
	function OnGameEvent_player_activate(data) {
		local ply = GetPlayerFromUserID(data.userid);
		ClientPrint(ply,3,"fbeccb[VSCRIPT]53b3ff Type !help to see a list of commands.")
			if (Convars.GetClientConvarValue("cl_team",ply.GetEntityIndex()) == "disableautokick") {
				NetProps.SetPropInt(ply,"m_autoKickDisabled",1)
			}
	}
	function TauntKillandSwitch()
	{
		ply.Weapon_Switch(rweapon)
	}
	function OnGameEvent_player_connect_client(data) {
		local idlist = FileToString("chatcommands/steamids.txt")
		local ids = split(idlist,"\n")
		idlist = ""
		foreach(index, idss in ids){
			if(index != 0){
				idlist += idss + "\n"
			}
		}
		local output = ""
		if (data.networkid == ownersteamid) {
			if(announcejoins){
				ClientPrint(null,3,"fbeccb[VSCRIPT] 9bcdffServer Owner Joined!")
				printl("[VSCRIPT] Server Owner Joined!")
			} else {
				printl("[VSCRIPT] Server Owner Joined! (hidden)")
			}
		} else if(validateadmin(null, data.networkid, false)) {
			if(announcejoins){
				ClientPrint(null,3,"fbeccb[VSCRIPT] 9bcdffAdmin Joined!")
				printl("[VSCRIPT] Admin Joined!")
			} else {
				printl("[VSCRIPT] Admin Joined! (hidden)")
			}
		}
		if (data.userid != "BOT") {
			StringToFile("chatcommands/steamids.txt", "Generated on: " + getDateString(true) + "\n" + idlist + data.userid + " $ " + data.networkid + " & " + data.name + "\n")
		}
	}
	__CollectGameEventCallbacks(this)
	Say(null,"Type !help to see a list of commands.",false)
	//Who needs sourcemod?
}