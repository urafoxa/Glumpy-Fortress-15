// do not ask me how this works, ChatGPT did this. (with some fixes to use real things in vscript)
function intToBigEndianFloat(hexInt) {
    local b1 = (hexInt >> 24) & 0xFF;
    local b2 = (hexInt >> 16) & 0xFF;
    local b3 = (hexInt >> 8) & 0xFF;
    local b4 = hexInt & 0xFF;
    local sign = ((b1 & 0x80) >> 7) ? -1.0 : 1.0;
    local exponent = ((b1 & 0x7F) << 1) | ((b2 & 0x80) >> 7);
    local mantissa = ((b2 & 0x7F) << 16) | (b3 << 8) | b4;
    if (exponent == 255) {
        if (mantissa == 0) return sign * (1.0/0.0);
        return (0.0/0.0);
    } else if (exponent == 0) {
        return sign * (mantissa * pow(2, -149));
    }
    return sign * (1 + mantissa * pow(2, -23)) * pow(2, exponent - 127);
}

function objectorbyid(player, id)
{
	if(!CBaseEntity.IsValid.call(player))
	{
		return;
	}
	for(local i = 0;i < 32;i++) 
	{
		local wep = NetProps.GetPropEntityArray(player,"m_hMyWeapons",i)
		if(CBaseEntity.IsValid.call(wep))
			if(wep.GetSlot() == 2)
			{
				wep.Kill()
			}
	}
	local weaponname = "tf_weapon_bat"
	switch(player.GetPlayerClass())
	{
		case 1:
			weaponname = "tf_weapon_bat"
		break
		case 2:
			weaponname = "tf_weapon_club"
		break
		case 3:
			weaponname = "tf_weapon_shovel"
		break
		case 4:
			weaponname = "tf_weapon_bottle"
		break
		case 5:
			weaponname = "tf_weapon_bonesaw"
		break
		case 6:
			weaponname = "tf_weapon_fireaxe"
		break
		case 7:
			weaponname = "tf_weapon_fireaxe"
		break
		case 8:
			weaponname = "tf_weapon_knife"
		break
		case 9:
			weaponname = "tf_weapon_wrench"
		break
	}
	local hi = id >> 32
	local lo = id & (0xFFFFFFFF)
	local weapon = Entities.CreateByClassname(weaponname)
	NetProps.SetPropInt(weapon, "m_bValidatedAttachedEntity", 1)
	NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 474)
	NetProps.SetPropInt(weapon, "m_AttributeManager.m_Item.m_bInitialized", 1)
	weapon.DispatchSpawn()
	weapon.AddAttribute("custom texture hi", intToBigEndianFloat(hi), -1)
	weapon.AddAttribute("custom texture lo", intToBigEndianFloat(lo), -1)
	weapon.ReapplyProvision()
	player.Weapon_Equip(weapon)
	player.Weapon_Switch(weapon)
}
getroottable()["zzobjector"] <- 
{
	OnGameEvent_player_say = function(data)
	{
		local player = GetPlayerFromUserID(data.userid)
		if(!player)
			return
		if(!player.IsPlayer())
			return
		if(data.text.tolower().find("!tryobjector") == 0) {
			if(strip(data.text.tolower()) != "!tryobjector") {
				local substring = data.text.slice("!tryobjector ".len()).tolower()
				objectorbyid(player, substring.tointeger())
			}
		}
	}
}
local EventsTable = getroottable()["zzobjector"]
foreach(name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)