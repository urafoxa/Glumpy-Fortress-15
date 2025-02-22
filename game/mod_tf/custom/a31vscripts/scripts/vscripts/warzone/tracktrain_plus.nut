// original by ficool2
// upgraded by Alien31 w/Help of Gidi3, ficool2, and the rest of people in the TF2Maps discord
// Alien31 Features: Car Lock check, Horn, Basic projectile Shooting, Turbo, Handbrake
// Look ask/add me first before unpacking and stealin ok? if not. ur a jackass

//ForceEscortPushLogic(2);

const IN_ATTACK = 1;
const IN_JUMP = 2;const IN_FORWARD = 8;
const IN_BACK = 16;
const IN_USE = 32;
const IN_ATTACK2 = 2048;
const IN_RELOAD = 8192;
const DMG_CRUSH = 1;
const COLLISION_GROUP_PLAYER = 5;
const COLLISION_GROUP_IN_VEHICLE = 10;
const MOVETYPE_NONE = 0;
const MOVETYPE_WALK = 2;
const FL_DUCKING = 2;
const EFL_IS_BEING_LIFTED_BY_BARNACLE = 1048576;
const MASK_PLAYERSOLID = 33636363; // CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_WINDOW|CONTENTS_PLAYERCLIP|CONTENTS_GRATE|CONTENTS_MONSTER
const DMG_VEHICLE = 16;

//TRAIN LIST
local TrainHandling = {
	"train_1" : {HasWagons = true, LinkedWagons = "train_1wagon_*", sfx_horn = "ambient/alarms/train_horn2.wav", delay_horn = 3},
	"train_2" : {HasWagons = true, LinkedWagons = "train_2wagon_*", sfx_horn = "ambient/mvm_warehouse/train_02.wav", delay_horn = 3},
}

foreach (Traintype,Traininfo in TrainHandling) 
{
	PrecacheSound(TrainHandling[Traintype].sfx_horn)
}

::TrainInitPlayer <- function(player)
{
	player.ValidateScriptScope();
	local scope = player.GetScriptScope();
	scope.vehicle <- null;
	scope.vehicle_scope <- null;
}

::TrainThink <- function()
{
	for (local player; player = Entities.FindByClassname(player, "player");)
	{
		if (!player.IsAlive())
			continue;
		local scope = player.GetScriptScope();
		if (scope.vehicle)
		{
			NetProps.SetPropInt(player, "m_Shared.m_nAirDucked", 8);
			continue;
		}
		local buttons = NetProps.GetPropInt(player, "m_nButtons");		
		if ((buttons & IN_USE) || player.IsUsingActionSlot())
		{	
			// find vehicle under crosshair
			local eye_pos = player.EyePosition();
			local trace =
			{
				start = eye_pos,
				end = eye_pos + player.EyeAngles().Forward() * 192.0,
				ignore = player
			}
			TraceLineEx(trace);		
			if ((trace.hit && trace.enthit.GetClassname() == "func_tracktrain" || trace.hit && trace.enthit.GetClassname() == "func_tanktrain"))
			{
				local flags = NetProps.GetPropInt(trace.enthit, "m_spawnflags");
				if(!(flags & 2))
					trace.enthit.GetScriptScope().EnterTrain(player);
			}
		}
	}
	return 0.1
}

// This hack allows vehicle damage to show the train kil licon
if (!("TrainDmgOwner" in getroottable()) || !TrainDmgOwner.IsValid())
{
	::TrainDmgOwner <- SpawnEntityFromTable("handle_dummy", {});
	TrainDmgOwner.KeyValueFromString("classname", "vehicle");
}
AddThinkToEnt(TrainDmgOwner, "TrainThink")

function Precache()
{
	driver <- null;
	vehicle <- self;
	can_enter <- true;
	can_exit <- false;
	fixup_origin <- Vector();
	fixup_angles <- QAngle();
	
    // unused spawnflags are used to define non-car vehicle type
	local flags = NetProps.GetPropInt(self, "m_spawnflags");

	
	DriversTeam <- 0;
}

function OnPostSpawn()
{
	AddThinkToEnt(self, "Think");
}

function EnableEnter()
{
	can_enter = true;
}

function EnableExit()
{
	can_exit = true;
}

function CheckExitPoint(yaw, distance, mins, maxs)
{
	local vehicleAngles = vehicle.GetLocalAngles();
	vehicleAngles.y += yaw;	
	
  	local vecStart = vehicle.GetOrigin();
	vecStart.z += 12.0;
	
  	local vecDir = vehicleAngles.Left() * -1.0;
	
  	fixup_origin = vecStart + vecDir * distance;
  
	local trace = 
	{
		start = vecStart,
		end = fixup_origin,
		hullmin = mins,
		hullmax = maxs,
		mask = MASK_PLAYERSOLID,
		ignore = vehicle
	};
	
	TraceHull(trace);
	if (trace.fraction < 1.0)
		return false;
  
  	return true;
}

function CanExit()
{
	local mins = driver.GetPlayerMins();
	local maxs = driver.GetPlayerMaxs();

	local vehicle_center = vehicle.GetCenter();
	local vehicle_mins = vehicle_center + vehicle.GetBoundingMins();
	local vehicle_maxs = vehicle_center + vehicle.GetBoundingMaxs();
	fixup_origin = Vector((vehicle_mins.x + vehicle_maxs.x) * 0.5, (vehicle_mins.y + vehicle_maxs.y) * 0.5, vehicle_maxs.z + 50.0);
	
	local trace = 
	{
		start = vehicle.GetCenter(),
		end = fixup_origin,
		hullmin = mins,
		hullmax = maxs,
		mask = MASK_PLAYERSOLID,
		ignore = vehicle
	};
	TraceHull(trace);
	if (!("startsolid" in trace))
		return true;
	
	return false;
}

function EnterTrain(player)
{
	if (!can_enter || driver)
		return;
	
	local player_scope = player.GetScriptScope();
	player_scope.vehicle = vehicle;
	player_scope.vehicle_scope = this;
	driver = player;
	can_exit = false;

	driver.SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE);
	driver.SetMoveType(MOVETYPE_NONE, 0);
	
	driver.AcceptInput("SetParent", "!activator", vehicle, vehicle);
	
	driver.RemoveFlag(FL_DUCKING);
	
	NetProps.SetPropBool(driver, "pl.deadflag", true);
	EntFireByHandle(vehicle, "CallScriptFunction", "EnableExit", 1.0, null, null);
}

function ExitTrain(dead, teleport)
{
	if (driver)
	{	
		if (!dead)
			NetProps.SetPropBool(driver, "pl.deadflag", false);
		
		driver.AcceptInput("ClearParent", "", null, null)
		
		fixup_angles = driver.EyeAngles();				
			
		fixup_angles.z = 0.0; // no roll
		
		driver.SetCollisionGroup(COLLISION_GROUP_PLAYER);
		driver.SetMoveType(MOVETYPE_WALK, 0);
	
		driver.SnapEyeAngles(fixup_angles);
		driver.SetAbsVelocity(vehicle.GetPhysVelocity());		

		
		local weapon = driver.GetActiveWeapon();
		if (weapon)
		{
			NetProps.SetPropEntity(driver, "m_hActiveWeapon", null);
			driver.Weapon_Switch(weapon);
		}
	
		local driver_scope = driver.GetScriptScope();
		driver_scope.vehicle = null;
		driver_scope.vehicle_scope = null;
		driver = null;
		
	}

	
	can_enter = false;
	EntFireByHandle(vehicle, "CallScriptFunction", "EnableEnter", 1.0, null, null);
}

local snd_carhorn_cooldown = 0.0

function Think() 
{
	
	if (driver)
	{
		local buttons = NetProps.GetPropInt(driver, "m_nButtons");
		
		if (!(buttons & (IN_FORWARD|IN_BACK)))
		{
			vehicle.AcceptInput("SetSpeedDirAccel", "0", vehicle, vehicle)
			if (TrainHandling[vehicle.GetName()].HasWagons)
				EntFire(TrainHandling[vehicle.GetName()].LinkedWagons, "SetSpeedDirAccel", "0", 0, null)
		}
		else if (buttons & IN_FORWARD)
		{
			vehicle.AcceptInput("SetSpeedDirAccel", "1", vehicle, vehicle)
			if (TrainHandling[vehicle.GetName()].HasWagons)
				EntFire(TrainHandling[vehicle.GetName()].LinkedWagons, "SetSpeedDirAccel", "1", 0, null)
		}
		else if (buttons & IN_BACK)
		{
			vehicle.AcceptInput("SetSpeedDirAccel", "0", vehicle, vehicle)
			if (TrainHandling[vehicle.GetName()].HasWagons)
				EntFire(TrainHandling[vehicle.GetName()].LinkedWagons, "SetSpeedDirAccel", "0", 0, null)
		}
			
		if (snd_carhorn_cooldown < Time() && buttons & IN_ATTACK2)
		{
			EmitSoundEx({
				sound_name = TrainHandling[vehicle.GetName()].sfx_horn,
				volume = 1,
				sound_level = 80,
				entity = vehicle,
			});
			snd_carhorn_cooldown = Time() + TrainHandling[vehicle.GetName()].delay_horn;
		}
		
		if (snd_carhorn_cooldown > Time()) return	
		
		if (can_exit)
		{
			if ((buttons & IN_USE) || (buttons & IN_JUMP) || driver.IsUsingActionSlot())
				ExitTrain(false, true);
		}
			
		return -1;
	}
	else
	{
		return 0.1;
	}
}

if (!("TrainEvents" in getroottable()))
	::TrainEvents <- {};
::TrainEvents.clear();
::TrainEvents =
{
	OnGameEvent_player_spawn = function(params)
	{
		local player = GetPlayerFromUserID(params.userid);
		if (!player)
			return;
		
		if (params.team == 0) // unassigned
		{
			TrainInitPlayer(player)
			return;
		}
		
		if (params.team & 2)
		{
			// respawned while in a vehicle?
			local vehicle_scope = player.GetScriptScope().vehicle_scope;
			if (vehicle_scope)
				vehicle_scope.ExitTrain(false, false);
			
			player.AddEFlags(EFL_IS_BEING_LIFTED_BY_BARNACLE); // prevents game's +use from passing to vehicle
		}
	}

	OnGameEvent_player_death = function(params)
	{
		local player = GetPlayerFromUserID(params.userid);
		if (!player)
			return;
		if (params.death_flags & 32) // dead ringer
			return;
			
		local scope = player.GetScriptScope();
		if (scope && scope.vehicle_scope)
			scope.vehicle_scope.ExitTrain(true, true);
	}

	OnGameEvent_player_disconnect = function(params)
	{
		local player = GetPlayerFromUserID(params.userid);
		if (!player)
			return;
			
		local scope = player.GetScriptScope();
		if (scope && scope.vehicle_scope)
			scope.vehicle_scope.ExitTrain(true, false);
	}

	OnGameEvent_scorestats_accumulated_update = function(params)
	{

			for (local vehicle; vehicle = Entities.FindByClassname(vehicle, "func_tracktrain");)
			{
				if (NetProps.GetPropString(vehicle, "m_iszVScripts").len() > 0)
					vehicle.GetScriptScope().ExitTrain(false, false);
			}
			for (local vehicle; vehicle = Entities.FindByClassname(vehicle, "func_tanktrain");)
			{
				if (NetProps.GetPropString(vehicle, "m_iszVScripts").len() > 0)
					vehicle.GetScriptScope().ExitTrain(false, false);
			}
	}

	OnScriptHook_OnTakeDamage = function(params)
	{
		local victim = params.const_entity;
		local inflictor = params.inflictor;
		
		if (victim.GetClassname() == "func_tracktrain")
		{
			// pass damage to driver
			local driver = victim.GetScriptScope().driver;
			if (driver)
			{
				driver.TakeDamageCustom(
					params.inflictor, 
					params.attacker,
					params.weapon,
					params.damage_force,
					params.damage_position, 
					params.damage,
					params.damage_type, 
					params.damage_custom);
			}
		}
		else if (inflictor && inflictor.GetClassname() == "func_tracktrain")
		{
			TrainDmgOwner.SetAbsOrigin(inflictor.GetOrigin());
			
			// make driver own the damage
			params.damage_type = DMG_VEHICLE; // unfortunately this doesn't set the kill icon
			params.inflictor = TrainDmgOwner;
			params.attacker = inflictor.GetScriptScope().driver;
		}
	}
}
__CollectGameEventCallbacks(TrainEvents)

for (local player; player = Entities.FindByClassname(player, "player");)
{
	local scope = player.GetScriptScope()
	if (!scope || !("vehicle" in scope))
		TrainInitPlayer(player)
}