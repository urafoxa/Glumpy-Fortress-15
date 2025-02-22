ClearGameEventCallbacks();
IncludeScript("c_turret.nut");
__CollectGameEventCallbacks(this);

ForceEscortPushLogic(2);

function Think()
{
    TurretsThink();
}
AddThinkToEnt(self, "Think");