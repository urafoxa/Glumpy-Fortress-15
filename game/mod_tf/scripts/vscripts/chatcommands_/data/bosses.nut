MCCB_custom <-
{
	/*
	"mosquito scout" :
	{
		"class" : "scout" // The class via its name.
		"health" : 100 // The desired max health
		"scale" : 0.5 // The desired size
		"model" : "models/player/scout.mdl" // The desired player model to use.
		"weapons" :
		[
			// the following weapons follow the same format for custom weapons
			{
				"item_class" : "tf_weapon_scattergun"
				"item_index" : 13
				"attributes" :
				{
					"damage bonus" : 0.1
					"bleeding duration" : 8 
				}
			}
			
			{
				"item_class" : "tf_weapon_pistol_scout"
				"item_index" : 23
				"attributes" :
				{
					"damage bonus" : 0.1
					"bleeding duration" : 8 
				}
			}
			
			{
				"item_class" : "tf_weapon_bat"
				"item_index" : 0
				"attributes" :
				{
					"damage bonus" : 0.1
					"bleeding duration" : 8 
				}
			}
			
			{
				"item_class" : "tf_weapon_grapplinghook"
				"item_index" : 1152
			}
		]
		"attributes" : // the base attributes the player has
		{
			"head scale" : 2
			"hand scale" : 0.5
			"voice pitch scale" : 2
			"gesture speed increase" : 2
			"air dash count" : 1000000
			"ammo regen" : 1
		}
	}
	*/
	
	"giant deflector heavy" :
	{
		"class" : "heavy"
		"health" : 5000
		"scale" : Convars.GetFloat("tf_mvm_miniboss_scale")
		"model" : "models/bots/heavy_boss/bot_heavy_boss.mdl"
		"weapons" :
		[
			{
				"item_class" : "tf_weapon_minigun"
				"item_index" : 850
				"attributes" :
				{
					"damage bonus" : 1.5
					"attack projectiles" : 1
				}
			}
		]
		"attributes" : 
		{
			"move speed bonus" : 0.5
			"damage force reduction" : 0.3
			"airblast vulnerability multiplier" : 0.3
			"override footstep sound set" : 2
		}
	}
	
	"sir nukesalot" :
	{
		"class" : "demoman"
		"health" : 50000
		"scale" : 1.9
		"model" : "models/bots/demo_boss/bot_demo_boss.mdl"
		"weapons" :
		[
			{
				"item_class" : "tf_weapon_cannon"
				"item_index" : 996
				"attributes" : 
				{
					"grenade launcher mortar mode" : 0
					"faster reload rate" : 1.8
					"fire rate bonus" : 2
					"clip size penalty" : 0.5
					"Projectile speed increased" : 0.8
					"projectile spread angle penalty" : 5
					"damage bonus" : 7
					"damage causes airblast" : 1
					"blast radius increased" : 1.2
					"use large smoke explosion" : 1
				}
			}
		]
		"attributes" : 
		{
			"move speed bonus" : 0.35
			"damage force reduction" : 0.4
			"airblast vulnerability multiplier" : 0.4
			"override footstep sound set" : 4
		}
	}
	
	"samurai demo" :
	{
		"class" : "demoman"
		"health" : 650
		"scale" : 1.3
		"model" : "models/bots/demo/bot_demo.mdl"
		"weapons" :
		[
			{
				"item_class" : "tf_weapon_katana"
				"item_index" : 357
				"damage bonus" : 1.5
			}
		]
		"attributes" : 
		{
			"charge time increased" : 2
			"charge recharge rate increased" : 7
			"increased jump height" : 2.3
			"bot custom jump particle" : 1
		}
	}
	
	"super scout" :
	{
		"class" : "scout"
		"health" : 1200
		"scale" : Convars.GetFloat("tf_mvm_miniboss_scale")
		"model" : "models/bots/scout_boss/bot_scout_boss.mdl"
		"weapons" :
		[
			{
				"item_class" : "tf_weapon_bat_fish"
				"item_index" : 221
			}
		]
		"attributes" : 
		{
			"move speed bonus" : 2
			"damage force reduction" : 0.7
			"airblast vulnerability multiplier" : 0.7
			"override footstep sound set" : 5
		}
	}
}