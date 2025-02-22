IncludeScript("chatcommands/toolgunmath.nut",this)
function addtoolgun(ply){
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
	weapong.GetScriptScope().ply <- ply
	weapong.GetScriptScope().hasattacked1 <- 0
	weapong.GetScriptScope().hasattacked2 <- 0
	weapong.GetScriptScope().hasswitched <- 0
	weapong.GetScriptScope().mode <- 0
	weapong.GetScriptScope().storedsolid <- 2
	weapong.GetScriptScope().storedmodel <- "models/player.mdl"
	weapong.GetScriptScope().storedcycle <- 0
	weapong.GetScriptScope().storedscale <- 1
	weapong.GetScriptScope().storedrendermode <- 1
	weapong.GetScriptScope().storedrendercolor <- -1
	weapong.GetScriptScope().storedskin <- 0
	weapong.GetScriptScope().storedangles <- 0
	weapong.GetScriptScope().storedsequence <- 0
	weapong.GetScriptScope().storedpose0 <- 0
	weapong.GetScriptScope().storedpose1 <- 0
	weapong.GetScriptScope().storedpose2 <- 0
	weapong.GetScriptScope().storedpose3 <- 0
	weapong.GetScriptScope().storedpose4 <- 0
	weapong.GetScriptScope().storedpose5 <- 0
	weapong.GetScriptScope().scale <- 2
	weapong.GetScriptScope().scaleduration <- 0
	weapong.GetScriptScope().holstering <- 0
	weapong.GetScriptScope().viewmodel <- NetProps.GetPropEntity(ply,"m_hViewModel")
	AddThinkToEnt(weapong,"checkattacktoolgun")
	weapong.SetCustomViewModel("models/weapons/v_357.mdl")
	ClientPrint(ply,3,"\x04[VSCRIPT]\x01 You have Recieved the \x04dollar store toolgun\x01! \nUse reload to switch modes. Use MOUSE2 to copy objects in prop mode.")
}
function checkattacktoolgun(){
	if(ply.GetActiveWeapon() == self){
		if(holstering == 1) {
			viewmodel.SetCycle(0)
			viewmodel.SetSequence(2)
			viewmodel.ResetSequence(2)
			viewmodel.SetPlaybackRate(4)
			holstering = 0
			if(mode > 5){
				mode = 0
			}
			if(mode == 0){
				ClientPrint(ply,4,"\n\n\n\n\n\n\n\n\nScale Mode")
			}
			if(mode == 1){
				ClientPrint(ply,4,"\n\n\n\n\n\n\n\n\nColor Mode")
			}
			if(mode == 2){
				ClientPrint(ply,4,"\n\n\n\n\n\n\n\n\nProp Mode")
			}
			if(mode == 3){
				ClientPrint(ply,4,"\n\n\n\n\n\n\n\n\nDelete Mode")
			}
			if(mode == 4){
				ClientPrint(ply,4,"\n\n\n\n\n\n\n\n\nEnable Physics")
			}
			if(mode == 5){
				ClientPrint(ply,4,"\n\n\n\n\n\n\n\n\nDisable Physics")
			}
		}
		if(viewmodel.GetSequence() == 2 && viewmodel.GetCycle() == 1){
			viewmodel.SetSequence(0)
		}
		ply.AddHudHideFlags(8)
		if(NetProps.GetPropInt(ply, "m_nButtons") & 1){
			if(hasattacked1 == 0){
				if(mode == 0){
					EmitSoundEx({sound_name="weapons/airboat/airboat_gun_lastshot2.wav" entity=ply sound_level=(40 + (20 * log10(2000 / 36.0))).tointeger()})
					local ent = FindPickerEntity(ply)
					EntFireByHandle(ent, "setmodelscale", scale.tostring() + " " + scaleduration.tostring(), 0, ply, ply)
				}
				if(mode == 1){
					EmitSoundEx({sound_name="weapons/airboat/airboat_gun_lastshot1.wav" entity=ply sound_level=(40 + (20 * log10(2000 / 36.0))).tointeger()})
					local ent = FindPickerEntity(ply)
					EntFireByHandle(ent, "addoutput", "rendermode 1", 0, ply, ply)
					EntFireByHandle(ent, "color", RandomInt(0,255).tostring() + " " + RandomInt(0,255).tostring() + " " + RandomInt(0,255).tostring(), 0, ply, ply)
				}
				if(mode == 2){
					local trace =
					{
						start = ply.EyePosition(),
						end = ply.EyePosition() + (ply.EyeAngles().Forward() * 32768.0),
						ignore = ply
					};
					TraceLineEx(trace)
					if(storedmodel.find(".mdl",0) != null){
						local tempent = SpawnEntityFromTable("prop_physics_override",{rendermode=storedrendermode origin=trace.pos angles=storedangles model=storedmodel classname="prop_dynamic_gmod" spawnflags=8 solid=storedsolid skin=storedskin modelscale = storedscale})
						tempent.SetModelSimple(storedmodel)
						tempent.SetCycle(storedcycle)
						tempent.SetSolid(storedsolid)
						tempent.SetSequence(storedsequence)
						NetProps.SetPropInt(tempent,"m_clrRender",storedrendercolor)
						NetProps.SetPropFloat(tempent,"m_flPoseParameter.000",storedpose0)
						NetProps.SetPropFloat(tempent,"m_flPoseParameter.001",storedpose1)
						NetProps.SetPropFloat(tempent,"m_flPoseParameter.002",storedpose2)
						NetProps.SetPropFloat(tempent,"m_flPoseParameter.003",storedpose3)
						NetProps.SetPropFloat(tempent,"m_flPoseParameter.004",storedpose4)
						NetProps.SetPropFloat(tempent,"m_flPoseParameter.005",storedpose5)
						EmitSoundEx({sound_name="weapons/airboat/airboat_gun_lastshot1.wav" entity=ply sound_level=(40 + (20 * log10(2000 / 36.0))).tointeger()})
					}
				}
				if(mode == 3){
					EmitSoundEx({sound_name="weapons/airboat/airboat_gun_lastshot2.wav" entity=ply sound_level=(40 + (20 * log10(2000 / 36.0))).tointeger()})
					local ent = FindPickerEntity(ply)
					EntFireByHandle(ent, "runscriptcode", "if(self.GetClassname()==`prop_dynamic_gmod`){self.Kill()}", 0, ply, ply)
				}
				if(mode == 4){
					EmitSoundEx({sound_name="weapons/airboat/airboat_gun_lastshot2.wav" entity=ply sound_level=(40 + (20 * log10(2000 / 36.0))).tointeger()})
					local ent = FindPickerEntity(ply)
					EntFireByHandle(ent, "enablemotion", "", 0, ply, ply)
				}
				if(mode == 5){
					EmitSoundEx({sound_name="weapons/airboat/airboat_gun_lastshot2.wav" entity=ply sound_level=(40 + (20 * log10(2000 / 36.0))).tointeger()})
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
					EmitSoundEx({sound_name="weapons/airboat/airboat_gun_lastshot2.wav" entity=ply sound_level=(40 + (20 * log10(2000 / 36.0))).tointeger()})
					local ent = FindPickerEntity(ply)
					storedmodel = ent.GetModelName()
					storedsolid = ent.GetSolid()
					storedrendermode = NetProps.GetPropInt(ent,"m_nRenderMode")
					storedrendercolor = NetProps.GetPropInt(ent,"m_clrRender")
					storedskin = ent.GetSkin()
					storedangles = ent.GetAbsAngles()
					storedsequence = ent.GetSequence()
					storedcycle = ent.GetCycle()
					storedscale = ent.GetModelScale()
					storedpose0 = NetProps.GetPropFloat(ent,"m_flPoseParameter.000")
					storedpose1 = NetProps.GetPropFloat(ent,"m_flPoseParameter.001")
					storedpose2 = NetProps.GetPropFloat(ent,"m_flPoseParameter.002")
					storedpose3 = NetProps.GetPropFloat(ent,"m_flPoseParameter.003")
					storedpose4 = NetProps.GetPropFloat(ent,"m_flPoseParameter.004")
					storedpose5 = NetProps.GetPropFloat(ent,"m_flPoseParameter.005")
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
					if(mode == 0){
						ClientPrint(ply,4,"\n\n\n\n\n\n\n\n\nScale Mode")
					}
					if(mode == 1){
						ClientPrint(ply,4,"\n\n\n\n\n\n\n\n\nColor Mode")
					}
					if(mode == 2){
						ClientPrint(ply,4,"\n\n\n\n\n\n\n\n\nProp Mode")
					}
					if(mode == 3){
						ClientPrint(ply,4,"\n\n\n\n\n\n\n\n\nDelete Mode")
					}
					if(mode == 4){
						ClientPrint(ply,4,"\n\n\n\n\n\n\n\n\nEnable Physics")
					}
					if(mode == 5){
						ClientPrint(ply,4,"\n\n\n\n\n\n\n\n\nDisable Physics")
					}
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