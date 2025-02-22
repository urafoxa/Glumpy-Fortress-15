//feel free to use this in your own projects.
function mvmchatfix(playerentity, data) 
{
	if (IsMannVsMachineMode()) 
	{
		local chat_colors = ["fbeccb*DEAD* 000000", "fbeccb*SPEC* cdcdcd", "ff3d3d", "9bcdff"]
		local plyname = NetProps.GetPropString(playerentity, "m_szNetname")
		local plyteam = NetProps.GetPropInt(playerentity, "m_iTeamNum")
		local clienttarget = null;
		for(local i = 1; i <= MaxClients(); i++)
		{
			local clienttarget = PlayerInstanceFromIndex(i);
			if(clienttarget == null) continue;
			if(clienttarget == playerentity) continue;
			if(NetProps.GetPropInt(clienttarget, "m_iTeamNum") != plyteam) 
			{
				ClientPrint(clienttarget, 3, chat_colors[plyteam] + plyname + "fbeccb : " + data.text)
			}
		}
	}
}