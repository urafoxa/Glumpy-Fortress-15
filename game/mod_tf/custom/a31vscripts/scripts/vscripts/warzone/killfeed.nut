
local table_killfeed = {
userid = 0
customkill = Constants.ETFDmgCustom.TF_DMG_CUSTOM_SPELL_SKELETON
death_flags = 0
weapon = "shark"
}

function KillFeed()
{
	local numID = NetProps.GetPropIntArray(Entities.FindByClassname(null, "tf_player_manager"), "m_iUserID", activator.entindex())
	table_killfeed.userid = numID
    SendGlobalGameEvent("player_death", table_killfeed)
}