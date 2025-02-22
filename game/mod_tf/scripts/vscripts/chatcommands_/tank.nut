enum BUTTONS
{
    IN_ATTACK = 1,
    IN_JUMP = 2,
    IN_DUCK = 4,
    IN_FORWARD = 8,
    IN_BACK = 16,
    IN_USE = 32,
    IN_CANCEL = 64,
    IN_LEFT = 128,
    IN_RIGHT = 256,
    IN_MOVELEFT = 512,
    IN_MOVERIGHT = 1024,
    IN_ATTACK2 = 2048,
    IN_RUN = 4096,
    IN_RELOAD = 8192,
    IN_ALT1 = 16384,
    IN_ALT2 = 32768,
    IN_SCORE = 65536,
    IN_SPEED = 131072,
    IN_WALK = 262144,
    IN_ZOOM = 524288,
    IN_WEAPON1 = 1048576,
    IN_WEAPON2 = 2097152,
    IN_BULLRUSH = 4194304,
    IN_GRENADE1 = 8388608,
    IN_GRENADE2 = 16777216,
    IN_ATTACK3 = 33554432
};
local speed = 1
if(!("owner" in this))
	return self.Kill()
SetDestroyCallback(self, function()
{
	owner.ForceChangeTeam(2, false)
})
function MCCT_tank() 
{	
	if(CBaseEntity.IsValid.call(owner))
	{
		local btn = NetProps.GetPropInt(owner, "m_nButtons")
		self.SetForwardVector(RotateOrientation(self.GetAbsAngles(), QAngle(0, ((btn & BUTTONS.IN_MOVELEFT) / BUTTONS.IN_MOVELEFT - (btn & BUTTONS.IN_MOVERIGHT) / BUTTONS.IN_MOVERIGHT), 0)).Forward())
		self.SetAbsOrigin(self.GetOrigin() + self.GetAbsAngles().Forward() * ((btn & BUTTONS.IN_FORWARD) / BUTTONS.IN_FORWARD - (btn & BUTTONS.IN_BACK) / BUTTONS.IN_BACK) * speed)
		NetProps.SetPropEntity(owner, "m_hObserverTarget", self)
		NetProps.SetPropInt(owner, "m_iObserverMode", 5)
		if(owner.GetTeam() != 1 || owner.GetScriptScope().MCCD_tank != self)
			return self.Kill()
		EntFireByHandle(self, "runscriptcode", "if(`MCCT_tank` in this)MCCT_tank()", 0.01, null, null)
	}
}
owner.GetScriptScope().MCCD_tank <- self
owner.ForceChangeTeam(1, false)
MCCT_tank()