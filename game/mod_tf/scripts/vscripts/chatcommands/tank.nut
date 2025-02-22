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
local timer = null
local tankname = UniqueString("tank")
local player = self
local tonk = SpawnEntityFromTable("tank_boss",{speed = 0 modelscale = 1 origin = player.GetOrigin() angles = player.GetAbsAngles() health = 8000 targetname = tankname})
player.ForceChangeTeam(1,false)
NetProps.SetPropInt(player,"m_iObserverMode",5)
NetProps.SetPropEntity(player,"m_hObserverTarget",tonk)
function OnTimer() 
{	
	try{
		tonk.GetModelName()
	} catch(var1){
		player.ForceChangeTeam(2,false)
		timer.Kill()
	}
	try{
		player.GetModelName()
	} catch(var1){
		EntFireByHandle(tonk,"setspeed","80",0,null,null)
		timer.Kill()
	}
	local btn = NetProps.GetPropInt(player, "m_nButtons")
	if (btn & BUTTONS.IN_MOVELEFT) {
		tonk.SetForwardVector(RotateOrientation(tonk.GetAbsAngles(),QAngle(0, 2.5, 0)).Forward())
	}
	if (btn & BUTTONS.IN_MOVERIGHT) {
		tonk.SetForwardVector(RotateOrientation(tonk.GetAbsAngles(),QAngle(0, -2.5, 0)).Forward())
	}
	if (btn & BUTTONS.IN_FORWARD) {
		tonk.SetAbsOrigin(tonk.GetOrigin() + tonk.GetAbsAngles().Forward() * 3)
	}
	if (btn & BUTTONS.IN_BACK) {
		tonk.SetAbsOrigin(tonk.GetOrigin() - tonk.GetAbsAngles().Forward() * 3)
	}
}
function StartLoop()
{	
	if( timer == null )
	{
		timer = SpawnEntityFromTable("logic_timer",{refiretime = 0.05})
		timer.ValidateScriptScope()
		local scope = timer.GetScriptScope()
		
		// add a reference to the function
		scope.OnTimer <- OnTimer

		// connect the OnTimer output,
		// every time the timer fires the output, the function is executed
		timer.ConnectOutput( "OnTimer", "OnTimer" )

		// start the timer
		EntFireByHandle( timer, "Enable", "", 0, null, null )
	}
}
StartLoop()
