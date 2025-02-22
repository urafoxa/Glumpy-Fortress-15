local cc_scope = this
const INVALID_VALUE = -2.84203
local inverted_attributes =
{
	"fire rate penalty" : 0
	"fire rate bonus" : 0
	"overheal decay penalty" : 0
	"overheal decay bonus" : 0
	"dmg taken from fire reduced" : 0
	"dmg taken from crit reduced" : 0
	"dmg taken from blast reduced" : 0
	"dmg taken from bullets reduced" : 0
	"cloak consume rate decreased" : 0
	"minigun spinup time decreased" : 0
	"reload time decreased" : 0
	"reload time increased hidden" : 0
	"weapon spread bonus" : 0
	"set bonus: dmg from sentry reduced" : 0
	"deploy time decreased" : 0
	"switch from wep deploy time decreased" : 0
	"reload time decreased while healed" : 0
	"faster reload rate" : 0
	"build rate bonus" : 0
	"engy sentry fire rate increased" : 0
	"fire rate penalty hidden" : 0
	"aiming knockback resistance" : 0
	"fire rate bonus hidden" : 0
	"melee attack rate bonus" : 0
	"set bonus: dmg taken from crit reduced set bonus" : 0
	"set bonus: dmg taken from fire reduced set bonus" : 0
	"single wep deploy time decreased" : 0
	"halloween reload time decreased" : 0
	"halloween fire rate bonus" : 0
	"fire rate bonus with reduced health" : 0
	"stickybomb charge rate" : 0
	"panic_attack_negative" : 0
	"single wep deploy time increased" : 0
	"dmg taken from fire reduced on active" : 0
	"card: dmg taken from bullets reduced" : 0
	"item_meter_charge_rate" : 0
	"airblast cost scale hidden" : 0
}

local mode_attributes =
{
	"sticky detonate mode" : 0
	"override projectile type" : 0
	"item_meter_charge_type" : 0
	"mod soldier buff type" : 0
	"mod demo buff type" : 0
	"attach particle effect" : 0
	"attach particle effect static" : 0
	"no self blast dmg" : 0
	"item style override" : 0
}

function MCC_addattribute(...)
{
	local errortext = "\x01[VSCRIPT]53b3ff Usage: !addattribute 'fire rate bonus' 0.5"
	local text = vargv[vargv.len() - 1]
	
	local start = text.tolower().find("'")
	if(start == null) return ClientPrint(self, 3, errortext)
	else start += 1
	
	local end = text.tolower().find("'", start)
	if(end == null) return ClientPrint(self, 3, errortext)
	
	local attribute = text.slice(start, end).tolower()
	if(MCCL_attributes.find(attribute) != null)
	{
		local attributevalue = text.slice(end + 2).tofloat()
		self.GetActiveWeapon().AddAttribute(attribute, attributevalue, -1)
		self.GetActiveWeapon().ReapplyProvision()
	}
	else 
	{
		ClientPrint(self, 3, "\x01[VSCRIPT]d13b30 Invalid weapon attribute. Use !findattribute to find a valid attribute.")
	}
}

function MCC_findattribute(...)
{
	if(vargv.len() < 2)
	{
		ClientPrint(self, 3, "\x01[VSCRIPT]53b3ff Use !help findattribute for more info.")
	}
	else
	{
		local attribute_to_search = ""
		foreach(i, item in vargv) { if(i == vargv.len() - 1) break; attribute_to_search += item + " "}
		attribute_to_search = rstrip(attribute_to_search.tolower())
		local return_attribute_array = []
		foreach(attribute in MCCL_attributes)
		{
			if(attribute.find(attribute_to_search) > -1 || attribute_to_search == "*")
			{
				return_attribute_array.append(attribute)
			}
		}
		if(return_attribute_array.len() == 0){
			ClientPrint(self, 3, "[VSCRIPT]d13b30 No attribute found matching: " + attribute_to_search)
		}
		else
		{
			ClientPrint(self, 2, "========ATTRIBS=======")
			foreach(attribute in return_attribute_array)
			{
				ClientPrint(self, 2, attribute)
			}
			ClientPrint(self, 2, "======================")
			ClientPrint(self, 3, "\x01[VSCRIPT]53b3ff Output In Console")
		}
	}
}

function MCCW_giveweaponfromtable(data)
{
	local sapper_fix = 0
	local weapon_classname = "tf_weapon_base"
	if("item_class" in data)
		if(typeof(data.item_class) == "string")
			weapon_classname = data.item_class
			
	if(weapon_classname == "tf_weapon_sapper")
	{
		weapon_classname = "tf_weapon_builder"
		sapper_fix = 1
	}
			
	if(weapon_classname == "saxxy")
	{
		weapon_classname = "tf_weapon_bat"
		switch(self.GetPlayerClass())
		{
			case 1:
				weapon_classname = "tf_weapon_bat"
			break
			case 2:
				weapon_classname = "tf_weapon_club"
			break
			case 3:
				weapon_classname = "tf_weapon_shovel"
			break
			case 4:
				weapon_classname = "tf_weapon_bottle"
			break
			case 5:
				weapon_classname = "tf_weapon_bonesaw"
			break
			case 6:
				weapon_classname = "tf_weapon_fireaxe"
			break
			case 7:
				weapon_classname = "tf_weapon_fireaxe"
			break
			case 8:
				weapon_classname = "tf_weapon_knife"
			break
			case 9:
				weapon_classname = "tf_weapon_wrench"
			break
		}
	}
			
	if(weapon_classname == "tf_weapon_shotgun")
	{
		switch(self.GetPlayerClass())
		{
			case 3:
				weapon_classname = "tf_weapon_shotgun_soldier"
			break
			case 6:
				weapon_classname = "tf_weapon_shotgun_pyro"
			break
			case 7:
				weapon_classname = "tf_weapon_shotgun_hwg"
			break
			case 9:
				weapon_classname = "tf_weapon_shotgun_primary"
			break
			default:
				//weapon_classname = ["tf_weapon_shotgun_primary", "tf_weapon_shotgun_hwg", "tf_weapon_shotgun_pyro", "tf_weapon_shotgun_soldier"][RandomInt(0,3)]
				weapon_classname = "tf_weapon_shotgun_primary"
			break
		}
	}
	
	local weapon_index = 0
	if("item_index" in data)
	{
		if(typeof(data.item_index) == "integer")
			weapon_index = data.item_index
	}
			
	local weapon_quality = 0
	if("item_quality" in data)
	{
		if(typeof(data.item_quality) == "integer")
			weapon_quality = data.item_quality
	}
			
	local forced_weapon_classname = weapon_classname
	if("forced_classname" in data)
	{
		if(typeof(data.forced_classname) == "string")
			forced_weapon_classname = data.forced_classname
	}
			
	local weapon = SpawnEntityFromTable(weapon_classname, {})
	if(!CBaseEntity.IsValid.call(weapon))
		return null;
	NetProps.SetPropString(weapon, "m_iClassname", forced_weapon_classname)
	NetProps.SetPropInt(weapon, "m_bValidatedAttachedEntity", 1)
	NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", weapon_index)
	NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_bInitialized", 1)
	NetProps.SetPropInt(weapon, "BuilderLocalData.m_iObjectType", (sapper_fix) ? 3 : 0)
	NetProps.SetPropInt(weapon, "m_iSubType", (sapper_fix) ? 3 : 0)
	if("buildables" in data)
	{
		if("dispenser" in data.buildables)
		{
			NetProps.SetPropInt(weapon, "m_aBuildableObjectTypes.000", data.buildables.dispenser ? 1 : 0)
		}
		if("teleporter" in data.buildables)
		{
			NetProps.SetPropInt(weapon, "m_aBuildableObjectTypes.001", data.buildables.teleporter ? 1 : 0)
		}
		if("sentry" in data.buildables)
		{
			NetProps.SetPropInt(weapon, "m_aBuildableObjectTypes.002", data.buildables.sentry ? 1 : 0)
		}
		if("sapper" in data.buildables)
		{
			NetProps.SetPropInt(weapon, "m_aBuildableObjectTypes.003", data.buildables.sapper ? 1 : 0)
		}
	}
	else
	{
		if(sapper_fix)
		{
			NetProps.SetPropInt(weapon, "m_aBuildableObjectTypes.003", 1)
		}
		else
		{
			NetProps.SetPropInt(weapon, "m_aBuildableObjectTypes.000", 1)
			NetProps.SetPropInt(weapon, "m_aBuildableObjectTypes.001", 1)
			NetProps.SetPropInt(weapon, "m_aBuildableObjectTypes.002", 1)
		}
	}
	NetProps.SetPropFloat(weapon, "LocalActiveTFWeaponData.m_flEffectBarRegenTime", Time())
	NetProps.SetPropFloat(weapon, "m_fChargeBeginTime", Time())
	if("attributes" in data)
	{
		foreach(attribute, value in data.attributes)
		{
			weapon.AddAttribute(attribute, value, -1)
		}
	}
	local replace = true
	if("replace" in data)
	{
		replace = data.replace
	}
	if(replace)
	{
		local slot = weapon.GetSlot()
		for(local i = 0;i < 32;i++) 
		{
			local wep = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
			if(CBaseEntity.IsValid.call(wep))
			{
				if(wep.GetSlot() == slot)
				{
					local wearable = NetProps.GetPropEntity(wep, "m_hExtraWearable")
					local wearable_vm = NetProps.GetPropEntity(wep, "m_hExtraWearableViewModel")
					if(CBaseEntity.IsValid.call(wearable))
						wearable.Kill()
					if(CBaseEntity.IsValid.call(wearable_vm))
						wearable_vm.Kill()
					wep.Kill()
				}
			}
		}
	}
	weapon.ReapplyProvision()
	self.Weapon_Equip(weapon)	
	if("item_text" in data)
		ClientPrint(self, 3, "\x01[VSCRIPT] " + data.item_text)
	return weapon;
}

function MCC_giveweaponcustom(...)
{
	if(vargv.len() < 2)
	{
		ClientPrint(self, 3, "\x01[VSCRIPT]53b3ff Use !help giveweaponcustom for more info.")
	}
	else
	{
		//IncludeScript("chatcommands_/data/cweapons.nut", cc_scope)
		local input = ""
		foreach(i, item in vargv) { if(i == vargv.len() - 1) break; input += item + " "}
		input = rstrip(input.tolower())
		foreach(name, data in cc_scope.MCCW_custom)
		{
			if(name == input)
			{
				local weapon = MCCW_giveweaponfromtable(data)
				return self.Weapon_Switch(weapon)
			}
		}
		return ClientPrint(self, 3, "\x01[VSCRIPT]d13b30 " + format("No custom weapon found named '%s'.", input))
	}
}

function MCC_givecustomweapon(...)
{
	local args = vargv
	args.insert(0, this)
	cc_scope.MCC_giveweaponcustom.acall(args)
}

function MCC_giveweapon(...)
{
	if(vargv.len() < 3)
	{
		ClientPrint(self, 3, "\x01[VSCRIPT]53b3ff Use !help giveweapon for more info.")
	}
	else
	{
		local classname = vargv[0]
		local index = 0
		try{index = vargv[1].tointeger()}catch(e){}
		local weapon = MCCW_giveweaponfromtable(
		{
			"item_class" : classname 
			"item_index" : index
		})
		if(weapon == null)
			return ClientPrint(self, 3, "[VSCRIPT]d13b30 Invalid weapon classname.")
		self.Weapon_Switch(weapon)
	}
}

function MCC_randomweapon(...)
{
	local weapondata = MCCL_weapons[RandomInt(0, MCCL_weapons.len()-1)]
	local name = weapondata[0]
	local classname = weapondata[1]
	local index = weapondata[2]
	local weapon = MCCW_giveweaponfromtable(
	{
		"item_text" : "You have recieved \"" + name + "\""
		"item_class" : classname 
		"item_index" : index
	})
	self.Weapon_Switch(weapon)
}

function MCC_randomloadout(...)
{
	local weapontypes = ["MCCL_primaryweapons", "MCCL_secondaryweapons", "MCCL_meleeweapons"]
	for(local i = 0;i < weapontypes.len();i++)
	{
		local weapondata = this[weapontypes[i]][RandomInt(0, this[weapontypes[i]].len()-1)]
		local name = weapondata[0]
		local classname = weapondata[1]
		local index = weapondata[2]
		local weapon = MCCW_giveweaponfromtable(
		{
			"item_text" : "You have recieved \"" + name + "\""
			"item_class" : classname 
			"item_index" : index
		})
		self.Weapon_Switch(weapon)
	}
	if(self.GetPlayerClass() == 8)
	{
		local weapondata = MCCL_invisweapons[RandomInt(0, MCCL_invisweapons.len()-1)]
		local name = weapondata[0]
		local classname = weapondata[1]
		local index = weapondata[2]
		local weapon = MCCW_giveweaponfromtable(
		{
			"item_text" : "You have recieved \"" + name + "\""
			"item_class" : classname 
			"item_index" : index
		})
	}
}

/*function MCC_dumpweapondata(...)
{
	local output = ""
	local slot = 6
	for(local i=0;i < MCCL_weapons.len();i++)
	{
		local weapon = ((MCCL_weapons[i][1] == "tf_weapon_shotgun") ? "tf_weapon_shotgun_primary" : ((MCCL_weapons[i][1] == "saxxy") ? "tf_weapon_knife": MCCL_weapons[i][1] ))
		local temp = SpawnEntityFromTable(weapon,{})
		if(temp.GetSlot() == slot)
			output += "[\""+ MCCL_weapons[i][0] + "\", \"" + MCCL_weapons[i][1] + "\", " + MCCL_weapons[i][2].tostring() + "]\n"
		temp.Kill()
	}
	StringToFile("weapons_" + slot.tostring() + ".txt", output)
}*/

function MCC_noweapons(...)
{
	for(local i = 0;i < 32;i++) 
	{
		local wep = NetProps.GetPropEntityArray(self, "m_hMyWeapons", i)
		if(CBaseEntity.IsValid.call(wep))
			wep.Kill()
	}
}

function MCC_nohats(...)
{
	local wearable = null
	if (Entities.FindByClassname(null,"tf_wearable") != null) 
	{
		for(local wearable = Entities.FindByClassname(null, "tf_wearable*"); wearable != null; wearable = Entities.FindByClassname(wearable, "tf_wearable*"))
		{
			if(NetProps.GetPropEntity(wearable,"m_hOwnerEntity") == self) 
				wearable.Kill()
		}
	}
	local wearable = null
	if (Entities.FindByClassname(null,"tf_powerup_bottle") != null) 
	{
		for(local wearable = Entities.FindByClassname(null, "tf_powerup_bottle*"); wearable != null; wearable = Entities.FindByClassname(wearable, "tf_powerup_bottle*"))
		{
			if(NetProps.GetPropEntity(wearable,"m_hOwnerEntity") == self) 
				wearable.Kill()
		}
	}
}

function MCC_noloadout(...)
{
	MCC_noweapons()
	MCC_nohats()
}

function MCC_buffweapon(...)
{
	local activeweapon = self.GetActiveWeapon()
	if(!CBaseEntity.IsValid.call(activeweapon))
		return ClientPrint(self, 3, "\x01[VSCRIPT]d13b30 You are not holding a weapon.")
	local weapon = MCCW_giveweaponfromtable(
	{
		"item_class" : activeweapon.GetClassname()
		"item_index" : NetProps.GetPropInt(activeweapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")
		"attributes" :
		{
			"fire rate bonus" : 0.5
			"damage bonus" : 2
			"clip size bonus" : 2
		}
		"replace" : false
	})
	for(local i = 0;i < MCCL_attributes.len();i++)
	{
		if(MCCL_attributes[i] in mode_attributes) continue
		if(activeweapon.GetAttribute(MCCL_attributes[i], INVALID_VALUE) != INVALID_VALUE)
		{
			local mult = 1
			mult *= (((MCCL_attributes[i] == "max pipebombs decreased") && activeweapon.GetAttribute(MCCL_attributes[i], 0) < 0) ? -1 : 1)
			weapon.AddAttribute(MCCL_attributes[i], activeweapon.GetAttribute(MCCL_attributes[i], 1) * ((MCCL_attributes[i] in inverted_attributes) ? 0.5 : 2 * mult), -1)
			//printl(mult)
			//printl(MCCL_attributes[i] + " | " + weapon.GetAttribute(MCCL_attributes[i], INVALID_VALUE))
		}
	}
	
	if(weapon.GetSlot() == 0)
	{
		if(weapon.GetAttribute("maxammo primary increased", INVALID_VALUE) == INVALID_VALUE)
		{
			weapon.AddAttribute("maxammo primary increased", 2, -1)
		}
	}
	
	if(weapon.GetSlot() == 1)
	{
		if(weapon.GetAttribute("maxammo secondary increased", INVALID_VALUE) == INVALID_VALUE)
		{
			weapon.AddAttribute("maxammo secondary increased", 2, -1)
		}
	}
	activeweapon.Kill()
	self.Weapon_Switch(weapon)
}

function MCC_dropweapon(...)
{
	// dont ask
	local oldmvm = IsMannVsMachineMode()
	local oldhealth = self.GetHealth()
	local oldclass = self.GetPlayerClass()
	local oldcloak = NetProps.GetPropFloat(self, "m_Shared.m_flCloakMeter")
	local oldmodel = self.GetModelName()
	local gamerules = Entities.FindByClassname(null, "tf_gamerules")
		NetProps.SetPropBool(gamerules, "m_bPlayingMannVsMachine", false)
	self.SetPlayerClass(8)
	NetProps.SetPropFloat(self, "m_Shared.m_flCloakMeter", 100)
	local weapon = MCCW_giveweaponfromtable(
	{
		"item_class" : "tf_weapon_invis" 
		"item_index" : 59
		"replace" : false
	})
	NetProps.SetPropBool(self, "m_Shared.m_bFeignDeathReady", true)
	self.SetHealth(10000000)
	self.TakeDamage(1, 0, self)
	self.SetHealth(oldhealth)
	NetProps.SetPropBool(self, "m_Shared.m_bFeignDeathReady", false)
	NetProps.SetPropFloat(self, "m_Shared.m_flCloakMeter", oldcloak)
	if(Entities.FindByClassname(null,"tf_ragdoll") != null) 
	{
		for(local ragdoll = Entities.FindByClassname(null, "tf_ragdoll"); ragdoll != null; ragdoll = Entities.FindByClassname(ragdoll, "tf_ragdoll"))
		{
			if(NetProps.GetPropEntity(ragdoll, "m_hPlayer") == self) 
				ragdoll.Kill()
		}
	}
	if(Entities.FindByClassname(null,"tf_ammo_pack") != null) 
	{
		for(local pack = Entities.FindByClassname(null, "tf_ammo_pack"); pack != null; pack = Entities.FindByClassname(pack, "tf_ammo_pack"))
		{
			if(NetProps.GetPropEntity(pack, "m_hOwnerEntity") == self) 
				pack.Kill()
		}
	}
	weapon.Destroy()
	NetProps.SetPropBool(gamerules, "m_bPlayingMannVsMachine", oldmvm)
	self.SetPlayerClass(oldclass)
	self.RemoveCond(4)
	self.RemoveCond(13)
	self.RemoveCond(32)
	self.SetCustomModelWithClassAnimations(oldmodel)
}

function MCC_customweaponlist(...)
{
	//IncludeScript("chatcommands_/data/cweapons.nut", cc_scope)
	ClientPrint(self, 2, "========WEAPONS=======")
	foreach(name, data in cc_scope.MCCW_custom)
	{
		ClientPrint(self, 2, name)
	}
	ClientPrint(self, 2, "======================")
	ClientPrint(self, 3, "\x01[VSCRIPT]53b3ff Output In Console")
}
