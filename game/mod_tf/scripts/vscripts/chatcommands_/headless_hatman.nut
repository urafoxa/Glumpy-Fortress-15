local axe = PrecacheModel("models/weapons/c_models/c_bigaxe/c_bigaxe.mdl")
NetProps.SetPropInt(self, "m_nModelIndexOverrides.000", axe)
NetProps.SetPropInt(self, "m_nModelIndexOverrides.001", axe)
NetProps.SetPropInt(self, "m_nModelIndexOverrides.002", axe)
NetProps.SetPropInt(self, "m_nModelIndexOverrides.003", axe)
laststep <- NetProps.GetPropInt(owner, "m_Local.m_nStepside")
bootimer <- 0.0
SetDestroyCallback(self, function()
{
	owner.AcceptInput("setcustommodelwithclassanimations", "", null, null)
})
MCCT_headless_hatman <- function() 
{
	owner.RemoveCond(22)
	owner.RemoveCond(24)
	owner.RemoveCond(25)
	owner.RemoveCond(27)
	if(owner.InCond(15))
	{
		owner.RemoveCond(15)
		NetProps.SetPropEntity(owner, "m_hActiveWeapon", null)	
		owner.Weapon_Switch(self)
	}
	if(laststep != NetProps.GetPropInt(owner, "m_Local.m_nStepside"))
	{
		laststep = NetProps.GetPropInt(owner, "m_Local.m_nStepside")
		self.EmitSound("Halloween.HeadlessBossFootfalls");	
		SpawnParticle(owner, "halloween_boss_foot_impact", "", particle.PATTACH_ABSORIGIN)
	}
	if(NetProps.GetPropInt(owner, "m_Shared.m_iNextMeleeCrit") == 0)
	{
		if(owner.GetActiveWeapon() == self)
		{
			self.EmitSound("Halloween.HeadlessBossAttack");
		}
		NetProps.SetPropInt(owner, "m_Shared.m_iNextMeleeCrit", -2)
	}
	if(NetProps.GetPropInt(owner, "m_lifeState") != 2)
	{
		if(!bootimer)
		{
			for (local scene; scene = Entities.FindByClassname(scene, "instanced_scripted_scene");)
			{
				local scene_owner = NetProps.GetPropEntity(scene, "m_hOwner")
				if (scene_owner == owner)
				{
					local name = NetProps.GetPropString(scene, "m_szInstanceFilename")
					local scene_array = ["scenes/Player/Demoman/low/959.vcd", "scenes/Player/Demoman/low/958.vcd", "scenes/Player/Demoman/low/957.vcd", "scenes/Player/Demoman/low/932.vcd", "scenes/Player/Demoman/low/933.vcd", "scenes/Player/Demoman/low/934.vcd", "scenes/Player/Demoman/low/925.vcd", "scenes/Player/Demoman/low/924.vcd", "scenes/Player/Demoman/low/923.vcd"]
					if(scene_array.find(name) != null)
					{
						scene.ValidateScriptScope()
						local scenescope = scene.GetScriptScope()
						if(!("MCC_booing" in scenescope))
						{
							scenescope.MCC_booing <- true
							self.EmitSound("Halloween.HeadlessBossBoo");
							local ent = null
							local range = Convars.GetFloat("tf_halloween_bot_terrify_radius")
							while (ent = Entities.FindByClassnameWithin(ent, "*", owner.GetOrigin(), range)) 
							{
								if (ent.IsPlayer() && ent != owner) 
								{
									ent.StunPlayer(2, 0, 192, null);
								}
							}
						}
					}
				}
			}
			bootimer = 0.5
		}
	}
	NetProps.SetPropInt(owner, "m_Shared.m_iDecapitations", 0)
	bootimer -= 0.1
	if(bootimer < 0)
		bootimer = 0
	EntFireByHandle(self, "runscriptcode", "if(`MCCT_headless_hatman` in this)MCCT_headless_hatman()", 0.1, null, null)
}
MCCT_headless_hatman()

MCCT_headless_hatman_laugh <- function() 
{
	if(NetProps.GetPropInt(owner, "m_lifeState") != 2)
	{
		owner.AcceptInput("dispatcheffect", "ParticleEffectStop", owner, owner)
		SpawnParticle(owner, "ghost_pumpkin", "", particle.PATTACH_ABSORIGIN_FOLLOW)
		SpawnParticle(owner, "halloween_boss_eye_glow", "lefteye", particle.PATTACH_POINT_FOLLOW)
		SpawnParticle(owner, "halloween_boss_eye_glow", "righteye", particle.PATTACH_POINT_FOLLOW)
		self.EmitSound("Halloween.HeadlessBossLaugh")
		EntFireByHandle(self, "runscriptcode", "if(`MCCT_headless_hatman_laugh` in this)MCCT_headless_hatman_laugh()", RandomFloat(3,5), null, null)
	}
}
EntFireByHandle(self, "runscriptcode", "if(`MCCT_headless_hatman_laugh` in this)MCCT_headless_hatman_laugh()", RandomFloat(3,5), null, null)