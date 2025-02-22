local cc_scope = this

local classtable =
{
	"scout" : 1
	"sniper" : 2
	"soldier" : 3
	"demoman" : 4
	"medic" : 5
	"heavyweapons" : 6
	"pyro" : 7
	"spy" : 8
	"engineer" : 9
	"civillian" : 10
	"civilian" : 10
}

local meem_models =
[
	"models/props_training/target_scout.mdl",
	"models/props_training/target_sniper.mdl",
	"models/props_training/target_soldier.mdl",
	"models/props_training/target_demoman.mdl",
	"models/props_training/target_medic.mdl",
	"models/props_training/target_heavy.mdl",
	"models/props_training/target_pyro.mdl",
	"models/props_training/target_spy.mdl",
	"models/props_training/target_engineer.mdl"
]

enum particle 
{
	PATTACH_ABSORIGIN,
	PATTACH_ABSORIGIN_FOLLOW,
	PATTACH_CUSTOMORIGIN,
	PATTACH_POINT,
	PATTACH_POINT_FOLLOW,
	PATTACH_WORLDORIGIN,
	PATTACH_ROOTBONE_FOLLOW,
};


function MCC_noclip(...)
{
	//if(vargv.len() < 2)
	//{
		self.SetMoveType(self.GetMoveType() == 8 ? 2 : 8, 0)
	//}
	/*else
	{
		local input = ""
		foreach(i, item in vargv) { if(i == vargv.len() - 1) break; input += item + " "}
		local players = util_findplayer(input)
		if(players.len() == 0)
			return ClientPrint(self, 3, "\x01[VSCRIPT]d13b30 No matching target found.")
		foreach(player in players)
		{
			player.SetMoveType(player.GetMoveType() == 8 ? 2 : 8, 0)
		}
	}*/
}

function MCC_bonk(...)
{
	local length = 1
	self.RemoveCond(15)
	if(vargv.len() > 1)
	{
		try {length = vargv[0].tofloat()}catch(e){}
	}
	self.StunPlayer(length, 0, 2, self)
}

function MCC_setclass(...)
{
	if(vargv.len() < 2)
	{
		ClientPrint(self, 3, "\x01[VSCRIPT]53b3ff Use !help setclass for more info.")
	}
	else
	{
		local input = ""
		foreach(i, item in vargv) { if(i == vargv.len() - 1) break; input += item + " "}
		input = rstrip(input.tolower())
		foreach(name, value in classtable)
		{
			if(name.find(input) == 0)
			{
				RemoveCustomAttributes(self)
				self.SetIsMiniBoss(false)
				self.SetModelScale(1, 0)
				self.SetPlayerClass(value)
				NetProps.SetPropInt(self, "m_Shared.m_iDesiredPlayerClass", value)
				self.Regenerate(true)
				self.SetHealth(self.GetMaxHealth())
				self.AcceptInput("SetCustomModelWithClassAnimations", "", false, false)
				return ClientPrint(self, 3, "\x01[VSCRIPT]53b3ff " + format("Player's class has been set to '%s'.", name))
			}
		}
		return ClientPrint(self, 3, "\x01[VSCRIPT]d13b30 "+format("no class found named '%s'.", input))
	}
}

function MCC_toggletp(...)
{
	self.SetForcedTauntCam(NetProps.GetPropInt(self, "m_nForceTauntCam") ? 0 : 1)
}

function MCC_tp(...)
{
	self.SetForcedTauntCam(1)
}

function MCC_fp(...)
{
	self.SetForcedTauntCam(0)
}

function MCC_vtaunt(...)
{
	if(self.IsAllowedToTaunt())
	{
		
		local eye_angles = self.EyeAngles()
		local input = 463
		local taunt_to_search = ""
		foreach(i, item in vargv) { if(i == vargv.len() - 1) break; taunt_to_search += item + " "}
		taunt_to_search = rstrip(taunt_to_search.tolower())
		if(vargv.len() > 1)
		{
			try{input = vargv[0].tointeger()}catch(e)
			{
				foreach(name, data in cc_scope.MCCL_taunt)
				{
					if(name.find(taunt_to_search) != null)
					{
						input = cc_scope.MCCL_taunt[name]
						break;
					}
				}
			}
		}
		local weapon = MCCW_giveweaponfromtable(
		{
			"item_class" : "tf_weapon_base"
			"item_index" : input
			"replace" : false
		})
		weapon.ValidateScriptScope()
		local wepscope = weapon.GetScriptScope()
		wepscope.owner <- self
		wepscope.oldweapon <- self.GetActiveWeapon()
		self.Weapon_Switch(weapon)
		NetProps.SetPropVector(self, "pl.v_angle", Vector(90, 0, 0))
		self.HandleTauntCommand(0)
		NetProps.SetPropVector(self, "pl.v_angle", eye_angles + Vector())
		weapon.AcceptInput("runscriptfile", "chatcommands_/taunt", self, self)
	}
	else 
	{
		ClientPrint(self, 3, "\x01[VSCRIPT] d13b30" + format("You cannot taunt now.", input))
	}
}

function MCC_setfov(...)
{
	if(vargv.len() < 2)
	{
		ClientPrint(self, 3, "\x01[VSCRIPT]53b3ff Use !help setfov for more info.")
	}
	else
	{
		local input = 90
		try {input = vargv[0].tointeger()}catch(e){}
		NetProps.SetPropInt(self, "m_iFOV", input)
	}
}

function MCC_score(...)
{
	if(vargv.len() < 2)
	{
		ClientPrint(self, 3, "\x01[VSCRIPT]53b3ff Use !help score for more info.")
	}
	else
	{
		local input = 1
		try {input = vargv[0].tointeger()}catch(e){}
		SendGlobalGameEvent("player_escort_score", {player = self.entindex() points = input})
	}
}

function MCC_tauntlist(...)
{
	foreach(name, index in MCCL_taunt)
	{
		ClientPrint(self, 2, "[" + index.tostring() + "] " + name)
	}
	ClientPrint(self, 3, "[VSCRIPT] Output in console.")
}

function MCC_disablekick(...)
{
	NetProps.SetPropInt(self, "m_autoKickDisabled", 1)
}

function MCC_afk(...)
{
	if(!("MCCD_afk" in this)) 
	{
		MCCD_afk <- true
		self.SetMoveType(0, 0)
		self.AddEFlags(1)
		self.AddCustomAttribute("no_attack", 1, -1)
		self.AddCustomAttribute("dmg taken increased", 0.0, -1)
		NetProps.SetPropInt(self, "m_autoKickDisabled", 1)
	}
	else 
	{
		self.SetMoveType(2, 0)
		self.RemoveEFlags(16777217)
		self.RemoveCustomAttribute("no_attack")
		self.RemoveCustomAttribute("dmg taken increased")
		NetProps.SetPropInt(self, "m_autoKickDisabled", 0)
		delete this["MCCD_afk"]
	}
	ClientPrint(self, 3, "[VSCRIPT] toggled afk.")
}

function MCC_hhh(...)
{
	local activewep = self.GetActiveWeapon()
	activewep.ValidateScriptScope()
	local wepscope = activewep.GetScriptScope()
	if("MCCT_headless_hatman" in wepscope)
	{
		return self.Regenerate(true)
	}
	self.SetModelScale(1, 0.1)
	self.SetPlayerClass(10)
	self.Regenerate(true)
	self.SetPlayerClass(4)
	self.RemoveCond(7)
	local hhhh = Convars.GetFloat("tf_halloween_bot_health_base")
	MCCW_giveweaponfromtable(
	{
		"item_class" : "tf_weapon_builder"
		"forced_classname" : "tf_weapon_base"
		"item_index" : 5
		"replace" : false
		"attributes" :
		{
			"max health additive bonus" : hhhh - 150
			"move speed bonus" : Convars.GetFloat("tf_halloween_bot_speed") / 280
			"fire retardant" : 1
			"afterburn immunity" : 1
			"cancel falling damage" : 1
			"airblast vulnerability multiplier" : 0.0
			"damage force increase" : 0.0
			"cannot be backstabbed" : 1
			"voice pitch scale" : 0.0
		}
		"buildables" : {}
	})
	local weapon = MCCW_giveweaponfromtable(
	{
		"item_text" : "You are the Headless Horseless Horsemann!"
		"item_class" : "tf_weapon_sword"
		"item_index" : 266
		"attributes" :
		{
			"fire rate bonus" : 1.25
			"melee range multiplier" : Convars.GetFloat("tf_halloween_bot_attack_range") / 72
			"apply look velocity on damage" : 250
			"damage bonus" : 5
		}
	})
	self.Weapon_Switch(weapon)
	self.SetHealth(hhhh)
	weapon.ValidateScriptScope()
	weapon.GetScriptScope().owner <- self
	NetProps.SetPropInt(self, "m_Shared.m_iNextMeleeCrit", -2)
	weapon.AcceptInput("runscriptfile", "chatcommands_/headless_hatman", self, self)
	self.AcceptInput("dispatcheffect", "ParticleEffectStop", self, self)
	EntFireByHandle(self, "SetCustomModelWithClassAnimations", "models/bots/headless_hatman.mdl", 0.0, null, null)
	EntFireByHandle(self, "runscriptcode", "SpawnParticle(self, `ghost_pumpkin`, ``, particle.PATTACH_ABSORIGIN_FOLLOW)", 0.0, self, self)
	EntFireByHandle(self, "runscriptcode", "SpawnParticle(self, `halloween_boss_eye_glow`, `lefteye`, particle.PATTACH_POINT_FOLLOW)", 0.0, self, self)
	EntFireByHandle(self, "runscriptcode", "SpawnParticle(self, `halloween_boss_eye_glow`, `righteye`, particle.PATTACH_POINT_FOLLOW)", 0.0, self, self)
}

function MCC_meem(...)
{
	if(meem_models.find(self.GetModelName()) == null)
	{
		self.SetCustomModelWithClassAnimations(meem_models[self.GetPlayerClass() - 1])
	}
	else
	{
		self.AcceptInput("SetCustomModelWithClassAnimations", "", false, false)
	}
	ClientPrint(self, 3, "\x01[VSCRIPT]53b3ff Successfully toggled target dummy model.")
}

function MCC_steamid(...)
{
	ClientPrint(self, 3, "SteamID3: " + MCCD_steamid)
}

function MCC_vscript(...)
{
	local input = ""
	foreach(i, item in vargv) { if(i == vargv.len() - 1) break; input += item + " "}
	input = rstrip(input)
	printl(format("[VSCRIPT] ran vscript \"%s\"", input))
	self.AcceptInput("runscriptcode", "try{" + input + "}catch(e){ClientPrint(self,3,`\x01[VSCRIPT] An error has occurred, check the console.`);ClientPrint(self,2,`AN ERROR HAS OCCURRED [`+e+`]`)}", null, null)
}

function MCC_decoy(...)
{
	local decoy = Entities.CreateByClassname("bot_npc_decoy")
	local angles = self.GetAbsAngles()
	decoy.SetAbsAngles(angles)
	decoy.SetOrigin(self.GetOrigin())
	decoy.SetOwner(self)
	Entities.DispatchSpawn(decoy)
	decoy.SetModelSimple(self.GetModelName())
	decoy.SetModelScale(self.GetModelScale(), 0)
	decoy.ValidateScriptScope()
	decoy.GetScriptScope().MCCT_decoy <- function()
	{
		if(CBaseEntity.IsValid.call(self))
		{
			self.SetAbsAngles(angles)
			EntFireByHandle(self, "runscriptcode", "if(`MCCT_decoy` in this)MCCT_decoy()", 0.01, null, null)
		}
	}
	decoy.GetScriptScope().MCCT_decoy()
}

/*
function MCC_togglethirdperson(...)
{
	self.SetForcedTauntCam(NetProps.GetPropBool(self, "m_nForceTauntCam") ? false : true)
}

function MCC_thirdperson(...)
{
	self.SetForcedTauntCam(true)
}

function MCC_firstperson(...)
{
	self.SetForcedTauntCam(true)
}
*/