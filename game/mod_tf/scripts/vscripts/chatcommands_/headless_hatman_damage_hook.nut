NetProps.SetPropInt(Entities.FindByClassname(null, "worldspawn"), "m_takedamage", 1)
MCCH_Headless_Hatman <- function(data) 
{
	local player = data.attacker
	if(!player)
		return
	if(!player.IsPlayer())
		return
	local wep = player.GetActiveWeapon()
	if(wep != null)
	{
		wep.ValidateScriptScope()
		if("MCCT_headless_hatman" in wep.GetScriptScope())
		{
			if(data.weapon != wep)
				return
			local victim = data.const_entity
			if(!victim)
				return
			data.damage = victim.GetMaxHealth() * 0.8
			data.max_damage = victim.GetMaxHealth() * 0.8
			local trace = 
			{
				start = player.EyePosition()
				end = player.EyePosition() + (player.EyeAngles().Forward() * 1000)
				ignore = player
			}
			TraceLineEx(trace)
			DispatchParticleEffect("halloween_boss_axe_hit_world", trace.pos, player.GetAbsAngles().Forward());
			ScreenShake(player.GetOrigin(), 15, 5, 1, 1000, 0, false);
			player.EmitSound("Halloween.HeadlessBossAxeHitWorld");	
			if(victim.IsPlayer())
				player.EmitSound("Halloween.HeadlessBossAxeHitFlesh");
		}
	}

	player = data.const_entity
	if(!player)
		return
	if(!player.IsPlayer())
		return
	local wep = player.GetActiveWeapon()
	if(wep != null)
	{
		wep.ValidateScriptScope()
		if("MCCT_headless_hatman" in wep.GetScriptScope())
		{
			if(!("damage_position" in data))
				data.damage_position <- player.GetOrigin()
			DispatchParticleEffect("halloween_boss_injured", data.damage_position, player.GetAbsAngles().Forward())
		}
	}
}