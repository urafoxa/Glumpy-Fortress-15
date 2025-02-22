MCCT_tauntcheck_weapon <- function() {
	if(!owner.InCond(7)) 
	{
		owner.Weapon_Switch(oldweapon)
		delete this["MCCT_tauntcheck_weapon"]
		self.Kill()
	}
	EntFireByHandle(self, "runscriptcode", "if(`MCCT_tauntcheck_weapon` in this)MCCT_tauntcheck_weapon()", 0.1, null, null)
}
MCCT_tauntcheck_weapon()