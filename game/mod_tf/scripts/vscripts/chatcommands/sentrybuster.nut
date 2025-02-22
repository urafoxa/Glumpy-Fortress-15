function tauntcheck() {
	if (self.InCond(7) || NetProps.GetPropInt(self, "m_lifeState") == 2 || self.GetHealth() <= 1) {
		StopAmbientSoundOn("mvm/sentrybuster/mvm_sentrybuster_loop.wav", self)
		EmitAmbientSoundOn("mvm/sentrybuster/mvm_sentrybuster_spin.wav", 1, 0, 100, self)
		if (NetProps.GetPropInt(self, "m_lifeState") != 2) {
			local mytimer = SpawnEntityFromTable("logic_timer", {refiretime = 2})
			if (mytimer.ValidateScriptScope()) {
				mytimer.GetScriptScope().playerent <- self
				mytimer.GetScriptScope().timerstuffnow <- function() {
					DispatchParticleEffect("fireSmoke_Collumn_mvmAcres_sm", playerent.GetOrigin() + Vector(0, 0, 60), Vector(0, 0, 0))
					playerent.EmitSound("mvm/sentrybuster/mvm_sentrybuster_explode.wav")
					EntFireByHandle(playerent, "SetCustommodelWithClassAnimations", "", 0.1, playerent, playerent)
					local ent = null
					while (ent = Entities.FindByClassnameWithin(ent, "*", playerent.GetOrigin(), 250)) {
						if (ent.GetClassname().find("obj_") == 0) {
							EntFireByHandle(ent, "RemoveHealth", "999999999", 0, playerent, playerent)
						}
						if (ent.IsPlayer()) {
							if (NetProps.GetPropInt(playerent, "m_bIsMiniBoss") == 0 || ent == playerent) {
								ent.TakeDamageEx(playerent, playerent, playerent.GetActiveWeapon(), Vector(0, 0, 10), playerent.GetOrigin(), 2500, 0)
							} else {
								ent.TakeDamageEx(playerent, playerent, playerent.GetActiveWeapon(), Vector(0, 0, 10), playerent.GetOrigin(), 600, 0)
							}
						}
					}
					self.Kill()
				}
			}
			mytimer.ConnectOutput("OnTimer", "timerstuffnow")
		}
		AddThinkToEnt(self, "null")
	}
	return 0.01;
}
AddThinkToEnt(self, "tauntcheck")