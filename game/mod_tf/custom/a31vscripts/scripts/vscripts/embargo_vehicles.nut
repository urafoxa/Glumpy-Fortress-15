// original by ficool2
// upgraded by Alien31 w/Help of Gidi3, ficool2, and the rest of people in the TF2Maps discord
// Alien31 Features: Car Lock check, Horn, Basic projectile Shooting, Turbo, Handbrake
// Look ask/add me first before unpacking and stealin ok? if not. ur a jackass

Convars.SetValue("sv_turbophysics", 0);

const IN_ATTACK = 1;
const IN_JUMP = 2;
const IN_FORWARD = 8;
const IN_BACK = 16;
const IN_USE = 32;
const IN_MOVELEFT = 512;
const IN_MOVERIGHT = 1024;
const IN_ATTACK2 = 2048;
const IN_RELOAD = 8192;

const DMG_CRUSH = 1;

const COLLISION_GROUP_PLAYER = 5;
const COLLISION_GROUP_IN_VEHICLE = 10;

const MOVETYPE_NONE = 0;
const MOVETYPE_WALK = 2;

const EFL_KILLME = 1;
const EFL_IS_BEING_LIFTED_BY_BARNACLE = 1048576;

const MASK_PLAYERSOLID = 33636363; // CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_WINDOW|CONTENTS_PLAYERCLIP|CONTENTS_GRATE|CONTENTS_MONSTER

const DMG_VEHICLE = 16;

//HANDLING TABLE - THIS IS FOR THE VEHICLES ON THE MAP
//REMEMBER TO PRECACHE THE NECESSARY ASSETS (SOUNDS/MODELS)
// TankVoice - true/false | Will make soldier play the Panzer pants voicelines upon entering the vehicle and firing with the weapon
// HasWeapons - true/false | Spawns a tf_weapon_mimic in order to fire projectiles
// delay_horn - seconds | delay to prevent spamming the horn
// delay_primarygun - same as above, but avoid spam of the weapon
local CarHandling = {
	"models/props_vehicles_drive/embargo/tank.mdl" : {VisibleDriver = true, TankVoice = true, HasWeapons = true, sfx_horn = "mvm/mvm_tank_horn.wav", delay_horn = 1.2, sfx_primarygun = "weapons/rocket_ll_shoot.wav", delay_primarygun = 0.5 },
	"models/props_vehicles_drive/morevehicles/chieftain.mdl" : {VisibleDriver = false, TankVoice = false, HasWeapons = false, sfx_horn = "ambient/mvm_warehouse/car_horn_03.wav", delay_horn = 0.8},
	"models/props_vehicles_drive/morevehicles/belair.mdl" : {VisibleDriver = false, TankVoice = false, HasWeapons = false, sfx_horn = "ambient/mvm_warehouse/car_horn_03.wav", delay_horn = 0.8},
	"models/combine_apc.mdl" : {VisibleDriver = false, TankVoice = false, HasWeapons = false, sfx_horn = "ambient/mvm_warehouse/car_horn_03.wav", delay_horn = 0.8},
	"models/airboat.mdl" : {VisibleDriver = false, TankVoice = false, HasWeapons = false, sfx_horn = "ambient/mvm_warehouse/car_horn_03.wav", delay_horn = 0.8},
}

// This hack allows vehicle damage to show the train kil licon
if (!("VehicleDmgOwner" in getroottable()) || !VehicleDmgOwner.IsValid())
{
	::VehicleDmgOwner <- SpawnEntityFromTable("handle_dummy", {});
	VehicleDmgOwner.KeyValueFromString("classname", "vehicle");
}

//Check the car if it got guns
local CarGotWeaponized = 0

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
	if (flags > 0)
		NetProps.SetPropInt(self, "m_nVehicleType", flags);
	
	NetProps.SetPropInt(self, "m_spawnflags", 1); // per-frame physics must be on

	DriversTeam <- 0;
	if (CarGotWeaponized != 1 && CarHandling[vehicle.GetModelName()].HasWeapons)
	{	
		CarWeaponMimic <- SpawnEntityFromTable("tf_point_weapon_mimic", {
			effect_name = "muzzle_minigun_constant_flare",
			SpeedMax = 1500,
			SpeedMin = 1500,
			WeaponType = 0,
			Damage = 110,
			SplashRadius = 75,
			origin       = vehicle,
		})
		CarWeaponMimic.AcceptInput("SetParent", "!activator", vehicle, vehicle)
		EntFireByHandle(CarWeaponMimic, "SetParentAttachment", "Muzzle", -1, 0.1, null)
		CarGotWeaponized = 1
	}
}

// Weaponized System Prototype
function CarWeapon_Primary(vehicle)
{

	CarWeaponMimic.AcceptInput("FireOnce", "", null, null)
	// Spawned Projectile Owner & Team
	for (local SpawnedProjectile; SpawnedProjectile = Entities.FindByClassname(SpawnedProjectile, "tf_projectile_rocket");)
	{
		if (SpawnedProjectile.GetOwner() == CarWeaponMimic)
		{
			SpawnedProjectile.SetTeam(DriversTeam)
			SpawnedProjectile.SetOwner(driver)
		}
	}
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
	local mins = activator.GetPlayerMins();
	local maxs = activator.GetPlayerMaxs();
	
	local attachment = vehicle.LookupAttachment("vehicle_driver_exit");
	if (attachment > 0)
	{
		local attachment_origin = vehicle.GetAttachmentOrigin(attachment);
	
		local trace = 
		{
			start = attachment_origin + Vector(0, 0, 12),
			end = attachment_origin,
			hullmin = mins,
			hullmax = maxs,
			mask = MASK_PLAYERSOLID,
			ignore = vehicle
		};
		TraceHull(trace);

		if (!("startsolid" in trace))
		{
			fixup_origin = attachment_origin;
			fixup_angles = vehicle.GetAttachmentAngles(attachment);
			return true;
		}
	}
	
	if (CheckExitPoint(90.0, 90.0, mins, maxs))
		return true;
	if (CheckExitPoint(-90.0, 90.0, mins, maxs))
		return true
	if (CheckExitPoint(0.0, 100.0, mins, maxs))
		return true;
	if (CheckExitPoint(180.0, 170.0, mins, maxs))
		return true;

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

function FixupDriverEntry()
{
	if (!activator)
		return;
		
	local origin;
	local attachment = vehicle.LookupAttachment("vehicle_driver_eyes");
	if (attachment > 0)
		origin = vehicle.GetAttachmentOrigin(attachment);
	else
		origin = vehicle.GetCenter();

	origin.z -= 64.0;
	
	activator.SetAbsOrigin(origin);
}

function FixupDriverExit()
{
	if (!activator)
		return;

	fixup_origin = activator.GetOrigin() + Vector(0, 0, 8);
	fixup_angles = activator.EyeAngles();				

	if (!CanExit())
	{
		// too bad
		//printl("Can't exit!");
	}
		
	fixup_angles.z = 0.0; // no roll
	
	activator.SetCollisionGroup(COLLISION_GROUP_PLAYER);
	activator.SetMoveType(MOVETYPE_WALK, 0);

	activator.SetAbsOrigin(fixup_origin);
	activator.SnapEyeAngles(fixup_angles);
	activator.SetAbsVelocity(vehicle.GetPhysVelocity());
}


function Enter(player)
{		

	
	if (!can_enter || driver)
		return;
	
	if (CarHandling[vehicle.GetModelName()].VisibleDriver)
	{
		vehicle.SetBodygroup(1,1)
	}

	local player_scope = player.GetScriptScope();
	player_scope.vehicle = vehicle;
	player_scope.vehicle_scope = this;
	driver = player;
	can_exit = false;
	DriversTeam = driver.GetTeam();

	driver.SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE);
	driver.SetMoveType(MOVETYPE_NONE, 0);
	
	driver.SetAbsVelocity(Vector());
	EntFireByHandle(vehicle, "CallScriptFunction", "FixupDriverEntry", -1, driver, null);
	EntFireByHandle(driver, "SetParent", "!activator", -1, vehicle, null);
	
	NetProps.SetPropBool(driver, "m_Local.m_bDrawViewmodel", false);

	if (CarHandling[vehicle.GetModelName()].TankVoice && driver.GetPlayerClass() == 3)
	{
		driver.PlayScene("scenes/player/soldier/low/taunt_vehicle_tank.vcd",0)
	}
	// INVISIBLE WEAPONS
	local weapon = driver.GetActiveWeapon();
	if (weapon)
	{
		NetProps.SetPropEntity(driver, "m_hActiveWeapon", null);
		driver.Weapon_Switch(weapon);
		if (!CarHandling[vehicle.GetModelName()].VisibleDriver)
			NetProps.SetPropInt(weapon, "m_nRenderMode", 10);
	}
	// INVISIBLE COSMETICS
	for (local wearable = driver.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
	{
	if (!CarHandling[vehicle.GetModelName()].VisibleDriver)
		{
		NetProps.SetPropInt(wearable, "m_nRenderMode", 10);
		}
	}

	NetProps.SetPropBool(driver, "pl.deadflag", true);
	driver.AddCustomAttribute("disable weapon switch", 1, -1);
	driver.AddCustomAttribute("no_attack", 1, -1);
	driver.AddCustomAttribute("no_duck", 1, -1);
	// INVISIBLE DRIVER [Vehicle Hatch System]
	if (!CarHandling[vehicle.GetModelName()].VisibleDriver)
		NetProps.SetPropInt(driver, "m_nRenderMode", 10);
		
	EntFireByHandle(vehicle, "TurnOn", "", -1, null, null);
	EntFireByHandle(vehicle, "HandbrakeOff", "", -1, null, null); 
	EntFireByHandle(vehicle, "CallScriptFunction", "EnableExit", 1.0, null, null);
}

function Exit(dead, teleport)
{
	if (CarHandling[vehicle.GetModelName()].VisibleDriver)
	{
		vehicle.SetBodygroup(1,0)
	}
	if (driver)
	{	
		if (!dead)
			NetProps.SetPropBool(driver, "pl.deadflag", false);
		driver.RemoveCustomAttribute("disable weapon switch");
		driver.RemoveCustomAttribute("no_attack");
		driver.RemoveCustomAttribute("no_duck");
		NetProps.SetPropInt(driver, "m_nRenderMode", 0);

		EntFireByHandle(driver, "ClearParent", "", -1, null, null);
		EntFireByHandle(vehicle, "CallScriptFunction", "FixupDriverExit", -1, driver, null);
		
		NetProps.SetPropBool(driver, "m_Local.m_bDrawViewmodel", true);

		local weapon = driver.GetActiveWeapon();
		if (weapon)
		{
			NetProps.SetPropEntity(driver, "m_hActiveWeapon", null);
			driver.Weapon_Switch(weapon);
			NetProps.SetPropInt(weapon, "m_nRenderMode", 0);
		}
		
		for (local wearable = driver.FirstMoveChild(); wearable != null; wearable = wearable.NextMovePeer())
				NetProps.SetPropInt(wearable, "m_nRenderMode", 0);
	
		local driver_scope = driver.GetScriptScope();
		driver_scope.vehicle = null;
		driver_scope.vehicle_scope = null;
		driver = null;
		
	}
	
	NetProps.SetPropFloat(vehicle, "m_VehiclePhysics.m_controls.steering", 0);
	NetProps.SetPropFloat(vehicle, "m_VehiclePhysics.m_controls.throttle", 0);
	EntFireByHandle(vehicle, "TurnOff", "", -1, null, null); 
	EntFireByHandle(vehicle, "TurnOn", "", 0.2, null, null);
	EntFireByHandle(vehicle, "HandbrakeOn", "", -1, null, null); 
	
	can_enter = false;
	EntFireByHandle(vehicle, "CallScriptFunction", "EnableEnter", 1.0, null, null);
}

local snd_carhorn_cooldown = 0.0
local cargun_rocket_timer = 0.0

function CarGun_AngleNormalize(target)
{
    target %= 360.0;
    if (target > 180.0)
        target -= 360.0;
    else if (target < -180.0)
        target += 360.0;
    return target;
}

function Think() 
{
	self.StudioFrameAdvance();
	
	
	
	if (driver)
	{
		local buttons = NetProps.GetPropInt(driver, "m_nButtons");
	
		if (buttons & IN_MOVERIGHT)
		{
			NetProps.SetPropFloat(self, "m_VehiclePhysics.m_controls.steering", 1.0);
		}
		else if (buttons & IN_MOVELEFT)
			NetProps.SetPropFloat(self, "m_VehiclePhysics.m_controls.steering", -1.0);
		else
			NetProps.SetPropFloat(self, "m_VehiclePhysics.m_controls.steering", 0);
		
		if (!CarHandling[vehicle.GetModelName()].TankVoice)
		{
			if (buttons & IN_RELOAD)
			{
				NetProps.SetPropFloat(self, "m_VehiclePhysics.m_controls.boost", 1);
				NetProps.SetPropBool(self, "params.bTurbo", true);
			}
			else
			{
				NetProps.SetPropFloat(self, "m_VehiclePhysics.m_controls.boost", 0);
				NetProps.SetPropBool(self, "params.bTurbo", false);
			}
		}
			
		if (buttons & IN_JUMP)
			NetProps.SetPropBool(self, "m_VehiclePhysics.m_controls.handbrake", true);
		else
			NetProps.SetPropBool(self, "m_VehiclePhysics.m_controls.handbrake", false);
		
		if (!(buttons & (IN_FORWARD|IN_BACK)))
			NetProps.SetPropFloat(self, "m_VehiclePhysics.m_controls.throttle", 0);
		else if (buttons & IN_FORWARD)
			NetProps.SetPropFloat(self, "m_VehiclePhysics.m_controls.throttle", 1);
		else if (buttons & IN_BACK)
			NetProps.SetPropFloat(self, "m_VehiclePhysics.m_controls.throttle", -1);


		if (snd_carhorn_cooldown < Time() && buttons & IN_ATTACK2)
		{
			EmitSoundEx({
				sound_name = CarHandling[vehicle.GetModelName()].sfx_horn,
				volume = 1,
				sound_level = 80,
				entity = vehicle,
			});
			snd_carhorn_cooldown = Time() + CarHandling[vehicle.GetModelName()].delay_horn;
		}
		
		//AIM CODE 
		local CurrentCarAngles = vehicle.GetAbsAngles()		
		local playerLookAngles = driver.EyeAngles()
		local playerEyeRoll = -90 + CarGun_AngleNormalize(playerLookAngles.y - CurrentCarAngles.y)
		local playerEyePitch = CarGun_AngleNormalize(playerLookAngles.x - CurrentCarAngles.x)

		// Vehicle Get Param
		local GetCar_Gun_Yaw = vehicle.LookupPoseParameter("vehicle_weapon_yaw")
		local GetCar_Gun_Pitch = vehicle.LookupPoseParameter("vehicle_weapon_pitch")

		// Vehicle Aim Setting
		vehicle.SetPoseParameter(GetCar_Gun_Yaw, -playerEyeRoll)
		vehicle.SetPoseParameter(GetCar_Gun_Pitch, -playerEyePitch)

		// Shooting the projectile
		local Get_Muzzle_Att = vehicle.LookupAttachment("Muzzle")
		local Gun_Muzzle_Pos = vehicle.GetAttachmentOrigin(Get_Muzzle_Att)
		local Gun_Muzzle_Rot = vehicle.GetAttachmentAngles(Get_Muzzle_Att)
		if (CarGotWeaponized == 1)
		{
			if (cargun_rocket_timer < Time() && buttons & IN_ATTACK)
			{
				if (driver.GetPlayerClass() == 3)
				{
					RandomInt(0,1)
					if (RandomInt(0,1) == 1)
						driver.PlayScene("scenes/player/soldier/low/taunt_vehicle_tank_fire.vcd",0)
				}
				EmitSoundEx({
					sound_name = CarHandling[vehicle.GetModelName()].sfx_primarygun,
					volume = 1,
					pitch = 80,
					sound_level = 90,
					entity = vehicle,
				});
				driver.ViewPunch(QAngle(-2.5,0,0))
				CarWeapon_Primary(vehicle)
				cargun_rocket_timer = Time() + CarHandling[vehicle.GetModelName()].delay_primarygun;
			}
		}
		
		if (snd_carhorn_cooldown > Time()) return
		if (cargun_rocket_timer > Time()) return
		
		if (can_exit)
		{
			if ((buttons & IN_USE) || NetProps.GetPropBool(driver, "m_bUsingActionSlot"))
				Exit(false, true);
		}
			
		return -1;
	}
	else
	{
		return 0.1;
	}
}

// events

::Vehicle_OnPlayerSpawn <- function(params)
{
	local player = GetPlayerFromUserID(params.userid);
	if (!player)
		return;
		
	player.RemoveEFlags(EFL_KILLME); // added if inside a vehicle on round end
		
	if (params.team == 0) // unassigned
	{
		player.ValidateScriptScope();
		local scope = player.GetScriptScope();
		scope.vehicle <- null;
		scope.vehicle_scope <- null;
		return;
	}
	
	if (params.team & 2)
	{
		// respawned while in a vehicle?
		local vehicle_scope = player.GetScriptScope().vehicle_scope;
		if (vehicle_scope)
			vehicle_scope.Exit(false, false);
		
		player.AddEFlags(EFL_IS_BEING_LIFTED_BY_BARNACLE); // prevents game's +use from passing to vehicle
	}
}

::Vehicle_OnPlayerDeath <- function(params)
{
	local player = GetPlayerFromUserID(params.userid);
	if (!player)
		return;
	if (params.death_flags & 0x20) // dead ringer
		return;
		
	local scope = player.GetScriptScope();
	if (scope && scope.vehicle_scope)
		scope.vehicle_scope.Exit(true, true);
}

::Vehicle_OnPlayerDisconnect <- function(params)
{
	local player = GetPlayerFromUserID(params.userid);
	if (!player)
		return;
		
	local scope = player.GetScriptScope();
	if (scope && scope.vehicle_scope)
		scope.vehicle_scope.Exit(true, false);
}

::Vehicle_OnRoundReset <- function(params)
{
	for (local vehicle; vehicle = Entities.FindByClassname(vehicle, "prop_vehicle_driveable");)
	{
		local vehicle_scope = vehicle.GetScriptScope();
		if (vehicle_scope.driver)
			vehicle_scope.driver.AddEFlags(EFL_KILLME); // prevent player from being deleted
		vehicle.GetScriptScope().Exit(false, false);
	}
}

::Vehicle_OnTakeDamage <- function(params)
{
	local victim = params.const_entity;
	local inflictor = params.inflictor;
	
	if (victim.GetClassname() == "prop_vehicle_driveable")
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
	else if (inflictor && inflictor.GetClassname() == "prop_vehicle_driveable")
	{
		VehicleDmgOwner.SetAbsOrigin(inflictor.GetOrigin());
		
		// make driver own the damage
		params.damage_type = DMG_VEHICLE; // unfortunately this doesn't set the kill icon
		params.inflictor = VehicleDmgOwner;
		params.attacker = inflictor.GetScriptScope().driver;
	}
}