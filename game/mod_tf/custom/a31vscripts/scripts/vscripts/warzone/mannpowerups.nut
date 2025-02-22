enum ERuneTypes
{
    RUNE_STRENGTH,
    RUNE_HASTE,
    RUNE_REGEN,
    RUNE_RESIST,
    RUNE_VAMPIRE,
    RUNE_REFLECT,
    RUNE_PRECISION,
    RUNE_AGILITY,
    RUNE_KNOCKOUT,
    RUNE_KING,
    RUNE_PLAGUE,
    RUNE_SUPERNOVA,
}

::RuneTypeToCond <-
[
	Constants.ETFCond.TF_COND_RUNE_STRENGTH,
	Constants.ETFCond.TF_COND_RUNE_HASTE,
	Constants.ETFCond.TF_COND_RUNE_REGEN,
	Constants.ETFCond.TF_COND_RUNE_RESIST,
	Constants.ETFCond.TF_COND_RUNE_VAMPIRE,
	Constants.ETFCond.TF_COND_RUNE_REFLECT,
	Constants.ETFCond.TF_COND_RUNE_PRECISION,
	Constants.ETFCond.TF_COND_RUNE_AGILITY,
	Constants.ETFCond.TF_COND_RUNE_KNOCKOUT,
	Constants.ETFCond.TF_COND_RUNE_KING,
	Constants.ETFCond.TF_COND_RUNE_PLAGUE,
	Constants.ETFCond.TF_COND_RUNE_SUPERNOVA,
]

::MaxPlayers <- MaxClients().tointeger()

::CreateRune <- function(origin, angles, velocity, team, type, reposition)
{
	// select random player to create a rune from
	// prioritize players with no rune, as stripping the rune temporarily can have side effects
	local player, fallback
	for (local i = 1; i <= MaxPlayers; i++)
	{
		player = PlayerInstanceFromIndex(i)
		if (player)
		{
			if (player.IsCarryingRune())
			{
				fallback = player
				player = null
				continue
			}
			
			break
		}
	}
	
	if (!player)
	{
		if (!fallback)
			return null
		player = fallback
	}
		
	// to detect the rune that was spawned, every existing rune must be hidden
	for (local rune; rune = Entities.FindByClassname(rune, "item_powerup_rune");)
		rune.KeyValueFromString("classname", "zitem_powerup_rune")
	
	local cond = RuneTypeToCond[type]
	
	// if player already has a rune, temporarily strip it
	local player_cond, player_cond_duration
	if (player.IsCarryingRune())
	{
		foreach (cond in RuneTypeToCond)
		{
			player_cond_duration = player.GetCondDuration(cond)
			if (player_cond_duration != 0.0)
			{
				player.RemoveCond(cond)
				player_cond = cond
				break
			}
		}	
	}

	local cond_prop = "m_Shared." + (cond >= 96 ? "m_nPlayerCondEx3" : "m_nPlayerCondEx2")
	local cond_bits = NetProps.GetPropInt(player, cond_prop)
	NetProps.SetPropInt(player, cond_prop, cond_bits | (1 << (cond % 32)))
	player.DropRune(false, team)
	NetProps.SetPropInt(player, cond_prop, cond_bits)
	
	// give original rune back
	if (player_cond)
		player.AddCondEx(player_cond, player_cond_duration, null)
	
	local rune = Entities.FindByClassname(null, "item_powerup_rune")
	if (!rune)
		return null
	
	rune.Teleport(true, origin, true, angles, true, velocity)
	
	if (!reposition)
	{
		// prevents rune from blinking after 30 or 60 seconds
		// and teleporting to a spawnpoint if one exists
		rune.AddEFlags(Constants.FEntityEFlags.EFL_NO_THINK_FUNCTION)
		rune.AddSolidFlags(Constants.FSolid.FSOLID_TRIGGER)
	}
	
	return rune
}