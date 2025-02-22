SetDestroyCallback(self, function()
{
	StopAmbientSoundOn("mvm/sentrybuster/mvm_sentrybuster_loop.wav", owner)
	owner.AcceptInput("setcustommodelwithclassanimations", "", null, null)
	owner.SetModelScale(1, 0.1)
})
MCCT_tauntcheck_buster <- function() 
{
	if(owner.GetHealth() <= 1)
		owner.HandleTauntCommand(0)
	if (owner.InCond(7) || NetProps.GetPropInt(owner, "m_lifeState") == 2) 
	{
		StopAmbientSoundOn("mvm/sentrybuster/mvm_sentrybuster_loop.wav", owner)
		EmitAmbientSoundOn("MvM.SentryBusterSpin", 1, 0, 100, owner)
		if (NetProps.GetPropInt(owner, "m_lifeState") != 2) {
			self.GetScriptScope().MCCT_explode_buster <- function() 
			{
				owner.SetHealth(1)
				NetProps.SetPropInt(owner, "m_debugOverlays", 0)
				DispatchParticleEffect("fluidSmokeExpl_ring_mvm", owner.GetOrigin(), owner.GetAbsAngles().Forward())
				DispatchParticleEffect("explosionTrail_seeds_mvm", owner.GetOrigin(), owner.GetAbsAngles().Forward())
				owner.EmitSound("MVM.SentryBusterExplode")
				local ent = null
				local range = Convars.GetInt("tf_bot_suicide_bomb_range")
				ScreenShake(owner.GetOrigin(), 25, 5, 5, 1000, 0, false)
				while (ent = Entities.FindByClassnameWithin(ent, "*", owner.GetOrigin(), range)) 
				{
					if (ent.GetClassname().find("obj_") == 0) 
					{
						EntFireByHandle(ent, "RemoveHealth", "999999999", 0, owner, owner)
					}
					if (ent.IsPlayer()) 
					{
						ent.TakeDamageEx(owner, owner, owner.GetActiveWeapon(), Vector(0, 0, 10), owner.GetOrigin(), (((ent.GetMaxHealth()) > (ent.GetHealth())) ? (ent.GetMaxHealth()) : (ent.GetHealth())) * 4, 64)
						ScreenFade(ent, 255, 255, 255, 255, 1, 0.1, 1);
					}
				}
			}
			EntFireByHandle(self, "runscriptcode", "MCCT_explode_buster()", 2.0, null, null)
			delete this["MCCT_tauntcheck_buster"]
		}
	}
	EntFireByHandle(self, "runscriptcode", "if(`MCCT_tauntcheck_buster` in this)MCCT_tauntcheck_buster()", 0.1, null, null)
}
MCCT_tauntcheck_buster()