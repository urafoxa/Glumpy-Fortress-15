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

local robot_models =
[
	"models/bots/scout/bot_scout.mdl",
	"models/bots/sniper/bot_sniper.mdl",
	"models/bots/soldier/bot_soldier.mdl",
	"models/bots/demo/bot_demo.mdl",
	"models/bots/medic/bot_medic.mdl",
	"models/bots/heavy/bot_heavy.mdl",
	"models/bots/pyro/bot_pyro.mdl",
	"models/bots/spy/bot_spy.mdl",
	"models/bots/engineer/bot_engineer.mdl"
]

local robot_giant_models =
[
	"models/bots/scout_boss/bot_scout_boss.mdl",
	"models/bots/sniper/bot_sniper.mdl",
	"models/bots/soldier_boss/bot_soldier_boss.mdl",
	"models/bots/demo_boss/bot_demo_boss.mdl",
	"models/bots/medic/bot_medic.mdl",
	"models/bots/heavy_boss/bot_heavy_boss.mdl",
	"models/bots/pyro_boss/bot_pyro_boss.mdl",
	"models/bots/spy/bot_spy.mdl",
	"models/bots/engineer/bot_engineer.mdl"
]

function MCC_vsentrybuster(...)
{
	local activewep = self.GetActiveWeapon()
	activewep.ValidateScriptScope()
	local wepscope = activewep.GetScriptScope()
	if("MCCT_tauntcheck_buster" in wepscope)
	{
		self.SetModelScale(1, 0.1)
		return self.Regenerate(true)
	}
	self.SetIsMiniBoss(true)
	self.SetModelScale(Convars.GetFloat("tf_mvm_miniboss_scale"),0.1)
	self.SetPlayerClass(10)
	self.Regenerate(true)
	self.SetPlayerClass(4)	
	MCCW_giveweaponfromtable(
	{
		"item_class" : "tf_weapon_builder"
		"forced_classname" : "tf_weapon_base"
		"item_index" : 5
		"replace" : false
		"attributes" :
		{
			"move speed bonus" : 2
			"damage force reduction" : 0.5
			"airblast vulnerability multiplier" : 0.5
			"override footstep sound set" : 7
			"cannot be backstabbed" : 1
			"max health additive bonus" : 2325
		}
		"buildables" : {}
	})
	local weapon = MCCW_giveweaponfromtable(
	{
		"item_text" : "You are the Sentry Buster! Taunt to explode!"
		"item_class" : "tf_weapon_stickbomb"
		"item_index" : 307
	})
	self.Weapon_Switch(weapon)
	EntFireByHandle(self, "SetCustomModelWithClassAnimations", "models/bots/demo/bot_sentry_buster.mdl", 0.0, null, null)
	self.SetHealth(2500)
	NetProps.SetPropInt(self, "m_debugOverlays", 33554432)
	EmitAmbientSoundOn("MVM.SentryBusterIntro", 1, 0, 100, self)
	EmitAmbientSoundOn("MVM.SentryBusterLoop", 1, 0, 100, self)
	weapon.ValidateScriptScope()
	weapon.GetScriptScope().owner <- self
	weapon.AcceptInput("runscriptfile", "chatcommands_/sentrybuster", self, self)
}

function MCC_joinblue(...)
{
	if(IsMannVsMachineMode())
	{
		//NetProps.SetPropInt(self, "m_nBotSkill", -1337)
		self.SetCustomModelWithClassAnimations(robot_models[self.GetPlayerClass() - 1])
		local gamerules = Entities.FindByClassname(null, "tf_gamerules")
		NetProps.SetPropBool(gamerules, "m_bPlayingMannVsMachine", false)
		self.ForceChangeTeam(3, true)
		NetProps.SetPropBool(gamerules, "m_bPlayingMannVsMachine", true)
		self.ForceRespawn()
		//NetProps.SetPropInt(self, "m_nBotSkill", 1)
	} 
	else 
	{
		ClientPrint(self, 3, "\x01[VSCRIPT]d13b30 This command is only available for use in MVM.")
	}
}

function MCC_robot(...)
{
	if(robot_models.find(self.GetModelName()) == null)
	{
		self.SetCustomModelWithClassAnimations(robot_models[self.GetPlayerClass() - 1])
		// Rave robots dammit
		/*local eye_1 = SpawnEntityFromTable("info_particle_system",
		{
			cpoint1 = "!self"
			effect_name  = "bot_eye_glow"
			start_active = true
		})
		eye_1.AcceptInput("setparent", "!activator", self, self)
		eye_1.AcceptInput("setparentattachment", "eye_1", self, self)
		
		local eye_2 = SpawnEntityFromTable("info_particle_system",
		{
			cpoint1 = "!self"
			effect_name  = "bot_eye_glow"
			start_active = true 
		})
		eye_2.AcceptInput("setparent", "!activator", self, self)
		eye_2.AcceptInput("setparentattachment", "eye_2", self, self)*/
	}
	else
	{
		self.AcceptInput("SetCustomModelWithClassAnimations", "", false, false)
	}
	ClientPrint(self, 3, "\x01[VSCRIPT] Successfully toggled robot model.")
}

function MCC_giant(...)
{
	if(self.IsMiniBoss())
	{
		RemoveCustomAttributes(self)
		self.SetIsMiniBoss(false)
		self.SetModelScale(1, 0)
		self.SetHealth(self.GetMaxHealth())
		self.AcceptInput("SetCustomModelWithClassAnimations", "", false, false)
		ClientPrint(self, 3, "\x01[VSCRIPT] Successfully toggled giant robot mode.")
		return self.Regenerate(false)
	}
	self.SetCustomModelWithClassAnimations(robot_giant_models[self.GetPlayerClass() - 1])
	self.AddCustomAttribute("max health additive penalty",4000,-1)
	self.AddCustomAttribute("move speed bonus", 0.5, -1)
	self.AddCustomAttribute("damage force reduction", 0.5, -1)
	self.AddCustomAttribute("airblast vulnerability multiplier", 0.5, -1)
	self.AddCustomAttribute("override footstep sound set", 3, -1)
	self.SetIsMiniBoss(true)
	self.SetModelScale(1.75, 0)
	self.Regenerate(false)
	ClientPrint(self, 3, "\x01[VSCRIPT] Successfully toggled giant robot mode.")
}

function MCCB_becomebossfromtable(data)
{
	local attributes = {}
	RemoveCustomAttributes(self)
	self.SetModelScale(1, 0)
	self.SetPlayerClass(10)
	self.Regenerate(true)
	if("class" in data)
	{
		local classname = data["class"]
		foreach(name, value in classtable)
		{
			if(name.find(classname) == 0)
			{
				self.SetPlayerClass(value)
			}
		}
	}
	if("scale" in data)
	{
		self.SetModelScale(data.scale, 0.1)
	}
	if("attributes" in data)
	{
		attributes = data.attributes
	}
	if("health" in data)
	{
		// deal with the edge case that they might include "set bonus: max health additive bonus" in the attributes for some reason.
		local desiredhealth = data.health - self.GetMaxHealth()
		if("set bonus: max health additive bonus" in attributes)
		{
			desiredhealth -= attributes["set bonus: max health additive bonus"]
		}
		attributes["set bonus: max health additive bonus"] <- desiredhealth
	}
	if("weapons" in data)
	{
		foreach(weapondata in data.weapons)
		{
			self.Weapon_Switch(MCCW_giveweaponfromtable(weapondata))
		}
	}
	if(attributes.len() > 0)
	{
		MCCW_giveweaponfromtable(
		{
			"item_class" : "tf_weapon_builder"
			"forced_classname" : "tf_weapon_base"
			"item_index" : 5
			"replace" : false
			"attributes" : attributes
			"buildables" : {}
		})
	}
	self.SetHealth(self.GetMaxHealth())
	if("model" in data)
	{
		self.SetCustomModelWithClassAnimations(data.model)
	}
}

function MCC_boss(...)
{
	if(vargv.len() < 2)
	{
		ClientPrint(self, 3, "\x01[VSCRIPT]53b3ff Use !help boss for more info.")
	}
	else
	{
		//IncludeScript("chatcommands_/data/bosses.nut", cc_scope)
		local input = ""
		foreach(i, item in vargv) { if(i == vargv.len() - 1) break; input += item + " "}
		input = rstrip(input.tolower())
		foreach(name, data in cc_scope.MCCB_custom)
		{
			if(name == input)
			{
				MCCB_becomebossfromtable(data)
				return ClientPrint(self, 3, "\x01[VSCRIPT]53b3ff " + format("You are now the boss '%s'.", name))
			}
		}
		return ClientPrint(self, 3, "\x01[VSCRIPT]d13b30 " + format("No boss found named '%s'.", input))
	}
}

function MCC_tank(...)
{
	if("MCCD_tank" in this)
	{
		if(CBaseEntity.IsValid.call(MCCD_tank))
		{
			MCCD_tank = null
			return self.ForceChangeTeam(2, false)
		}
	}
	local tank = SpawnEntityFromTable("tank_boss",{speed = 0 modelscale = 1 origin = self.GetOrigin() angles = self.GetAbsAngles() health = 8000})
	tank.ValidateScriptScope()
	tank.GetScriptScope().owner <- self
	tank.AcceptInput("runscriptfile", "chatcommands_/tank", null, null)
}

function MCC_bosslist(...)
{
	//IncludeScript("chatcommands_/data/bosses.nut", cc_scope)
	ClientPrint(self, 2, "========BOSSES========")
	foreach(name, data in cc_scope.MCCB_custom)
	{
		ClientPrint(self, 2, name)
	}
	ClientPrint(self, 2, "======================")
	ClientPrint(self, 3, "\x01[VSCRIPT]53b3ff Output In Console")
}

function MCC_deploybomb(...)
{
	if(IsMannVsMachineMode())
	{
		if(Entities.FindByName(null, "cap_destroy_relay")) 
		{
			EntFire("cap_destroy_relay","trigger","",2)
		}
		else
		{
			local win = SpawnEntityFromTable("game_round_win", {force_map_reset = 1 teamnum = 3 OnRoundWin = "!self,kill"})
			win.AcceptInput("RoundWin", "", null, null)
		}
	}
	else 
	{
		ClientPrint(self, 3, "\x01[VSCRIPT]d13b30 This command is only available for use in MVM.")
	}
}