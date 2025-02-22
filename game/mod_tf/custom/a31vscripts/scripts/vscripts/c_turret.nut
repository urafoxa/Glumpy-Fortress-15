

function Precache()
{
	target <- null;
	team <- null;
	

}

function TurretsThink()
{
	local entity = null
	local possible_targets = [tf_zombie, player]
	while (entity = Entities.FindByClassname(entity, possible_targets))
	{
		if(entity.IsPlayer())
		{
			if (entity.IsPlayer())
			{
				local bone = entity.LookupBone("bip_spine_2")
				if (bone != 0)
				{
					look_ang = LookAt(entity.GetBoneOrigin(bone))
				}
			}
		}
	}

}

function LookAt(pos)
    {
	
		local pose_body_pitch = self.LookupPoseParameter("aim_pitch")
		local pose_body_yaw = self.LookupPoseParameter("aim_yaw")
		
		local look_dir = pos 
        look_dir.Norm()

        local look_angle = atan2(look_dir.y, look_dir.x)
        local look_ang = QAngle(0, look_angle * RAD2DEG, 0)

        // Smoothly turn towards the target position
        local current_yaw = m_angAbsRotation.y
        local target_yaw = look_ang.y
        local delta_yaw = target_yaw - current_yaw

        delta_yaw = NormalizeAngle(delta_yaw)

        // Turn smoothly towards the target yaw
        local turn_speed = 5 / (1 + exp(-abs(delta_yaw)))
        if (delta_yaw > turn_speed) delta_yaw = turn_speed
        else if (delta_yaw < -turn_speed) delta_yaw = -turn_speed

        look_ang.y = current_yaw + delta_yaw

        // Set the pose parameters for pitch and yaw
        local pitch_angle = asin(look_dir.z)
        local pitch_degrees = pitch_angle * RAD2DEG
        self.SetPoseParameter(pose_body_pitch, pitch_degrees)

        local yaw_degrees = delta_yaw
        self.SetPoseParameter(pose_body_yaw, yaw_degrees)

        return look_ang
    }
	