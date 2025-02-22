function SetDestroyCallback(entity, callback)
{
	entity.ValidateScriptScope()
	local scope = entity.GetScriptScope()
	scope.setdelegate({}.setdelegate({
			parent   = scope.getdelegate()
			id       = entity.GetScriptId()
			index    = entity.entindex()
			callback = callback
			_get = function(k)
			{
				return parent[k]
			}
			_delslot = function(k)
			{
				if (k == id)
				{
					entity = EntIndexToHScript(index)
					local scope = entity.GetScriptScope()
					scope.self <- entity
					callback.pcall(scope)
				}
				delete parent[k]
			}
		})
	)
}

if(!("ParticleSpawner" in this))
	ParticleSpawner <- Entities.CreateByClassname("trigger_particle")
NetProps.SetPropInt(ParticleSpawner, "m_spawnflags", 64)

function SpawnParticle(entity, name, attach_name, attach_type)
{
	if(!CBaseEntity.IsValid.call(ParticleSpawner))
	{
		ParticleSpawner = Entities.CreateByClassname("trigger_particle")
		NetProps.SetPropInt(ParticleSpawner, "m_spawnflags", 64)
	}
	NetProps.SetPropString(ParticleSpawner, "m_iszParticleName", name)
	NetProps.SetPropString(ParticleSpawner, "m_iszAttachmentName", attach_name)
	NetProps.SetPropInt(ParticleSpawner, "m_nAttachType", attach_type)
	ParticleSpawner.AcceptInput("StartTouch", "", entity, entity)
}


function RemoveCustomAttributes(player)
{
	for(local i = 0;i < MCCL_attributes.len();i++)
	{
		player.RemoveCustomAttribute(MCCL_attributes[i])
	}
}