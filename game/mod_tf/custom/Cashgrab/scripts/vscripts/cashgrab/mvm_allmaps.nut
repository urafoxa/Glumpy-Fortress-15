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
local finalecountdown = false

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
				CG_Spawnmoney(victim)
				attacker.AcceptInput("SpeakResponseConcept","TLK_MVM_MONEY_PICKUP IsMvMDefender:1 randomnum:5",null,null)
			}
			else
			{
				if (victim.GetCurrency() < 0)
				{
					CG_Spawnmoney(victim)
					attacker.RemoveCurrency(g_lose_on_suicide)
					CG_RemovePoints(attacker.GetTeam() == Constants.ETFTeam.TF_TEAM_RED ? 2 : 3, g_lose_on_suicide)
				}
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

::CG_FinaleSetter <- function(victim)
{
	if (finalecountdown)
	{
	
	}
}

::CG_Spawnmoney <- function(victim)
{
	local moneypile_med = SpawnEntityFromTable("item_currencypack_medium", {			
		spawnflags = (1 << 30),
		"OnPlayerTouch": "!self,Kill,,-1,-1",
		"OnPlayerTouch": "!activator,CallScriptfunction,MVMALL_PAYPLAYER,-1,-1",
	});
	moneypile_med.SetMoveType(5, 1);
	local forward = victim.GetForwardVector();
	moneypile_med.SetAbsOrigin(victim.GetCenter() + forward * 20);
	moneypile_med.SetVelocity(Vector(RandomFloat(-50, 50), RandomFloat(-50, 50), 250) + forward * 60);
	EntFireByHandle(moneypile_med, "Kill", "", 15, null, null);
}

::MVMALL_PAYPLAYER <- function()
{
	CG_ScorePoints(self.GetTeam() == Constants.ETFTeam.TF_TEAM_RED ? 2 : 3, g_pay_for_kill);
	self.AddCurrency(g_pay_for_kill)
}

local logic_cash = Entities.FindByClassname(null, "tf_logic_player_destruction") // Or Robot Destruction

::CG_ScorePoints <- function(team, killscore)
{
    //Score Points by using a dummy flag and send it -Burguers
	printl("Added: " + killscore)
	FlagDummy <- SpawnEntityFromTable("item_teamflag", {
		TeamNum = team,
		PointValue = killscore,
		GameType = 5,
		trail_effect = 0,
	})
	NetProps.SetPropBool(FlagDummy, "m_bForcePurgeFixedupStrings", true)
	FlagDummy.AcceptInput("RoundActivate", "!self", null, null)
	FlagDummy.Kill()
}

::CG_RemovePoints <- function(team, killscore)
{
	local currentScore = NetProps.GetPropInt(logic_cash ,team == 2 ? "m_nRedScore" : "m_nBlueScore");
	local newScore = currentScore - killscore;
	printl("Current Score: " + currentScore)

	RemoverFlag <- SpawnEntityFromTable("item_teamflag", {
		TeamNum = team,
		GameType = 5,
		trail_effect = 0,
	})
	NetProps.SetPropBool(RemoverFlag, "m_bForcePurgeFixedupStrings", true)
	//Sarexicus magic removal| Sets the points to 0 caused by an overflow, then deliver a new ammount by calling the scoring above
    if (currentScore != 0)
    {
        RemoverFlag.KeyValueFromString("PointValue", "4294967295")
        RemoverFlag.AcceptInput("RoundActivate", "!self", null, null)
        RemoverFlag.Kill()
        if (newScore > 0)
            CG_ScorePoints(team, newScore)
    }
}