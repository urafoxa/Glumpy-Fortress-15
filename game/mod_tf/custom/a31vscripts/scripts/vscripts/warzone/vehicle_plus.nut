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
const FL_DUCKING = 2;
const EFL_IS_BEING_LIFTED_BY_BARNACLE = 1048576;
const MASK_PLAYERSOLID = 33636363; // CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_WINDOW|CONTENTS_PLAYERCLIP|CONTENTS_GRATE|CONTENTS_MONSTER
const DMG_VEHICLE = 16;

//HANDLING TABLE - THIS IS FOR THE VEHICLES ON THE MAP
local CarHandling = {
	"models/props_vehicles_drive/embargo/tank.mdl" : {VisibleDriver = true, TankVoice = true, HasWeapons = true, sfx_horn = "mvm/mvm_tank_horn.wav", delay_horn = 1.2, sfx_primarygun = "weapons/rocket_ll_shoot.wav", delay_primarygun = 0.5 },
	"models/props_vehicles_drive/morevehicles/chieftain.mdl" : {VisibleDriver = false, TankVoice = false, HasWeapons = false, sfx_horn = "ambient/mvm_warehouse/car_horn_03.wav", delay_horn = 0.8},
	"models/props_vehicles_drive/morevehicles/belair.mdl" : {VisibleDriver = false, TankVoice = false, HasWeapons = false, sfx_horn = "ambient/mvm_warehouse/car_horn_03.wav", delay_horn = 0.8},
	"models/buggy.mdl" : {VisibleDriver = true, TankVoice = false, HasWeapons = true, sfx_horn = "ambient/mvm_warehouse/car_horn_03.wav", delay_horn = 0.8, sfx_primarygun = "weapons/rocket_ll_shoot.wav", delay_primarygun = 0.5},
}
//DAMAGE TABLE
local DamageTable = {
	"models/props_vehicles_drive/embargo/tank.mdl" : {CanDamage = true, HP = 1000, FlyStrenght = 250, DamageRadius = 250, sfx_damage = "mvm/mvm_tank_explode.wav"}
	"models/props_vehicles_drive/morevehicles/chieftain.mdl" : {CanDamage = true, HP = 1000, FlyStrenght = 250, DamageRadius = 250, sfx_damage = "mvm/mvm_tank_explode.wav"}
	"models/props_vehicles_drive/morevehicles/belair.mdl" : {CanDamage = true, HP = 1000, FlyStrenght = 250, DamageRadius = 250, sfx_damage = "mvm/mvm_tank_explode.wav"}
	"models/buggy.mdl" : {CanDamage = true, HP = 1000, FlyStrenght = 250, DamageRadius = 250, sfx_damage = "mvm/mvm_tank_explode.wav"}
}
// PASSENGER TABLE
local SeatTable = {
    "models/props_vehicles_drive/morevehicles/chieftain.mdl" : { Seats = [Vector(0,0,0), Vector(0,0,0)] }
    "models/props_vehicles_drive/morevehicles/belair.mdl" : { Seats = [Vector(0,0,0), Vector(0,0,0)] }
	"models/props_vehicles_drive/embargo/tank.mdl" : { Seats = [Vector(0,0,0), Vector(0,0,0)] }
    "models/buggy.mdl" : { Weapononseats = [1,2,3], Seats = [Vector(0,0,0), Vector(0,0,0),Vector(0,0,0)] }
}

//PRECACHE SOUNDS
foreach (CarType,CarInfo in CarHandling) 
{
	PrecacheSound(CarHandling[CarType].sfx_horn);
    if ("sfx_primarygun" in CarHandling[CarType]){ PrecacheSound(CarHandling[CarType].sfx_primarygun)}
}
foreach (BoomType,BoomInfo in DamageTable) 
{
	PrecacheSound(DamageTable[BoomType].sfx_damage);
    if ("sfx_damage" in DamageTable[BoomType]){ PrecacheSound(DamageTable[BoomType].sfx_damage)}
}
PrecacheSound("doors/handle_pushbar_locked1.wav")

//Check the car state
IsDestroyed <- false

::VehicleInitPlayer <- function(player)
{
	player.ValidateScriptScope();
	local scope = player.GetScriptScope();
	scope.vehicle <- null;
	scope.vehicle_scope <- null;
}

::VehicleThink <- function()
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
			if (trace.hit && trace.enthit.GetClassname() == "prop_vehicle_driveable")
			{
				if (NetProps.GetPropBool(trace.enthit, "m_bLocked") == false)
					trace.enthit.GetScriptScope().Enter_proxy(player);
				else if (!trace.enthit.GetScriptScope().IsDestroyed)
				{
					EmitSoundEx({
						sound_name = "doors/handle_pushbar_locked1.wav",
						volume = 1,
						sound_level = 80,
						entity = trace.enthit,
					});
				}
			}
		}
	}	
	return 0.1
}

// This hack allows vehicle damage to show the train kil licon
if (!("VehicleDmgOwner" in getroottable()) || !VehicleDmgOwner.IsValid())
{
	::VehicleDmgOwner <- SpawnEntityFromTable("handle_dummy", {});
	VehicleDmgOwner.KeyValueFromString("classname", "vehicle");
}
AddThinkToEnt(VehicleDmgOwner, "VehicleThink")

function Precache()
{
	driver <- null;
	vehicle <- self;
	can_enter <- true;
	can_exit <- false;
	fixup_origin <- Vector();
	fixup_angles <- QAngle();
	player_array <- array(SeatTable[vehicle.GetModelName()].Seats.len(),null) // put it in the precache of the vehicle.
	
    // unused spawnflags are used to define non-car vehicle type
	local flags = NetProps.GetPropInt(self, "m_spawnflags");
	if (flags > 0)
		NetProps.SetPropInt(self, "m_nVehicleType", flags);
	
	NetProps.SetPropInt(self, "m_spawnflags", 1); // per-frame physics must be on
	
	//Weapon Spawner
	DriversTeam <- 0;
	if (CarHandling[vehicle.GetModelName()].HasWeapons)
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
	}
	//Damage System
	if(vehicle.GetModelName() in DamageTable)
	{	
		NetProps.SetPropInt(vehicle, "m_takedamage", 2);
		vehicle.SetMaxHealth(DamageTable[vehicle.GetModelName()].HP)
		vehicle.SetHealth(DamageTable[vehicle.GetModelName()].HP)
	}
}

// Weaponized System 
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

function DissolveCar()
{

}

function EnableEnter()
{
	can_enter = true;
}

function EnableExit()
{
	can_exit = true;
}

function ExplodeCar()
{
	IsDestroyed = true
	NetProps.SetPropBool(vehicle, "m_bLocked", true);
	EmitSoundEx({
		sound_name = DamageTable[vehicle.GetModelName()].sfx_damage,
		volume = 1,
		sound_level = 80,
		entity = vehicle,
	});
	DispatchParticleEffect("mvm_tank_destroy_bloom", vehicle.GetOrigin() + Vector(0, 0, 125), Vector(0, 90, 0))
	DispatchParticleEffect("mvm_tank_destroy", vehicle.GetOrigin() + Vector(0, 0, 125), Vector(0, 90, 0))
	EntFireByHandle(vehicle, "HandbrakeOn", "", -1, null, null); 
	DeathExplosion <- SpawnEntityFromTable("point_push", {
		magnitude = DamageTable[vehicle.GetModelName()].FlyStrenght,
		radius = DamageTable[vehicle.GetModelName()].DamageRadius,
		enabled = 1,
		spawnflags = 24,
		origin = vehicle.GetOrigin(),
	})
	EntFireByHandle(vehicle, "Addoutput", "renderfx 5" , 6.1, null, null);
	EntFireByHandle(vehicle, "Kill", "" , 7.1, null, null);
	EntFireByHandle(DeathExplosion, "Kill", "", 0.25, null, null)
	if (driver)
		driver.TakeDamageCustom(driver,driver,null,Vector(RandomInt(-150000,150000),RandomInt(-150000,150000),150000),vehicle.GetOrigin(),999,Constants.FDmgType.DMG_CRUSH,Constants.ETFDmgCustom.TF_DMG_CUSTOM_TELEFRAG)						
	//Chain Reaction Test
	for (local DamageOther; DamageOther = Entities.FindByClassnameWithin(DamageOther, "prop_vehicle_driveable", vehicle.GetOrigin(), DamageTable[vehicle.GetModelName()].DamageRadius);)
	{
		if (DamageTable[DamageOther.GetModelName()].CanDamage)
		{
			DamageOther.SetHealth(DamageOther.GetHealth()-150)
		}
	}
	for (local DamagePlayer; DamagePlayer = Entities.FindByClassnameWithin(DamagePlayer, "player", vehicle.GetOrigin(), DamageTable[vehicle.GetModelName()].DamageRadius);)
	{
		DamagePlayer.TakeDamageCustom(DamagePlayer,DamagePlayer,null,Vector(RandomInt(-150000,150000),RandomInt(-150000,150000),150000),vehicle.GetOrigin(),250,Constants.FDmgType.DMG_CRUSH,Constants.ETFDmgCustom.TF_DMG_CUSTOM_NONE)
	}
	for (local DamageNPC; DamageNPC = Entities.FindByClassnameWithin(DamageNPC, "tf_zombie", vehicle.GetOrigin(), DamageTable[vehicle.GetModelName()].DamageRadius);)
	{
		DamageNPC.AcceptInput("BecomeRagdoll", "", null,null)
	}
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
	
	local origin;
	local attachment = vehicle.LookupAttachment("vehicle_driver_eyes");
	if (attachment > 0)
		origin = vehicle.GetAttachmentOrigin(attachment);
	else
		origin = vehicle.GetCenter();
	origin.z -= 64.0;
	driver.SetAbsOrigin(origin);
	driver.SetAbsVelocity(Vector());
	
	driver.AcceptInput("SetParent", "!activator", vehicle, vehicle);
	
	driver.RemoveFlag(FL_DUCKING);
	NetProps.SetPropBool(driver, "m_Local.m_bDrawViewmodel", false);
	NetProps.SetPropInt(driver, "m_Shared.m_nAirDucked", 8);
	
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
		
	vehicle.AcceptInput("TurnOn", "", null, null)
	vehicle.AcceptInput("HandbrakeOff", "", null, null)
	EntFireByHandle(vehicle, "CallScriptFunction", "EnableExit", 1.0, null, null);
}

function Enter_proxy(player)
{
if(!CBaseEntity.IsValid.call(player))
{
    return printl("Veh_plus: Invalid Passenger!");
}
// remove any players that disconnected from the array ( call this in ongameevent_player_disconnect too )
	update_passengers_state()
    if(player_array.find(player) == null)
    {
        local seat_index = 0
		foreach(i, element in player_array)
			{
				if(element == null)
				{
					element = player
					seat_index = i
					break;
				}
				printl(element)
			}

        // teleport them to the vehicle and parent them.
        if(player_array[0] == player)
        {
            Enter(player)
        }
        else
        {
			player.AcceptInput("SetParent", "!activator", vehicle, vehicle)
            player.SetAbsOrigin(self.GetOrigin() + SeatTable[vehicle.GetModelName()].Seats[seat_index])
        }
    }
}
function update_passengers_state()
{
for(local i = 0;i < player_array.len();i++)
    {
        if(!CBaseEntity.IsValid.call(player_array[i])) 
            player_array[i] = null
    }
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
		
		driver.AcceptInput("ClearParent", "", null, null)
		
		fixup_origin = driver.GetOrigin() + Vector(0, 0, 8);
		fixup_angles = driver.EyeAngles();				
	
		if (!CanExit())
		{
			// too bad
			//printl("Can't exit!");
		}
			
		fixup_angles.z = 0.0; // no roll
		
		driver.SetCollisionGroup(COLLISION_GROUP_PLAYER);
		driver.SetMoveType(MOVETYPE_WALK, 0);
	
		driver.SetAbsOrigin(fixup_origin);
		driver.SnapEyeAngles(fixup_angles);
		driver.SetAbsVelocity(vehicle.GetPhysVelocity());		

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
	vehicle.AcceptInput("TurnOff", "", null, null); 
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
			NetProps.SetPropFloat(self, "m_VehiclePhysics.m_controls.steering", 1.0);
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
		{
			NetProps.SetPropFloat(self, "m_VehiclePhysics.m_controls.throttle", 1);
		}
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
		if ("InvertedAim" in CarHandling[vehicle.GetModelName()])
		{
			vehicle.SetPoseParameter(GetCar_Gun_Yaw, playerEyeRoll)
			vehicle.SetPoseParameter(GetCar_Gun_Pitch, playerEyePitch)
		}
		else
		{
			vehicle.SetPoseParameter(GetCar_Gun_Yaw, -playerEyeRoll)
			vehicle.SetPoseParameter(GetCar_Gun_Pitch, -playerEyePitch)
		}

		// Shooting the projectile
		local Get_Muzzle_Att = vehicle.LookupAttachment("Muzzle")
		local Gun_Muzzle_Pos = vehicle.GetAttachmentOrigin(Get_Muzzle_Att)
		local Gun_Muzzle_Rot = vehicle.GetAttachmentAngles(Get_Muzzle_Att)
		if (CarHandling[vehicle.GetModelName()].HasWeapons)
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
			if ((buttons & IN_USE) || driver.IsUsingActionSlot())
				Exit(false, true);
			foreach( player in player_array )
			{
				if(CBaseEntity.IsValid.call(player))
				{
					if(NetProps.GetPropInt(player,"m_nButtons") & IN_USE || player.IsUsingActionSlot()) 
					{
						player.AcceptInput("ClearParent", "", null, null)
						player = null
						// Reuse the Exit() teleport position code here (?)
					}
				}
			}
		}
		if(vehicle.GetModelName() in DamageTable && !IsDestroyed)
		{
			if (DamageTable[vehicle.GetModelName()].CanDamage)
			{
				if (vehicle.GetHealth() < 900)
				{
					ExplodeCar()
					printl("Boom!")
				}
			}
		}
		return -1;
	}
	else
	{
		//If you wanna crash or spam explosions, remove IsDestroyed :)
		if(vehicle.GetModelName() in DamageTable && !IsDestroyed)
		{
			if (DamageTable[vehicle.GetModelName()].CanDamage)
			{
				if (vehicle.GetHealth() < 900)
				{
					ExplodeCar()
					printl("Boom!")
				}
			}
		}
		return 0.1;
	}
}

if (!("VehicleEvents" in getroottable()))
	::VehicleEvents <- {};
::VehicleEvents.clear();
::VehicleEvents =
{
	OnGameEvent_player_spawn = function(params)
	{
		local player = GetPlayerFromUserID(params.userid);
		if (!player)
			return;
		
		if (params.team == 0) // unassigned
		{
			VehicleInitPlayer(player)
			return;
		}
		
		if (params.team & 2)
		{
			// respawned while in a vehicle?
			local vehicle_scope = player.GetScriptScope().vehicle_scope;
			if (vehicle_scope)
			{
				vehicle_scope.Exit(false, false);
				vehicle_scope.update_passengers_state()
			}
			
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
		{
			scope.vehicle_scope.Exit(true, true);
			foreach(item in scope.vehicle_scope.player_array){
				if(item == player)
				item = null
			}
		}
	}

	OnGameEvent_player_disconnect = function(params)
	{
		local player = GetPlayerFromUserID(params.userid);
		if (!player)
			return;
			
		local scope = player.GetScriptScope();
		if (scope && scope.vehicle_scope)
		{
			scope.vehicle_scope.Exit(true, false);
			scope.vehicle_scope.update_passengers_state()
		}
	}

	OnGameEvent_scorestats_accumulated_update = function(params)
	{
		for (local vehicle; vehicle = Entities.FindByClassname(vehicle, "prop_vehicle_driveable");)
		{
			vehicle.GetScriptScope().Exit(false, false);
			foreach(player in vehicle.GetScriptScope().player_array)
			{
				printl("Removed " + player)
				player.AcceptInput("ClearParent", "", null, null)
				player = null
			}
		}
	}
	//MVM Fix


	OnScriptHook_OnTakeDamage = function(params)
	{
		local victim = params.const_entity;
		local inflictor = params.inflictor;
		local vehicle = params.const_entity;
		
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

			params.damage_type = DMG_VEHICLE; // unfortunately this doesn't set the kill icon
			params.inflictor = VehicleDmgOwner;
			params.attacker = inflictor.GetScriptScope().driver;
			printl("Damage Done: " + params.damage)

		}
		// The Whole Damage system...
		local vehiclescope = vehicle.GetScriptScope()
		if (vehicle.GetClassname() == "prop_vehicle_driveable" && !vehiclescope.IsDestroyed)
		{
			if(vehicle.GetModelName() in DamageTable)
			{
				if (DamageTable[vehicle.GetModelName()].CanDamage)  
				{
					if (vehiclescope.driver)
					{
						if (inflictor.GetTeam() != vehicle.GetScriptScope().DriversTeam || Convars.GetBool("mp_friendlyfire"))
						{
							vehicle.SetHealth(vehicle.GetHealth()-params.damage)
							printl("Attacker Team " + inflictor.GetTeam())
							printl("Driver Team " + driver.GetTeam())
							printl("Health " + vehicle.GetHealth())
						}
					}
					else
					{
						vehicle.SetHealth(vehicle.GetHealth()-params.damage)
					}
				}
			}
		}
	}
}
__CollectGameEventCallbacks(VehicleEvents)

for (local player; player = Entities.FindByClassname(player, "player");)
{
	local scope = player.GetScriptScope()
	if (!scope || !("vehicle" in scope))
		VehicleInitPlayer(player)
}