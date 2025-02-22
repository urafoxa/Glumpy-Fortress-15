//thanks for the help :)
//if you see this, add me on steam, because i need help with VSCRIPT

GameModeUsesCurrency();
GameModeUsesUpgrades();
ForceEnableUpgrades(2);
PrecacheScriptSound("MVM.MoneyPickup");

local g_pay_for_kill = 100
local g_pay_for_assist = 50
local g_lose_on_suicide = 100
local g_pay_botler = 250

local EventsID = UniqueString()
getroottable()[EventsID] <-
{
    OnGameEvent_scorestats_accumulated_update = function(_) { delete getroottable()[EventsID] }

	OnGameEvent_player_death = function(params)
	{
		local attacker = GetPlayerFromUserID(params.attacker)
		local assister  = GetPlayerFromUserID(params.assister)
		local victim = GetPlayerFromUserID(params.userid)

		if (attacker != null)
		{
			if(attacker != victim)
			{
				EmitSoundOnClient("MVM.MoneyPickup", attacker)
				attacker.AddCurrency(g_pay_for_kill)
			}
			else
			{
				attacker.RemoveCurrency(g_lose_on_suicide)
			}
			if (assister != null)
			{
				if(assister.GetPlayerClass() == 5)
				{
					assister.AddCurrency(g_pay_for_kill)
				}
				else
				{
					assister.AddCurrency(g_pay_for_assist)
				}
			}
		}
	}
}
local EventsTable = getroottable()[EventsID]
__CollectGameEventCallbacks(EventsTable)
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)

::MVMALL_PAYPLAYER <- function()
{
    self.AddCurrency(g_pay_botler)
	EmitSoundOnClient("MVM.MoneyPickup", self)
	EntFireByHandle(self, "SpeakResponseConcept", "TLK_MVM_MONEY_PICKUP IsMvMDefender:1 randomnum:5", 0.5, null, null)
	
}