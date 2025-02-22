// Made by Mikusch, special thanks to ficool2 for assistance
// Sorry but i need this! since you guys don't wanna help >:(
// https://steamcommunity.com/profiles/76561198071478507

// Allow expression constants
::CONST <- getconsttable()
CONST.setdelegate({ _newslot = @(k, v) compilestring("const " + k + "=" + (typeof(v) == "string" ? ("\"" + v + "\"") : v))() })

// Fold constants
::ROOT <- getroottable()
if (!("ConstantNamingConvention" in ROOT))
{
	foreach (a, b in Constants)
		foreach (k, v in b)
			if (v == null)
				ROOT[k] <- 0
			else
				ROOT[k] <- v
}

const MENACE_IDLE_SOUND = "Recon.Ping"
const MENACE_WEAPON_SHOOT_SOUND = "Weapon_SMG.Single"
const MENACE_WEAPON_TRACER_PARTICLE = "bullet_pistol_tracer01_red"
const MENACE_WEAPON_MUZZLEFLASH_PARTICLE = "muzzle_smg"
const MENACE_WEAPON_DAMAGE = 3
const MENACE_WEAPON_TIME_FIRE_DELAY = 0.1
const MENACE_WEAPON_SPREAD = 0.1
const MENACE_WEAPON_RANGE = 4000.0
const MENACE_MAX_SPEED = 250.0
const MENACE_FOV = 90.0
const MENACE_MOVE_RANGE = 300.0
const MENACE_TURN_RATE = 5.0

const PATH_UPDATE_INTERVAL = 0.1

const FLT_MAX = 0x7F7FFFFF
const RAD2DEG = 57.295779513

CONST.MASK_SOLID <- (CONTENTS_SOLID | CONTENTS_MOVEABLE | CONTENTS_WINDOW | CONTENTS_MONSTER | CONTENTS_GRATE)
CONST.MASK_BLOCKLOS <- (CONTENTS_SOLID | CONTENTS_MOVEABLE | CONTENTS_BLOCKLOS)
CONST.MASK_BLOCKLOS_AND_NPCS <- (CONST.MASK_BLOCKLOS | CONTENTS_MONSTER)
CONST.SF_NORESPAWN <- (1 << 30)

worldspawn <- Entities.FindByClassname(null, "worldspawn")

local sound_cache = "mvm/giant_pyro/giant_pyro_loop.wav";
PrecacheSound(sound_cache);
PrecacheScriptSound(MENACE_WEAPON_SHOOT_SOUND)
PrecacheScriptSound(MENACE_IDLE_SOUND)
PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = MENACE_WEAPON_TRACER_PARTICLE })

if (!("nextbots" in getroottable()))
	::nextbots <- []

::BotPathPoint <- class
{
	constructor(area, pos, how)
	{
		this.area = area
		this.pos = pos
		this.how = how
	}

	area = null
	pos = null
	how = null
}


class MVM_Boss_Menace
{
	constructor(entity)
	{
		me = entity
		
		locomotion = me.GetLocomotionInterface()

		path_update_time_next = Time()
		path_update_force = true

		sequence_spawn = me.LookupSequence("idle_scanning")
		sequence_idle = me.LookupSequence("test_anim")
		sequence_run = me.LookupSequence("test_anim")
		pose_body_pitch = me.LookupPoseParameter("body_pitch")
		pose_body_yaw = me.LookupPoseParameter("body_yaw")

		me.SetSequence(sequence_spawn)
		
		EmitSoundEx(
		{
			sound_name = sound_cache,
			sound_level = 80,
			entity = me,
			pitch = 85
		});	


		me.AddFlag(FL_NPC)
		me.SetCollisionGroup(COLLISION_GROUP_PLAYER)

		EntFireByHandle(me, "SetStepHeight", "18", -1, null, null)
		EntFireByHandle(me, "SetMaxJumpHeight", "0", -1, null, null)
		me.KeyValueFromFloat("speed", MENACE_MAX_SPEED)

		me.SetSize(Vector(-50, -80, 0), Vector(80, 80, 230))

		nextbots.append(me)
	}
	
	function Precache()
	{
		me.SetSequence(sequence_spawn)		
	}

	function UpdatePath()
	{
		ResetPath()

		if (!HasVictim())
			return
		
		path_target_pos = attack_target.GetOrigin()

		local pos_start = m_vecAbsOrigin + Vector(0, 0, 1)
		local pos_end = path_target_pos + Vector(0, 0, 1)
		
		local area_start = NavMesh.GetNavArea(pos_start, 128.0)
		local area_end = NavMesh.GetNavArea(pos_end, 128.0)
		if (area_start == null)
			area_start = NavMesh.GetNearestNavArea(pos_start, 512.0, false, false)
		if (area_end == null)
			area_end = NavMesh.GetNearestNavArea(pos_end, 512.0, false, false)

		if (area_start == null || area_end == null)
			return false

		if (area_start == area_end)
		{
			path.append(BotPathPoint(area_end, pos_end, NUM_TRAVERSE_TYPES))
			return true
		}
		
		if (!NavMesh.GetNavAreasFromBuildPath(area_start, area_end, pos_end, 0.0, TEAM_ANY, false, path_areas))
			return false

		if (path_areas.len() == 0)
			return false

		local area_target = path_areas["area0"]
		local area = area_target
		local area_count = path_areas.len()

		for (local i = 0; i < area_count && area != null; i++)
		{
			path.append(BotPathPoint(area, area.GetCenter(), area.GetParentHow()))
			area = area.GetParent()
		}
		
		path.append(BotPathPoint(area_start, m_vecAbsOrigin, NUM_TRAVERSE_TYPES))
		path.reverse()
		
		local path_count = path.len()
		for (local i = 1; i < path_count; i++)
		{
			local path_from = path[i - 1]
			local path_to = path[i]
			
			path_to.pos = path_from.area.ComputeClosestPointInPortal(path_to.area, path_to.how, path_from.pos)
		}

		path.append(BotPathPoint(area_end, pos_end, NUM_TRAVERSE_TYPES))
	}

	function AdvancePath()
	{
		local path_len = path.len()
		if (path_len == 0)
			return false

		if ((path[path_index].pos - m_vecAbsOrigin).Length2D() < 32.0)
		{
			path_index++
			if (path_index >= path_len)
			{
				ResetPath()
				return false
			}
		}

		return true
	}

	function ResetPath()
	{
		path_areas.clear()
		path.clear()
		path_index = 0
		path_target_pos = null
	}

	function Laugh()
	{
		if (next_laugh_time <= curtime)
		{
			next_laugh_time = curtime + RandomFloat(4.0, 5.0)

			me.EmitSound(MENACE_IDLE_SOUND)
		}
	}

	function LookAtEntity(entity)
	{
		local look_ang = LookAt(entity.GetCenter())

		// Crouch jumping or taunting makes the box weird
		if (entity.IsPlayer() && !(entity.GetFlags() & FL_ONGROUND) && entity.GetFlags() & FL_DUCKING || entity.InCond(TF_COND_TAUNTING))
		{
			local bone = entity.LookupBone("neck_3")
			if (bone != 0)
			{
				look_ang = LookAt(entity.GetBoneOrigin(bone))
			}
		}

		return look_ang
	}

	function LookAt(pos)
	{
		look_dir = pos - m_vecEyePosition
		look_dir.Norm()

		local look_angle = atan2(look_dir.y, look_dir.x)
		local look_ang = QAngle(0, look_angle * RAD2DEG, 0)

		// Smoothly turn towards the target position
		local current_yaw = m_angAbsRotation.y
		local target_yaw = look_ang.y
		local delta_yaw = target_yaw - current_yaw

		delta_yaw = AngleNormalize(delta_yaw)
		
		// Make turn speed proportional to delta_yaw
		local turn_speed = MENACE_TURN_RATE * abs(delta_yaw) / (1 + exp(-abs(delta_yaw)))
		if (delta_yaw > turn_speed) delta_yaw = turn_speed
		else if (delta_yaw < -turn_speed) delta_yaw = -turn_speed

		look_ang.y = current_yaw + delta_yaw

		// Set the pose parameters for pitch and yaw
		local pitch_angle = asin(look_dir.z)
		local pitch_degrees = pitch_angle * RAD2DEG
		me.SetPoseParameter(pose_body_pitch, pitch_degrees)

		local yaw_degrees = delta_yaw
		me.SetPoseParameter(pose_body_yaw, yaw_degrees)

		return look_ang
	}

	function HasVictim()
	{
		return attack_target != null && attack_target.IsValid()
	}

	function SelectVictim()
	{
		if (IsPotentiallyChaseable(attack_target) && curtime <= attack_target_focus_timer)
			return

		local new_victim = null

		local victim_range_sq = FLT_MAX
		for (local i = 1; i <= MaxClients(); i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if (player == null)
				continue
			
			if (!IsPotentiallyChaseable(player))
				continue

			if (IsPlayerStealthed(player))
				continue

			if (player.InCond(TF_COND_HALLOWEEN_GHOST_MODE))
				continue

			local range_sq = (player.GetCenter() - me.GetCenter()).LengthSqr()
			if (range_sq < victim_range_sq)
			{
				new_victim = player
				victim_range_sq = range_sq
			}
		}

		if (new_victim != null)
		{
			attack_target_focus_timer = curtime + 3.0
		}

		attack_target = new_victim
	}

	function RunAnimations()
	{
		me.StudioFrameAdvance()
		me.DispatchAnimEvents(me)
		
		// Wait for spawning animation to finish
		if (me.GetSequence() == sequence_spawn && me.GetCycle() < 1)
			return

		if (locomotion.IsAttemptingToMove())
			me.ResetSequence(sequence_run)
		else
			me.ResetSequence(sequence_idle)

        local movement_dir = locomotion.GetVelocity()
        local speed = movement_dir.Norm() / MENACE_MAX_SPEED
	}

	function PrimaryAttack()
	{
		// Check if enemy is under our crosshair
		local bosseyes = me.GetOrigin()
		local trace =
		{
			start = bosseyes,
			end = bosseyes + look_dir * MENACE_WEAPON_RANGE,
			ignore = me,
			mask = CONST.MASK_BLOCKLOS_AND_NPCS | CONTENTS_IGNORE_NODRAW_OPAQUE
		}

		//DebugDrawLine(trace.start, trace.end, 255, 255, 255, true, 1)

		if (!TraceLineEx(trace) || !("enthit" in trace) || trace.enthit == null || !trace.enthit.IsPlayer() || IsPlayerStealthed(trace.enthit))
			return false

		// Apply weapon spread
		local x = RandomFloat(-0.5, 0.5) + RandomFloat(-0.5, 0.5)
		local y = RandomFloat(-0.5, 0.5) + RandomFloat(-0.5, 0.5)
		local shoot_forward = look_dir
		local shoot_right = shoot_forward.Cross(Vector(0, 0, 1))
		local shoot_up = shoot_right.Cross(shoot_forward)
		local shoot_dir = shoot_forward + (shoot_right * MENACE_WEAPON_SPREAD * x) + (shoot_up * MENACE_WEAPON_SPREAD * y)
		shoot_dir.Norm()

		// Check if a bullet can pass through
		trace.end = m_vecEyePosition + shoot_dir * MENACE_WEAPON_RANGE
		trace.mask = CONST.MASK_SOLID | CONTENTS_HITBOX

		if (!TraceLineEx(trace))
			return false

		me.EmitSound(MENACE_WEAPON_SHOOT_SOUND)

		local muzzle_origin = weapon.GetAttachmentOrigin(attachment_muzzle)
		local muzzle_angles = weapon.GetAttachmentAngles(attachment_muzzle)

		local muzzle_forward = muzzle_angles.Forward()
		muzzle_forward.Norm()

		local tracer = SpawnEntityFromTable("info_particle_system",
		{
			effect_name = MENACE_WEAPON_TRACER_PARTICLE,
			start_active = 1,
			origin = muzzle_origin,
			angles = muzzle_forward
		})
		EntFireByHandle(tracer, "Kill", null, MENACE_WEAPON_TIME_FIRE_DELAY, null, null)

		DispatchParticleEffect(MENACE_WEAPON_MUZZLEFLASH_PARTICLE, muzzle_origin, muzzle_forward)

		local target = SpawnEntityFromTable("info_target", { origin = trace.endpos, spawnflags = 0x01 })
		NetProps.SetPropEntityArray(tracer, "m_hControlPointEnts", target, 0)
		EntFireByHandle(target, "Kill", null, MENACE_WEAPON_TIME_FIRE_DELAY, null, null)

		// Hit a player
		if ("enthit" in trace && trace.enthit != null && trace.enthit.IsPlayer())
		{
			if (!trace.enthit.InCond(TF_COND_DISGUISED))
			{
				trace.enthit.EmitSound("Flesh.BulletImpact")
			}
			
			// Passing Vector() auto-calculates damage force and position
			trace.enthit.TakeDamageCustom(me, me, null, Vector(), Vector(), MENACE_WEAPON_DAMAGE, DMG_BULLET, TF_DMG_CUSTOM_SPELL_SKELETON)
		}

		return true
	}

	function DrawDebugInfo()
	{		
		local duration = 0.03
		
		local path_len = path.len()
		if (path_len > 0)
		{
			local path_start_index = 0
			if (path_start_index == 0)
				path_start_index++

			for (local i = path_start_index; i < path_len; i++)
			{
				local p1 = path[i-1]
				local p2 = path[i]
				
				local clr
				if (p1.how <= GO_WEST || p1.how >= NUM_TRAVERSE_TYPES)
					clr = [0, 255, 0]
				else if (p1.how == GO_JUMP)
					clr = [128, 128, 255]
				else
					clr = [255, 128, 192]
				
				DebugDrawLine(p1.pos, p2.pos, clr[0], clr[1], clr[2], true, duration)
				DebugDrawText(p1.pos, i.tostring(), false, duration)
			}
		}

		foreach (name, area in path_areas)
			area.DebugDrawFilled(255, 0, 0, 30, duration, true, 0.0)
	}
	
	function Update()
	{
		curtime = Time()
		m_vecAbsOrigin = me.GetOrigin()
		m_angAbsRotation = me.GetAbsAngles()
		m_vecEyePosition = m_vecAbsOrigin + Vector(0, 0, 72)

		RunAnimations()

		if (me.GetSequence() != sequence_spawn)
		{
			SelectVictim()
			Laugh()

			if (next_primary_attack <= curtime && PrimaryAttack())
			{
				next_primary_attack = curtime + MENACE_WEAPON_TIME_FIRE_DELAY
			}
		}

		//DrawDebugInfo()
	}

	me = null	
	
	locomotion = null

	curtime = 0.0
	m_vecAbsOrigin = Vector()
	m_angAbsRotation = QAngle()
	m_vecEyePosition = Vector()

	look_dir = Vector()
	
	path = []				
	path_index = 0

	path_target_pos = Vector()		
	path_update_time_next = 0.0
	path_update_time_delay = 0.0 
	path_update_force = false	
	path_areas = {}

	sequence_spawn = -1
	sequence_idle = -1
	sequence_run = -1
	pose_body_pitch = -1
	pose_body_yaw = -1

	attachment_muzzle = 0

	next_primary_attack = 0.0
	attack_target = null
	attack_target_focus_timer = 0.0
	next_laugh_time = 0.0
}


function OnPostSpawn()
{
	self.ValidateScriptScope()
	self.GetScriptScope().nextbot <- MVM_Boss_Menace(self)
}


::IsPotentiallyChaseable <- function (victim)
{
	if (victim == null || !victim.IsValid())
		return false
	
	if (NetProps.GetPropInt(victim, "m_lifeState") != 0)
		return false
	
	local area = victim.GetLastKnownArea()
	if (area == null || area.HasAttributeTF(TF_NAV_SPAWN_ROOM_BLUE | TF_NAV_SPAWN_ROOM_RED))
		return false
	
	return true
}

::IsLineOfSightClear <- function(entity, target)
{
	local trace =
	{
		start = m_vecEyePosition,
		end = target.GetCenter(),
		ignore = entity,
		mask = CONST.MASK_BLOCKLOS_AND_NPCS | CONTENTS_IGNORE_NODRAW_OPAQUE
	}

	if (!TraceLineEx(trace))
		return false
	
	return trace.enthit == target
}

::PointWithinViewAngle <- function(pos_src, pos_target, look_dir, half_fov)
{
	local delta = pos_target - pos_src
	local cos_diff = look_dir.Dot(delta)

	if (cos_diff < 0)
		return false
	
	return (cos_diff * cos_diff > delta.LengthSqr() * half_fov * half_fov)
}

::IsPlayerStealthed <- function(player)
{
	return player.IsStealthed() &&
		!player.InCond(TF_COND_BURNING) &&
		!player.InCond(TF_COND_URINE) &&
		!player.InCond(TF_COND_STEALTHED_BLINK) &&
		!player.InCond(TF_COND_BLEEDING)
}

::AngleNormalize <- function(angle)
{
	angle %= 360.0
	if (angle > 180.0)
		angle -= 360.0
	else if (angle < -180.0)
		angle += 360.0
	return angle
}