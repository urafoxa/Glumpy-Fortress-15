IncludeScript("chatcommands_/toolgunmath.nut",this)
local modes = 
[
	"Scale Mode",
	"Color Mode",
	"       Prop Mode\n(right-click to copy)",
	"Delete Mode",
	"Enable Physics",
	"Disable Physics"
]

function addtoolgun(ply)
{
	PrecacheSound("weapons/airboat/airboat_gun_lastshot1.wav")
	PrecacheSound("weapons/airboat/airboat_gun_lastshot2.wav")
	PrecacheSound("common/wpn_moveselect.wav")
	local weapong = SpawnEntityFromTable("tf_weapon_grapplinghook",{})	
	NetProps.SetPropInt(weapong, "m_bValidatedAttachedEntity", 1) 
	NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 5)
	NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_bInitialized", 1)
	weapong.AddAttribute("override projectile type", 1, -1)
	weapong.AddAttribute("single wep deploy time decreased", 3.4e+38, -1)
	ply.Weapon_Equip(weapong)
	weapong.ValidateScriptScope()
	local weapongscope = weapong.GetScriptScope()
	weapongscope.ply <- ply
	weapongscope.hasattacked1 <- 0
	weapongscope.hasattacked2 <- 0
	weapongscope.hasswitched <- 0
	weapongscope.mode <- 0
	weapongscope.stored <- 
	{
		"solid" : 2
		"model" : "models/player.mdl"
		"cycle" : 0
		"scale" : 1
		"rendermode" : 1
		"rendercolor" : -1
		"skin" : 0
		"angles" : Vector()
		"sequence" : 0
		"pose0" : 0
		"pose1" : 0
		"pose2" : 0
		"pose3" : 0
		"pose4" : 0
		"pose5" : 0
	}
	weapongscope.scale <- 2
	weapongscope.scaleduration <- 0
	weapongscope.holstering <- 0
	weapongscope.viewmodel <- NetProps.GetPropEntity(ply,"m_hViewModel")
	AddThinkToEnt(weapong,"checkattacktoolgun")
	weapong.SetCustomViewModel("models/weapons/v_357.mdl")
	ClientPrint(ply, 3, "\x04[VSCRIPT]\x01 You have Recieved the \x04dollar store toolgun\x01! \nUse reload to switch modes. Use MOUSE2 to copy objects in prop mode. Available in Weapon Slot 6")
}

function checkattacktoolgun(){
	if(ply.GetActiveWeapon() == self){
		if(holstering == 1) {
			viewmodel.SetCycle(0)
			viewmodel.SetSequence(2)
			viewmodel.ResetSequence(2)
			viewmodel.SetPlaybackRate(4)
			holstering = 0
			local text = "\n\n\n\n\n\n\n\n\n" + modes[mode]
			ClientPrint(ply, 4, text)
		}
		if(viewmodel.GetSequence() == 2 && viewmodel.GetCycle() == 1){
			viewmodel.SetSequence(0)
		}
		ply.AddHudHideFlags(8)
		if(NetProps.GetPropInt(ply, "m_nButtons") & 1){
			if(hasattacked1 == 0){
				if(mode == 0){
					EmitSoundEx({sound_name="weapons/airboat/airboat_gun_lastshot2.wav" entity = ply sound_level = 74})
					local ent = FindPickerEntity(ply)
					EntFireByHandle(ent, "setmodelscale", scale.tostring() + " " + scaleduration.tostring(), 0, ply, ply)
				}
				if(mode == 1){
					EmitSoundEx({sound_name="weapons/airboat/airboat_gun_lastshot1.wav" entity = ply sound_level = 74})
					local ent = FindPickerEntity(ply)
					EntFireByHandle(ent, "addoutput", "rendermode 1", 0, ply, ply)
					EntFireByHandle(ent, "color", format("%i %i %i", RandomInt(0,255), RandomInt(0,255), RandomInt(0,255)), 0, ply, ply)
				}
				if(mode == 2){
					local trace =
					{
						start = ply.EyePosition(),
						end = ply.EyePosition() + (ply.EyeAngles().Forward() * 32768.0),
						ignore = ply
					};
					TraceLineEx(trace)
					if(stored.model.find(".mdl",0) != null){
						local tempent = SpawnEntityFromTable("prop_physics_override",{rendermode=stored.rendermode origin=trace.pos angles=stored.angles model=stored.model classname="prop_dynamic_gmod" spawnflags=8 solid=stored.solid skin=stored.skin modelscale = stored.scale})
						tempent.SetModelSimple(stored.model)
						tempent.SetCycle(stored.cycle)
						tempent.SetSolid(stored.solid)
						tempent.SetSequence(stored.sequence)
						NetProps.SetPropInt(tempent,"m_clrRender",stored.rendercolor)
						NetProps.SetPropFloat(tempent,"m_flPoseParameter.000",stored.pose0)
						NetProps.SetPropFloat(tempent,"m_flPoseParameter.001",stored.pose1)
						NetProps.SetPropFloat(tempent,"m_flPoseParameter.002",stored.pose2)
						NetProps.SetPropFloat(tempent,"m_flPoseParameter.003",stored.pose3)
						NetProps.SetPropFloat(tempent,"m_flPoseParameter.004",stored.pose4)
						NetProps.SetPropFloat(tempent,"m_flPoseParameter.005",stored.pose5)
						EmitSoundEx({sound_name="weapons/airboat/airboat_gun_lastshot1.wav" entity = ply sound_level = 74})
					}
				}
				if(mode == 3){
					EmitSoundEx({sound_name="weapons/airboat/airboat_gun_lastshot2.wav" entity = ply sound_level = 74})
					local ent = FindPickerEntity(ply)
					if(ent.GetClassname() == "prop_dynamic_gmod")
						ent.Kill()
				}
				if(mode == 4){
					EmitSoundEx({sound_name="weapons/airboat/airboat_gun_lastshot2.wav" entity = ply sound_level = 74})
					local ent = FindPickerEntity(ply)
					EntFireByHandle(ent, "enablemotion", "", 0, ply, ply)
				}
				if(mode == 5){
					EmitSoundEx({sound_name="weapons/airboat/airboat_gun_lastshot2.wav" entity = ply sound_level = 74})
					local ent = FindPickerEntity(ply)
					EntFireByHandle(ent, "disablemotion", "", 0, ply, ply)
				}
				hasattacked1 = 1
				viewmodel.SetCycle(0)
				viewmodel.SetSequence(1)
				viewmodel.SetPlaybackRate(1)
			}
		}	else {
			hasattacked1 = 0
			if(viewmodel.GetSequence() != 2){
				viewmodel.SetCycle(0)
				viewmodel.SetSequence(0)
				viewmodel.SetPlaybackRate(1)
			}
		}
		
		if(NetProps.GetPropInt(ply, "m_nButtons") & 2048){
			if(hasattacked2 == 0){
				if(mode == 2){
					EmitSoundEx({sound_name="weapons/airboat/airboat_gun_lastshot2.wav" entity = ply sound_level = 74})
					local ent = FindPickerEntity(ply)
					stored.model = ent.GetModelName()
					stored.solid = ent.GetSolid()
					stored.rendermode = NetProps.GetPropInt(ent,"m_nRenderMode")
					stored.rendercolor = NetProps.GetPropInt(ent,"m_clrRender")
					stored.skin = ent.GetSkin()
					stored.angles = ent.GetAbsAngles()
					stored.sequence = ent.GetSequence()
					stored.cycle = ent.GetCycle()
					stored.scale = ent.GetModelScale()
					stored.pose0 = NetProps.GetPropFloat(ent,"m_flPoseParameter.000")
					stored.pose1 = NetProps.GetPropFloat(ent,"m_flPoseParameter.001")
					stored.pose2 = NetProps.GetPropFloat(ent,"m_flPoseParameter.002")
					stored.pose3 = NetProps.GetPropFloat(ent,"m_flPoseParameter.003")
					stored.pose4 = NetProps.GetPropFloat(ent,"m_flPoseParameter.004")
					stored.pose5 = NetProps.GetPropFloat(ent,"m_flPoseParameter.005")
				}
				hasattacked2 = 1
			}
		}	else {
			hasattacked2 = 0
		}
		if(NetProps.GetPropInt(ply, "m_nButtons") & 8192){
				if(hasswitched == 0){
					mode++
					EmitSoundOnClient("Player.WeaponSelectionMoveSlot",ply)
					if(mode > 5){
						mode = 0
					}
					local text = "\n\n\n\n\n\n\n\n\n" + modes[mode]
					ClientPrint(ply, 4, text)
					hasswitched = 1
				} 
		
		} else {
			hasswitched = 0
		}
	}
	if(ply.GetActiveWeapon() != self){
		ply.RemoveHudHideFlags(8)
		holstering = 1
	}
	return 0.01
}

function MCC_toolgun(...)
{
	addtoolgun(self)
}