ClearGameEventCallbacks();
IncludeScript("embargo/util.nut");
IncludeScript("embargo/players.nut");
IncludeScript("embargo/sound.nut");
IncludeScript("embargo/botlers.nut");
IncludeScript("mvm_allmaps.nut");
IncludeScript("embargo_vehicle_ev.nut");
__CollectGameEventCallbacks(this);

ForceEscortPushLogic(2);

function Think()
{
    ThinkBotlers();
}
AddThinkToEnt(self, "Think");