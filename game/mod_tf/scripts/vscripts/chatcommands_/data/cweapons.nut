MCCW_custom <-
{
	"deflector" :
	{
		"item_class" : "tf_weapon_minigun"
		"item_index" : 850
		"attributes" :
		{
			"damage bonus" : 1.5
			"attack projectiles" : 1
		}
	}
	
	"valve rocket launcher" :
	{
		"item_text" : "Use the \"nerfed valve rocket launcher\" to avoid crashes from the upgrade station."
		"item_class" : "tf_weapon_rocketlauncher"
		"item_index" : 205
		"attributes" :
		{
			"elevate quality" : 8
			"damage bonus" : 10100
			"clip size bonus" : 1100
			"fire rate bonus" : 0.25
			"heal on hit for rapidfire" : 250
			"critboost on kill" : 10
			"Projectile speed increased" : 1.5
			"move speed bonus" : 2
			"attach particle effect" : 2
		}
	}
	
	"nerfed valve rocket launcher" :
	{
		"item_class" : "tf_weapon_rocketlauncher"
		"item_index" : 205
		"attributes" :
		{
			"elevate quality" : 8
			"damage bonus" : 100
			"clip size bonus" : 91
			"fire rate bonus" : 0.25
			"heal on hit for rapidfire" : 250
			"critboost on kill" : 10
			"Projectile speed increased" : 1.5
			"move speed bonus" : 2
			"attach particle effect" : 2
		}
	}
	
	"batsaber" :
	{
		"item_class" : "tf_weapon_bat"
		"item_index" : 30667
		"attributes" :
		{
			"damage bonus" : 1000
		}
	}
	
	"australium blackbox" :
	{
		"item_class" : "tf_weapon_rocketlauncher"
		"item_index" : 228
		"attributes" :
		{
			"item style override" : 1
			"is australium item" : 1
			"loot rarity" : 1
		}
	}
	
	"broken sapper" :
	{
		"item_class" : "tf_weapon_sapper"
		"item_index" : 735
		"attributes" :
		{
			"sapper damage bonus" : 0.0
			"sapper damage leaches health" : 100
			"sapper degenerates buildings" : -1
		}
		"buildables" :
		{
			"dispenser" : 0
			"teleporter" : 0
			"sentry" : 0
			"sapper" : 1
		}
	}
	
}