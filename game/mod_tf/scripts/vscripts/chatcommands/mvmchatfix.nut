function mvmchatfix(playerentity,plyname,data) {
	//feel free to use this in your own projects.
	if (IsMannVsMachineMode()) {
	local clienttarget = null;
	while ( clienttarget = Entities.FindByClassname(clienttarget, "player") ) {
	if (NetProps.GetPropInt(playerentity,"m_iTeamNum") == 2) {
	{
	if (NetProps.GetPropInt(clienttarget,"m_iTeamNum") == 3 || NetProps.GetPropInt(clienttarget,"m_iTeamNum") == 0 || NetProps.GetPropInt(clienttarget,"m_iTeamNum") == 1) {
	ClientPrint(clienttarget, 3, "ff3d3d" + plyname + "fbeccb : " + data.text)
			}
		}
	}
	if (NetProps.GetPropInt(playerentity,"m_iTeamNum") == 3 ) {
	{
	if (NetProps.GetPropInt(clienttarget,"m_iTeamNum") == 2 || NetProps.GetPropInt(clienttarget,"m_iTeamNum") == 0 || NetProps.GetPropInt(clienttarget,"m_iTeamNum") == 1) {
	ClientPrint(clienttarget, 3, "9bcdff" + plyname + "fbeccb : " + data.text)
			}
		}
	}
	if (NetProps.GetPropInt(playerentity,"m_iTeamNum") == 1) {
	{
	if (NetProps.GetPropInt(clienttarget,"m_iTeamNum") == 3 || NetProps.GetPropInt(clienttarget,"m_iTeamNum") == 0 || NetProps.GetPropInt(clienttarget,"m_iTeamNum") == 2) {
	ClientPrint(clienttarget, 3, "fbeccb*SPEC* cdcdcd" + plyname + "fbeccb : " + data.text)
			}
		}
	}
	if (NetProps.GetPropInt(playerentity,"m_iTeamNum") == 0) {
	{
	if (NetProps.GetPropInt(clienttarget,"m_iTeamNum") != 0) {
	ClientPrint(clienttarget, 3, "fbeccb*DEAD* 000000" + plyname + "fbeccb : " + data.text)
					}
				}
			}
		}
	}
}