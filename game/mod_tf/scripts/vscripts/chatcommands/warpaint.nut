// Made by Mince (STEAM_0:0:41588292)

::ROOT <- getroottable();
if (!("ConstantNamingConvention" in ROOT))
{
	foreach(a, b in Constants)
		foreach(k, v in b)
			ROOT[k] <- v != null ? v : 0;
}

foreach(k, v in ::NetProps.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NetProps[k].bindenv(::NetProps);

foreach(k, v in ::Entities.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::Entities[k].bindenv(::Entities);
	
foreach(k, v in ::EntityOutputs.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::EntityOutputs[k].bindenv(::EntityOutputs);

foreach(k, v in ::NavMesh.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NavMesh[k].bindenv(::NavMesh);
	
// Weapon slots
const SLOT_PRIMARY   = 0;
const SLOT_SECONDARY = 1;
const SLOT_MELEE     = 2;
const SLOT_UTILITY   = 3;
const SLOT_BUILDING  = 4;
const SLOT_PDA       = 5;
const SLOT_PDA2      = 6;
const SLOT_COUNT     = 7;

const HELP_STRING = @"
========== DOCUMENTATION ==========
	-- COMMANDS -- 
		!give (target) (weapon)
		!g
			- Give a target a weapon
		!giveme (weapon)
		!gimme
		!gm
			- Give yourself a weapon
		!paint (paint)
		!p
			- Set your weapon paintkit
		!wear (wear)
		!w
			- Set your weapon wear
		!effect (effect)
		!e
			- Set your weapon effect
		!killstreak
		!ks
			- Set your weapon killstreak
		!loadoutpaint [paint]
		!lp
			- Set your loadout paintkit, or toggle it off with no arguments
		!next
		!n
			- Receive the next warpaint weapon for this slot
		!prev
		!pr
			- Receive the previous warpaint weapon for this slot
		!randomseed
		!rs
			- Set a random painkit seed for your weapon
		!seed (seed)
		!s
			- Set a paintkit seed for your weapon
		!thirdperson
		!tp
			- Toggle thirdperson
		!switchteam
		!switch
		!sw
			- Switch teams
			
	-- VALUES --
		WEARS
			factory new:    0.00,
			minimal wear:   0.25,
			field tested:   0.50,
			well worn:      0.75,
			battle scarred: 1.00,
			
		EFFECTS
			reset:       0,
			hot:         701,
			isotope:     702,
			cool:        703,
			energy orb:  704,
			
		KILLSTREAKS
			reset:              0,
			team shine:         1,
			deadly daffodil:    2,
			manndarin:          3,
			mean green:         4,
			agonizing emerald:  5,
			villainous violet:  6,
			hot rod:            7,

		
	-- KEYBINDS --
		
	-- EXAMPLES --
		!give @bots shotgun
		!give @aim panic attack
		!g @me winger
		
		!giveme tf_weapon_rocketlauncher
		!gimme rocket launcher
		!gm rocket
		
		!paint night owl
		!p owl
		!p 114
		
		!wear battle scarred
		!w battle
		!w 1
		
===================================
";

::Warpaints <- {
	INT_MAX32 = 2147483647,
	MaxPlayers  = MaxClients().tointeger(),
	STRING_NETPROP_ITEMDEF = "m_AttributeManager.m_Item.m_iItemDefinitionIndex",
	
	WHITESPACE  = {[9]=null, [10]=null, [11]=null, [12]=null, [13]=null, [32]=null},
	PUNCTUATION = {[33]=null, [44]=null, [46]=null, [63]=null}, // . , ? !
	
	TARGETFLAGS_NOSELF     = 1 << 0,
	TARGETFLAGS_NOMULTIPLE = 1 << 1,
	TARGETFLAGS_NOBOTS     = 1 << 2,
	
	DEFAULT_PLAYER_SCOPE = {
		buttons_last = 0,
		paint        = null,
		wear         = null,
		effect       = null,
		killstreak   = null,
		loadoutpaint = null,
		seed         = null,
		thirdperson  = false,
		hud          = true,
	},
	
	WEARABLE_WEAPONS = {
		[133] = SLOT_SECONDARY, // Gunboats
		[444] = SLOT_SECONDARY, // Mantreads
		[405] = SLOT_PRIMARY, // Booties
		[608] = SLOT_PRIMARY, // Bootlegger
		[131] = SLOT_SECONDARY, // Chargin' Targe
		[406] = SLOT_SECONDARY, // Splendid Screen
		[1099] = SLOT_SECONDARY, // Tide Turner
		[1144] = SLOT_SECONDARY, // Festive Targe
		[57] = SLOT_SECONDARY, // Razorback
		[231] = SLOT_SECONDARY, // Danger Shield
		[642] = SLOT_SECONDARY, // Cozy Camper
	},
	
	WARPAINT_WEAPONS = {
		[TF_CLASS_SCOUT] = [
			{slot=SLOT_PRIMARY, name="scattergun", cls="tf_weapon_scattergun", id=200},
			{slot=SLOT_PRIMARY, name="the shortstop", cls="tf_weapon_handgun_scout_primary", id=220},
			{slot=SLOT_PRIMARY, name="the soda popper", cls="tf_weapon_soda_popper", id=448},
			{slot=SLOT_SECONDARY, name="pistol", cls="tf_weapon_pistol_scout", id=209},
			{slot=SLOT_SECONDARY, name="the winger", cls="tf_weapon_handgun_scout_secondary", id=449},
			{slot=SLOT_MELEE, name="the holy mackerel", cls="tf_weapon_bat_fish", id=221},
		],
		[TF_CLASS_SOLDIER] = [
			{slot=SLOT_PRIMARY, name="rocket launcher", cls="tf_weapon_rocketlauncher", id=205},
			{slot=SLOT_PRIMARY, name="the black box", cls="tf_weapon_rocketlauncher", id=228},
			{slot=SLOT_PRIMARY, name="the air strike", cls="tf_weapon_rocketlauncher_airstrike", id=1104},
			{slot=SLOT_SECONDARY, name="shotgun", cls="tf_weapon_shotgun_soldier", id=199},
			{slot=SLOT_SECONDARY, name="the panic attack", cls="tf_weapon_shotgun_soldier", id=1153},
			{slot=SLOT_SECONDARY, name="the reserve shooter", cls="tf_weapon_shotgun_soldier", id=415},
			{slot=SLOT_MELEE, name="the disciplinary action", cls="tf_weapon_shovel", id=447},
		],
		[TF_CLASS_PYRO] = [
			{slot=SLOT_PRIMARY, name="flame thrower", cls="tf_weapon_flamethrower", id=208},
			{slot=SLOT_PRIMARY, name="the degreaser", cls="tf_weapon_flamethrower", id=215},
			{slot=SLOT_PRIMARY, name="the dragon's fury", cls="tf_weapon_rocketlauncher_fireball", id=1178},
			{slot=SLOT_SECONDARY, name="shotgun", cls="tf_weapon_shotgun_pyro", id=199},
			{slot=SLOT_SECONDARY, name="the panic attack", cls="tf_weapon_shotgun_pyro", id=1153},
			{slot=SLOT_SECONDARY, name="the reserve shooter", cls="tf_weapon_shotgun_pyro", id=415},
			{slot=SLOT_SECONDARY, name="the detonator", cls="tf_weapon_flaregun", id=351},
			{slot=SLOT_SECONDARY, name="the scorch shot", cls="tf_weapon_flaregun", id=740},
			{slot=SLOT_MELEE, name="the powerjack", cls="tf_weapon_fireaxe", id=214},
			{slot=SLOT_MELEE, name="the back scratcher", cls="tf_weapon_fireaxe", id=326},
		],
		[TF_CLASS_DEMOMAN] = [
			{slot=SLOT_PRIMARY, name="grenade launcher", cls="tf_weapon_grenadelauncher", id=206},
			{slot=SLOT_PRIMARY, name="the loch-n-load", cls="tf_weapon_grenadelauncher", id=308},
			{slot=SLOT_PRIMARY, name="the loose cannon", cls="tf_weapon_cannon", id=996},
			{slot=SLOT_PRIMARY, name="the iron bomber", cls="tf_weapon_grenadelauncher", id=1151},
			{slot=SLOT_SECONDARY, name="stickybomb launcher", cls="tf_weapon_pipebomblauncher", id=207},
			{slot=SLOT_MELEE, name="the scotsman's skullcutter", cls="tf_weapon_sword", id=172},
			{slot=SLOT_MELEE, name="the claidheamohmor", cls="tf_weapon_sword", id=327},
			{slot=SLOT_MELEE, name="the persian persuader", cls="tf_weapon_sword", id=404},
		],
		[TF_CLASS_HEAVYWEAPONS] = [
			{slot=SLOT_PRIMARY, name="minigun", cls="tf_weapon_minigun", id=202},
			{slot=SLOT_PRIMARY, name="the brass breast", cls="tf_weapon_minigun", id=312},
			{slot=SLOT_PRIMARY, name="tomislav", cls="tf_weapon_minigun", id=424},
			{slot=SLOT_SECONDARY, name="shotgun", cls="tf_weapon_shotgun_hwg", id=199},
			{slot=SLOT_SECONDARY, name="the panic attack", cls="tf_weapon_shotgun_hwg", id=1153},
			{slot=SLOT_SECONDARY, name="the family business", cls="tf_weapon_shotgun_hwg", id=425},
		],
		[TF_CLASS_ENGINEER] = [
			{slot=SLOT_PRIMARY, name="shotgun", cls="tf_weapon_shotgun_primary", id=199},
			{slot=SLOT_PRIMARY, name="the panic attack", cls="tf_weapon_shotgun_primary", id=1153},
			{slot=SLOT_PRIMARY, name="the rescue ranger", cls="tf_weapon_shotgun_building_rescue", id=997},
			{slot=SLOT_SECONDARY, name="pistol", cls="tf_weapon_pistol", id=209},
			{slot=SLOT_MELEE, name="wrench", cls="tf_weapon_wrench", id=197},
			{slot=SLOT_MELEE, name="the jag", cls="tf_weapon_wrench", id=329},
		],
		[TF_CLASS_MEDIC] = [
			{slot=SLOT_PRIMARY, name="crusader's crossbow", cls="tf_weapon_crossbow", id=305},
			{slot=SLOT_SECONDARY, name="medi gun", cls="tf_weapon_medigun", id=211},
			{slot=SLOT_MELEE, name="the ubersaw", cls="tf_weapon_bonesaw", id=37},
			{slot=SLOT_MELEE, name="the amputator", cls="tf_weapon_bonesaw", id=304},
		],
		[TF_CLASS_SNIPER] = [
			{slot=SLOT_PRIMARY, name="sniper rifle", cls="tf_weapon_sniperrifle", id=201},
			{slot=SLOT_PRIMARY, name="the bazaar bargain", cls="tf_weapon_sniperrifle_decap", id=402},
			{slot=SLOT_SECONDARY, name="smg", cls="tf_weapon_smg", id=203},
			{slot=SLOT_MELEE, name="shahanshah", cls="tf_weapon_club", id=401},
		],
		[TF_CLASS_SPY] = [
			{slot=SLOT_PRIMARY, name="revolver", cls="tf_weapon_revolver", id=210},
			{slot=SLOT_MELEE, name="knife", cls="tf_weapon_knife", id=194},
		],
	},
	
	PAINTS = {
		"wrapped reviver": 102,"carpet bomber": 104,"woodland warrior": 106,"forest fire": 109,
		"woodsy widowmaker": 113,"night owl": 114,"plaid potshotter": 122,"autumn": 160,
		"civil servant": 139,"civic duty": 144,"bovine blazemaker": 130,"dead reckoner": 151,
		"masked mender": 105,"backwoods boomstick": 112,"iron wood": 120,"macabre web": 163,
		"smalltown bringdown": 143,"nutcracker": 161,"park pigmented": 301,"yeti coated": 300,
		"sax waxed": 304,"macaw masked": 303,"croc dusted": 308,"pina polished": 309,
		"mannana peeled": 302,"anodized aloha": 305,"bamboo brushed": 306,"tiger buffed": 307,
		"leopard printed": 310,"fire glazed": 205,"bonk varnished": 207,"freedom wrapped": 210,
		"dream piped": 212,"bank rolled": 202,"kill covered": 204,"pizza polished": 206,
		"clover camo'd": 209,"bloom buffed": 200,"quack canvassed": 201,"merc stained": 203,
		"star crossed": 208,"cardboard boxed": 211,"miami element": 213,"mosaic": 228,
		"jazzy": 230,"neo tokyo": 214,"cosmic calamity": 225,"hana": 223,"uranium": 218,
		"hazard warning": 226,"damascus & mahogany": 234,"dovetailed": 224,"alien tech": 232,
		"cabin fevered": 220,"polar surprise": 221,"bomber soul": 217,"geometrical teams": 215,
		"dragon slayer": 390,"smissmas sweater": 391,"electroshocked": 241,"ghost town": 242,
		"tumor toasted": 243,"skull study": 235,"spectral shimmered": 237,"calavera canvas": 244,
		"haunted ghosts": 236,"spirit of halloween": 238,"horror holiday": 239,"totally boned": 240,
		"winterland wrapped": 254,"smissmas camo": 250,"smissmas village": 247,"frost ornamented": 246,
		"snow covered": 245,"sleighin' style": 251,"alpine": 252,"igloo": 248,"seriously snowed": 249,
		"gift wrapped": 253,"spectrum splattered": 257,"helldriver": 255,"pumpkin pied": 259,
		"mummified mimic": 268,"sweet toothed": 260,"crawlspace critters": 261,"raving dead": 264,
		"spider's cluster": 266,"organ-ically hellraised": 256,"candy coated": 258,"portal plastered": 262,
		"death deluxe": 263,"eyestalker": 265,"gourdy green": 267,"spider season": 269,
		"starlight serenity": 280,"frosty delivery": 281,"saccharine striped": 271,"cookie fortress": 283,
		"frozen aurora": 279,"elfin enamel": 272,"smissmas spycrabs": 278,"snowflake swirled": 277,
		"gingerbread winner": 270,"peppermint swirl": 273,"gifting mann's wrapping paper": 276,
		"glacial glazed": 282,"snow globalization": 275,"misfortunate": 287,"broken bones": 291,
		"party phantoms": 294,"swashbuckled": 285,"neon-ween": 289,"polter-guised": 295,"necromanced": 297,
		"sarsaparilla sprayed": 284,"skull cracked": 286,"simple spirits": 290,"potent poison": 292,
		"searing souls": 293,"kiln & conquer": 296,"sacred slayer": 403,"ghoul blaster": 400,
		"bonzo gnawed": 405,"metalized soul": 404,"pumpkin plastered": 409,"chilly autumn": 410,
		"cream corned": 401,"sunriser": 402,"health and hell": 406,"health and hell (green)": 407,
		"hypergon": 408,"sky stallion": 413,"business class": 415,"deadly dragon": 416,"steel brushed": 411,
		"warborn": 418,"mechanized monster": 420,"secretly serviced": 412,"bomb carrier": 414,
		"team serviced": 417,"pacific peacemaker": 419,"stardust": 421, "team detail": 422,"gobi glazed": 423,
		"sleek greek": 424,"graphite gripped": 425,"stealth specialist": 426,"piranha mania": 427,
		"team charged": 428,"brawler's iron": 429,"necropolish": 430, "team blackout": 431,"broken record": 432,
	},
	
	WEARS = {
		"factory new":    0.00,
		"minimal wear":   0.25,
		"field tested":   0.50,
		"well worn":      0.75,
		"battle scarred": 1.00,
	},
	
	EFFECTS = {
		"reset":       0,
		"hot":         701,
		"isotope":     702,
		"cool":        703,
		"energy orb":  704,
	},
	
	KILLSTREAKS = {
		"reset":              0,
		"team shine":         1,
		"deadly daffodil":    2,
		"manndarin":          3,
		"mean green":         4,
		"agonizing emerald":  5,
		"villainous violet":  6,
		"hot rod":            7,
	},

	function PrintToConsoleFragmented(player, string)
	{	
		local charlimit = 200; // Console limit is 255, but we go a bit lower to be safe
		if (string.len() < charlimit)
		{
			ClientPrint(player, 2, string);
			return;
		}
		
		// We use these in order as delimiters; rather than splitting the string exactly into 200 characters,
		// we go as far as we can go and then check these to get a split point below 200
		local last_newline     = null
		local last_punctuation = null
		local last_whitespace  = null
	
		local start  = 0;
		local strlen = string.len();
		for (local i = 0; i < strlen; ++i)
		{
			local ch = string[i];
			
			if (i == start + charlimit || i == strlen - 1)
			{
				local end = i;

				if (i != strlen - 1)
				{
					if (last_newline)          end = last_newline;
					else if (last_punctuation) end = last_punctuation;
					else if (last_whitespace)  end = last_whitespace;
				}
				
				end += 1;
				
				ClientPrint(player, 2, string.slice(start, end));
				start = end;
				
				last_newline     = null
				last_punctuation = null
				last_whitespace  = null
			}
			
			if (ch == '\n')
				last_newline = i;
			else if (ch in PUNCTUATION)
				last_punctuation = i;
			else if (ch in WHITESPACE)
				last_whitespace = i;
		}
	},
	
	function ParseCommand(string, cmdstart="!", strchar='`')
	{
		local cmd = {
			start = null,
			name  = null,
			args  = [],
			error = null			
		}

		if (string == cmdstart) return cmd;
		
		// Make sure our string actually starts with cmdstart
		if (typeof(cmdstart) == "string" && !startswith(string, cmdstart))
			return cmd;
		else if (typeof(cmdstart) == "array")
		{
			local found = false;
			foreach (s in cmdstart)
			{
				if (startswith(string, s))
				{
					found    = true;
					cmdstart = s;
					break;
				}
			}
			if (!found) return cmd;
		}
		
		cmd.start = cmdstart;
		
		// Get rid of cmdstart from string
		if (cmdstart)
			string = string.slice(cmdstart.len());
		
		// Parse tokens
		local tokens = [];
		local in_str = false;
		local start  = null
		local strlen = string.len();
		for (local i = 0; i < strlen; ++i)
		{
			local ch = string[i];
			
			if (ch in WHITESPACE)
			{
				if (start != null)
				{
					if (in_str) continue;
					
					// End of token
					tokens.append(string.slice(start, i));
					start = null;
				}
			}
			else
			{
				if (start == null)
				{
					start = i;
					
					if (ch == strchar)
						in_str = true;
				}
				else
				{
					if (ch == strchar)
					{
						in_str = false;
						
						tokens.append(string.slice(start+1, i));
						start = null;
					}
				}
			}
			
			// Ensure we detect the last token
			if (i == string.len() - 1 && start != null)
			{
				if (in_str)
				{
					cmd.error <- "[CMD] Invalid arguments: String token was not closed before EOL.";
					return cmd;
				}

				tokens.append(string.slice(start));
				break;
			}
		}
		
		cmd.name <- tokens[0];
		
		if (tokens.len() > 1)
			cmd.args <- tokens.slice(1);
		
		return cmd;
	},

	function HandleArgs(player, cmd, argformat)
	{
		// Collect amount of required args
		local required_args = 0;
		foreach (arg in argformat)
			if ("required" in arg && arg.required)
				++required_args;
		
		local arglen    = cmd.args.len();
		local formatlen = null;
		
		// We don't care about going over length if our last arg is a vararg
		local last = argformat.top();
		if (!("vararg" in last) || !last.vararg)
			formatlen = argformat.len();

		// Check number of args in cmd
		if (arglen < required_args || (formatlen && (arglen > formatlen)))
		{
			local output = format("[CMD] Usage: !%s", cmd.name);
			foreach (arg in argformat)
			{
				if ("required" in arg && arg.required)
					output += format(" (%s)", arg.name);
				else
					output += format(" [%s]", arg.name);
			}
			return output; // Caller handles error msg display
		}
		
		foreach (index, arg in argformat)
		{
			local cmparg = null;
			if (index < arglen)
				cmparg = cmd.args[index];
			
			if (cmparg != null)
			{
				// Check type
				if (!("type" in arg))
					arg.type <- "string";

				try
				{
					switch (arg.type)
					{
					case "integer":
						cmd.args[index] = cmparg.tointeger();
						break;
					case "float":
						cmd.args[index] = cmparg.tofloat();
						break;
					}
				}
				catch (err)
				{
					return format("[CMD] Invalid type for argument <%s>, expected <%s>", arg.name, arg.type);
				}
				
				// Target type is a special case
				if (arg.type == "target")
				{
					local targets = ResolveTargetString(cmparg, player);
					if (!targets || !targets.len())
						return "[CMD] Could not find a valid target";
					else
					{
						if ("flags" in arg)
						{
							if ((arg.flags & TARGETFLAGS_NOSELF) && targets.find(player) != null)
								return "[CMD] Command does not support targeting yourself";
							else if ((arg.flags & TARGETFLAGS_NOMULTIPLE) && targets.len() > 1)
								return "[CMD] Command does not support multiple targets";
							else if ((arg.flags & TARGETFLAGS_NOBOTS))
							{
								foreach (t in targets)
									if (t.IsBotOfType(1337))
										return "[CMD] Command does not support targeting bots";
							}
						}
						cmd.args[index] = targets;
					}
				}
				
				// Update this with the new typed value
				cmparg = cmd.args[index];
				
				// Check bounds
				if (arg.type == "integer" || arg.type == "float")
				{
					local f = (arg.type == "integer") ? "%d" : "%.2f"
					if ("min_value" in arg && cmparg < arg.min_value)
						return format("[CMD] Argument <%s> below minimum value <" + f + ">", arg.name, arg.min_value);
					if ("max_value" in arg && cmparg > arg.max_value)
						return format("[CMD] Argument <%s> above maximum value <" + f + ">", arg.name, arg.max_value);
				}
			}
			else
			{
				cmd.args.append(null);
			}
		}
	},
	
	function GetAllPlayers(filter=null)
	{
		local players = []
		for (local i = 1; i <= MaxPlayers; ++i)
		{
			local player = PlayerInstanceFromIndex(i)
			if (player == null) continue
			
			if (filter)
			{
				if (filter(player))
					players.append(player);
			}
			else
				players.append(player)
		}
		return players;
	},
	
	function ResolveTargetString(string, player=null)
	{
		switch (string)
		{
		case "@all":
			return GetAllPlayers();
			
		case "@humans":
			return GetAllPlayers( @(p) !p.IsBotOfType(1337) );
		
		case "@bots":
			return GetAllPlayers( @(p) p.IsBotOfType(1337) );
			
		case "@alive":
			return GetAllPlayers( @(p) NetProps.GetPropInt(p, "m_lifeState") == 0 );
			
		case "@dead":
			return GetAllPlayers( @(p) NetProps.GetPropInt(p, "m_lifeState") != 0 );
			
		case "@aim":
			if (NetProps.GetPropInt(player, "m_lifeState") != 0)
				return []

			local eyepos = player.EyePosition();
			local trace = {
				start = eyepos,
				end = eyepos + player.EyeAngles().Forward() * 8192,
				mask = 33554433, // CONTENTS_SOLID|CONTENTS_MONSTER
				ignore = player,
			};
			TraceLineEx(trace);
			
			if (trace.enthit && trace.enthit.IsPlayer())
				return [trace.enthit];
			else
				return [];
			
		case "@me":
			return [player]
			
		case "@!me":
			return GetAllPlayers( @(p) p != player );
			
		case "@red":
			return GetAllPlayers( @(p) p.GetTeam() == 2 );
			
		case "@blue":
			return GetAllPlayers( @(p) p.GetTeam() == 3 );
			
		default:
			if (startswith(string, "#[U:"))
			{
				local steamid = string.slice(1);
				for (local i = 1; i <= MaxPlayers; ++i)
				{
					local p = PlayerInstanceFromIndex(i)
					if (p == null) continue
					if (steamid == NetProps.GetPropString(p, "m_szNetworkIDString")) return [p];
				}
			}
			else if (startswith(string, "#"))
			{
				local userid = null;
				try { userid = string.slice(1).tointeger(); }
				catch (err) {}
				
				if (userid)
				{
					local player = GetPlayerFromUserID(userid);
					if (player)
						return [player];
				}
				else
				{
					local name = string.slice(1);
					for (local i = 1; i <= MaxPlayers; ++i)
					{
						local p = PlayerInstanceFromIndex(i)
						if (p == null) continue
						
						if (name == NetProps.GetPropString(p, "m_szNetname")) return [p];
					}
				}
			}
			else
			{
				local t = null
				for (local i = 1; i <= MaxPlayers; ++i)
				{
					local p = PlayerInstanceFromIndex(i)
					if (p == null) continue
					
					local n = NetProps.GetPropString(p, "m_szNetname");
					if (startswith(n, string))
					{
						if (t == null)
							t = p;
						else
							return [];
					}
				}

				if (t != null)
					return [t];
			}

			return [];
		}
	},
	
	function JoinArray(arr)
	{
		local output = "";
		foreach (index, elem in arr)
		{
			output += elem;
			if (index != arr.len() - 1)
				output += " ";
		}
		return output;
	},
	
	function GetWeaponInfo(player, wpn)
	{
		if (typeof wpn == "string")
		{
			local array = WARPAINT_WEAPONS[player.GetPlayerClass()];
			foreach (data in array)
			{
				foreach (k, v in data)
					if (k != "slot" && v.tostring() == wpn)
						return data;
				
				if (data.name.find(wpn) != null)
					return data;
			}
		}
		else if (wpn instanceof CBaseCombatWeapon)
		{
			local array = WARPAINT_WEAPONS[player.GetPlayerClass()];
			local cls   = wpn.GetClassname();
			local id    = GetPropInt(wpn, STRING_NETPROP_ITEMDEF);
			
			foreach (data in array)
				if (data.id == id)
					return data;
			foreach (data in array)
				if (data.cls == cls)
					return data;
		}
	},
	
	function GetAdjacentWeaponInfo(player, increment)
	{
		local wpn = player.GetActiveWeapon();
		if (!wpn)
			return;
		
		local wpn_info = GetWeaponInfo(player, wpn);
		if (!wpn_info)
			return;
		
		local array = WARPAINT_WEAPONS[player.GetPlayerClass()];
		local slot = wpn.GetSlot();
		local ids = [];
		foreach (t in array)
			if (t.slot == slot)
				ids.append(t.id);
			
		if (!ids)
			return;
		
		ids.sort();
		local index = ids.find(wpn_info.id);
		if (index == null)
			return;
		
		if (increment < 0)
			index = (index + increment >= 0) ? index + increment : ids.len() - 1;
		else
			index = (index + increment < ids.len()) ? index + increment : 0;
			
		local wpn_info = null;
		foreach (t in array)
			if (ids[index] == t.id)
				wpn_info = t;
		
		return wpn_info;
	},
	
	function GetPlayerLoadout(player) {
		local loadout = [];
		
		for (local i = 0; i < SLOT_COUNT; ++i) {
			local wpn = GetPropEntityArray(player, "m_hMyWeapons", i);
			if ( wpn == null) continue
			loadout.append(wpn);
		}
		for (local child = player.FirstMoveChild(); child != null; child = child.NextMovePeer()) {
			local id = GetPropInt(child, STRING_NETPROP_ITEMDEF);
			if (id in WEARABLE_WEAPONS)
				loadout.append(child);
		}
		
		return loadout;
	},
	
	function GetItemInSlot(player, slot) {
		for (local i = 0; i < SLOT_COUNT; ++i)
		{
			local wep = GetPropEntityArray(player, "m_hMyWeapons", i);
			if ( wep == null || wep.GetSlot() != slot) continue;

			return wep;
		}
	},
	
	function CapitalizeString(string)
	{
		local arr = split(string, " ", true);
		foreach (i, s in arr)
		{
			if (s.len() > 1)
				arr[i] = s[0].tochar().toupper() + s.slice(1);
			else
				arr[i] = s.toupper();
		}
		return JoinArray(arr);
	},
	
	function GiveWarpaintWeapon(player, wpn_info, paint=null, wear=null, effect=null, killstreak=null, seed=null)
	{
		if (!wpn_info) return;
		
		local wpn = CreateByClassname(wpn_info.cls);
		if (!wpn) return;
		
		local old_wpn = GetItemInSlot(player, wpn_info.slot);
		if (!old_wpn)
		{
			// Search for wearable items and remove them if we need the slot
			local loadout = GetPlayerLoadout(player);
			foreach (item in loadout)
			{
				local id = GetPropInt(item, STRING_NETPROP_ITEMDEF);
				if (id in WEARABLE_WEAPONS && WEARABLE_WEAPONS[id] == wpn_info.slot)
				{
					old_wpn = item;
					break;
				}
			}
		}
		if (old_wpn)
			old_wpn.Destroy();
		
		SetPropInt(wpn, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", wpn_info.id);
		SetPropBool(wpn, "m_AttributeManager.m_Item.m_bInitialized", true);
		SetPropBool(wpn, "m_bValidatedAttachedEntity", true);
		wpn.SetTeam(player.GetTeam());
		
		DispatchSpawn(wpn);
		player.Weapon_Equip(wpn);
		player.Weapon_Switch(wpn);
		
		player.ValidateScriptScope();
		local scope = player.GetScriptScope();
		
		local data = [
			{val=paint, name="paint", cast2f=true, attrs={"paintkit_proto_def_index": "val"}},
			{val=wear, name="wear", attrs={"Set_item_texture_wear": "val"}},
			{val=effect, name="effect", attrs={"attach particle effect": "val"}},
			{val=killstreak, name="killstreak", attrs={"killstreak idleeffect": "val", "killstreak tier": 2}},
			{val=seed, name="seed", attrs={"custom_paintkit_seed_lo": "val", "custom_paintkit_seed_hi": 0}},
		];
		
		// Apply attributes
		foreach (table in data)
		{
			table.val = (table.val != null) ? table.val : scope[table.name];
			if (table.val != null)
			{
				scope[table.name] = table.val;
				foreach (attr, val in table.attrs)
				{
					local v = (val == "val") ? table.val : val;
					if ("cast2f" in table && table.cast2f)
						v = casti2f(v);
					
					wpn.AddAttribute(attr, v, -1);
				}
			}
		}
		
		wpn.ReapplyProvision();

		return wpn;
	},
	
	function HandleWarpaintCommand(player, cmd, argstring, numargfillers, valuetype, table, giveweapon=true, params=null)
	{
		params = (params == null) ? [{name="value",type="string",required=true,vararg=true}] : params;
		local err = HandleArgs(player, cmd, params);
		if (err)
		{
			ClientPrint(player, 3, err);
			return;
		}

		if (cmd.args[0] == null)
			return;

		local arg = JoinArray(cmd.args).tolower();
		local string = "";
		try
		{
			if (valuetype == "integer")
				arg = arg.tointeger();
			else if (valuetype == "float")
				arg = arg.tofloat();

			// Grab name for reply msg
			foreach (name, id in table)
			{
				if (arg == id)
				{
					string = name;
					break;
				}
			}
		}
		catch (err)
		{
			foreach (name, id in table)
			{
				if (name.find(arg) != null)
				{
					arg = id;
					string = name;
					break;
				}
			}
		}
		if (typeof arg != valuetype)
		{
			ClientPrint(player, 3, format("[CMD] Invalid %s", argstring));
			return;
		}
		
		if (!giveweapon)
			return arg;
			
		local wpn_info = GetWeaponInfo(player, player.GetActiveWeapon());
		
		local args = [this, player, wpn_info];
		for (local i = 0; i < numargfillers; ++i)
			args.append(null);
		args.append(arg);

		local wpn = GiveWarpaintWeapon.acall(args);
		if (!wpn)
			ClientPrint(player, 3, "[CMD] Could not find weapon data");
		else
		{
			local f = (valuetype == "integer") ? "%d" : "%.2f";
			ClientPrint(player, 3, format("[CMD] Applying %s: %s [" + f + "]", argstring, CapitalizeString(string), arg));
		}
	}
	
	function PlayerThink() {
		local buttons = NetProps.GetPropInt(self, "m_nButtons");
		local buttons_changed = buttons_last ^ buttons;
		local buttons_pressed = buttons_changed & buttons;
		local buttons_released = buttons_changed & (~buttons);		

		buttons_last = buttons;
		return -1;
	},
	
	function OnGameEvent_post_inventory_application(params) {
		local player = GetPlayerFromUserID(params.userid)
		if (!player) return;
		
		player.ValidateScriptScope();
		local scope = player.GetScriptScope();
		
		if (!("buttons_last" in scope))
			foreach (k, v in DEFAULT_PLAYER_SCOPE)
				scope[k] <- v;
			
		if (!player.IsBotOfType(1337))
		{
			local origin = player.GetOrigin();
			for (local ent; ent = FindByClassnameWithin(ent, "tf_dropped_weapon", origin, 128.0);)
				EntFireByHandle(ent, "Kill", "", 0, null, null);
			
			if (scope.loadoutpaint != null)
			{
				local array = WARPAINT_WEAPONS[player.GetPlayerClass()];
				local data = { [SLOT_PRIMARY]={}, [SLOT_SECONDARY]={}, [SLOT_MELEE]={} };
				foreach (t in array)
				{
					local data_table = data[t.slot];
					if (!data_table.len() || t.id < data_table.id)
						data[t.slot] = t;
				}
				
				foreach (slot, wpn_info in data)
					if (wpn_info.len())
						GiveWarpaintWeapon(player, wpn_info, scope.loadoutpaint);
				
				EntFireByHandle(player, "RunScriptCode",
								"local w = Warpaints.GetItemInSlot(self, 0); self.Weapon_Switch(w);",
								0.015, null, null);
			}
			
			scope.Think <- PlayerThink;
			AddThinkToEnt(player, "Think");
		}
	},
	
	function OnGameEvent_player_say(params)
	{
		local player = GetPlayerFromUserID(params.userid);
		if (!player) return;
		
		player.ValidateScriptScope();
		local scope = player.GetScriptScope();
		
		local cmd = ParseCommand(params.text);
		
		if (cmd.error)
		{
			ClientPrint(player, 3, cmd.error);
			return;
		}
		
		if (!cmd || !cmd.name) return;

		switch (cmd.name)
		{
		case "help":
		case "h":
			ClientPrint(player, 3, "[CMD] See console for output");
			PrintToConsoleFragmented(player, HELP_STRING);

			break;

		case "give":
		case "g":
			local err = HandleArgs(player, cmd, [{name="target",type="target",required=true},
												 {name="weapon",type="string",required=true,vararg=true},
												]);
			if (err)
			{
				ClientPrint(player, 3, err);
				break;
			}
			
			local targets  = cmd.args[0];
			local string   = JoinArray(cmd.args.slice(1)).tolower();
			
			foreach (t in targets)
			{
				local wpn_info = GetWeaponInfo(t, string);
				GiveWarpaintWeapon(t, wpn_info, scope.paint, scope.wear, scope.effect, scope.killstreak, scope.seed);
			}
			
			ClientPrint(player, 3, "[CMD] Attempting to give targets the weapon");
			
			break;

		case "giveme":
		case "gimme":
		case "gm":
			local err = HandleArgs(player, cmd, [{name="weapon",type="string",required=true,vararg=true}]);
			if (err)
			{
				ClientPrint(player, 3, err);
				break;
			}
			
			local string   = JoinArray(cmd.args).tolower();
			local wpn_info = GetWeaponInfo(player, string);
			
			local wpn = GiveWarpaintWeapon(player, wpn_info);
			if (!wpn)
				ClientPrint(player, 3, "[CMD] Could not find weapon data");
			else
				ClientPrint(player, 3, format("[CMD] Giving self weapon: %s", CapitalizeString(wpn_info.name)));
			
			break;
			
		case "paint":
		case "p":
			HandleWarpaintCommand(player, cmd, "paint", 0, "integer", PAINTS);
			break;
			
		case "wear":
		case "w":
			HandleWarpaintCommand(player, cmd, "wear", 1, "float", WEARS);
			break;
			
		case "effect":
		case "e":
			HandleWarpaintCommand(player, cmd, "effect", 2, "integer", EFFECTS);
			break;
			
		case "killstreak":
		case "ks":
			HandleWarpaintCommand(player, cmd, "killstreak", 3, "integer", KILLSTREAKS);
			break;
			
		case "randomseed":
		case "rs":
			local seed = RandomInt(0, INT_MAX32);
			
			local wpn = player.GetActiveWeapon();
			if (!wpn)
				break;
			
			local wpn_info = GetWeaponInfo(player, wpn);
			wpn = GiveWarpaintWeapon(player, wpn_info, null, null, null, null, seed);
			if (!wpn)
				ClientPrint(player, 3, "[CMD] Could not find weapon data");
			else
			{
				ClientPrint(player, 3, "[CMD] Applying paintkit seed:");
				ClientPrint(player, 3, format("\x0733BEE8%d", seed));
			}
			
			break;
			
		case "seed":
		case "s":
			local err = HandleArgs(player, cmd, [{name="seed",type="integer",min_value=0,max_value=INT_MAX32,
												  required=true}]);
			if (err)
			{
				ClientPrint(player, 3, err);
				break;
			}
			
			local seed = cmd.args[0];
			
			local wpn = player.GetActiveWeapon();
			if (!wpn)
				break;
			
			local wpn_info = GetWeaponInfo(player, wpn);
			wpn = GiveWarpaintWeapon(player, wpn_info, null, null, null, null, seed);
			if (!wpn)
				ClientPrint(player, 3, "[CMD] Could not find weapon data");
			else
			{
				ClientPrint(player, 3, "[CMD] Applying paintkit seed:");
				ClientPrint(player, 3, format("\x0733BEE8%d", seed));
			}
			
			break;
			
		case "loadoutpaint":
		case "lp":			
			local paint = HandleWarpaintCommand(player, cmd, "loadoutpaint", 0, "integer", PAINTS,
												false, [{name="value",type="string",vararg=true}]);
			if (!paint)
			{
				scope.loadoutpaint = null;
				ClientPrint(player, 3, "[CMD] Disabled loadout paint");
				break;
			}
			else
				scope.loadoutpaint = paint;
			
			local string = "";
			foreach (name, id in PAINTS)
			{
				if (paint == id)
				{
					string = name;
					break;
				}
			}
			
			ClientPrint(player, 3, format("[CMD] Loadout paint set to: %s [%d]", CapitalizeString(string), paint));
			player.Regenerate(true);

			break;
			
		case "next":
		case "n":
			if (scope.loadoutpaint != null)
			{
				local wpn_info = GetAdjacentWeaponInfo(player, 1);
				if (wpn_info)
				{
					GiveWarpaintWeapon(player, wpn_info, scope.loadoutpaint);
					ClientPrint(player, 3, format("[CMD] Gave self next warpaint weapon: %s", CapitalizeString(wpn_info.name)));
				}
			}
			
			break;
			
		case "prev":
		case "pr":
			if (scope.loadoutpaint != null)
			{
				local wpn_info = GetAdjacentWeaponInfo(player, -1);
				if (wpn_info)
				{
					ClientPrint(player, 3, format("[CMD] Gave self previous warpaint weapon: %s", CapitalizeString(wpn_info.name)));
					GiveWarpaintWeapon(player, wpn_info, scope.loadoutpaint);
				}
			}
			
			break;			
			
		case "thirdperson":
		case "tp":
			player.SetForcedTauntCam((scope.thirdperson = !scope.thirdperson).tointeger());
			ClientPrint(player, 3, format("[CMD] %s thirdperson", (scope.thirdperson) ? "Enabled" : "Disabled"));
			break;

		case "switchteam":
		case "switch":
		case "sw":
			player.ForceChangeTeam((player.GetTeam() == 2) ? 3 : 2, true);
			ClientPrint(player, 3, format("[CMD] Switched team to %s", (player.GetTeam() == 2) ? "RED" : "BLU"));
			player.Regenerate(true);
			break;
			
		case "reset":
		case "r":
			scope.paint        = null;
			scope.wear         = null;
			scope.effect       = null;
			scope.killstreak   = null;
			scope.loadoutpaint = null;
			scope.seed         = null;
			scope.hud          = true;
			player.Regenerate(true);
			ClientPrint(player, 3, "[CMD] Reset player warpaint data");
			break;
		}
	},
};
__CollectGameEventCallbacks(Warpaints);

ClientPrint(null, 3, "\x0750FF20<< Loaded Warpaint Commands >>\nType !help in chat for info");

local players = Warpaints.GetAllPlayers();
foreach (player in players)
{
	player.ValidateScriptScope();
	local scope = player.GetScriptScope();
	
	if (!("buttons_last" in scope))
	{
		foreach (k, v in Warpaints.DEFAULT_PLAYER_SCOPE)
			scope[k] <- v;
			
		scope.Think <- Warpaints.PlayerThink;
		AddThinkToEnt(player, "Think");
	}
}