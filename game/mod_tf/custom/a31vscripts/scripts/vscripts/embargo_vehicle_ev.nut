// Template script that passes mandatory events to vehicles and setups crosshair tracing for each player
// originaly by ficool2
// forked by Alin31 w/Help of Gidi3, ficool2, and the rest of people in the TF2Maps discord
// Alien31 Features: Car Lock check, Horn, Basic projectile Shooting
// Look ask/add me first before unpacking n' stealin ok?

//Car Sounds Precache
PrecacheSound("ambient/mvm_warehouse/car_horn_03.wav");
PrecacheSound("doors/handle_pushbar_locked1.wav");
PrecacheSound("weapons/rocket_ll_shoot.wav");
PrecacheSound("mvm/mvm_tank_horn.wav");

::Vehicle_FindInCrosshair <- function(player)
{
	if (!vehicle && player.IsAlive())
	{
		local buttons = NetProps.GetPropInt(player, "m_nButtons");
		
		if ((buttons & IN_USE) || NetProps.GetPropBool(player, "m_bUsingActionSlot"))
		{	
			local eye_pos = player.EyePosition();
			local trace =
			{
				start = eye_pos,
				end = eye_pos + player.EyeAngles().Forward() * 192.0,
				ignore = player
			}
			
			TraceLineEx(trace);
			
			if (trace.hit && trace.enthit.GetClassname() == "prop_vehicle_driveable")
			{
				if (GetPropBool(trace.enthit, "m_bLocked") == false)
					trace.enthit.GetScriptScope().Enter(player);
				else
					trace.enthit.EmitSound("doors/handle_pushbar_locked1.wav");			
			}
			
		}
	}	
}

::PlayerThink <- function()
{
	Vehicle_FindInCrosshair(self);
	return 0.1;
}

function OnGameEvent_player_death(params)
{
	Vehicle_OnPlayerDeath(params);
}

function OnGameEvent_scorestats_accumulated_update(params)
{
	Vehicle_OnRoundReset(params);
}


