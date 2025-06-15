::SpawnDroppedWeapon <- function(index, modelname, origin)
{
    local weapon = Entities.CreateByClassname("tf_dropped_weapon");
    NetProps.SetPropInt(weapon, "m_Item.m_iItemDefinitionIndex", index);
    NetProps.SetPropInt(weapon, "m_Item.m_iEntityLevel", 5);
    NetProps.SetPropInt(weapon, "m_Item.m_iEntityQuality", 6);
    NetProps.SetPropInt(weapon, "m_Item.m_bInitialized", 1);
    weapon.SetModelSimple(modelname);
    weapon.SetOrigin(origin);

    weapon.DispatchSpawn();
}