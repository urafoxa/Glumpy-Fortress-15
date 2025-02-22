function weapongive(playerentitiy,weaponname,weaponindex) {
	local sapperfix = 0
	if (weaponname == "tf_weapon_sapper") {
		weaponname = "tf_weapon_builder"
		sapperfix = 1
	}
	local weapong = SpawnEntityFromTable(weaponname,{})	
	if (weapong == null) {
		ClientPrint(playerentitiy,3,"fbeccb[VSCRIPT] d13b30INVALID WEAPON CLASSNAME.")
		printl("[VSCRIPT] INVALID WEAPON CLASSNAME.")
		return;
	}
	NetProps.SetPropInt(weapong, "m_bValidatedAttachedEntity", 1) // Found this netprop here: https://github.com/TF2CutContentWiki/TF2ServersidePlayerAttachmentFixer
	NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", weaponindex) // I initialy did not have this which caused weapons to be. A placeholder(?) weapon called #TF_Default_ItemDef
	NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_bInitialized", 1) // This makes the weapon show up as a viewmodel.
	if (weaponname == "tf_weapon_builder") {
		if (sapperfix == 1) {
			NetProps.SetPropInt(weapong, "BuilderLocalData.m_iObjectType", 3)
			NetProps.SetPropInt(weapong, "m_iSubType", 3)
			NetProps.SetPropInt(weapong, "m_aBuildableObjectTypes.003",1)
		} else {
			NetProps.SetPropInt(weapong, "BuilderLocalData.m_iObjectType", 0)
			NetProps.SetPropInt(weapong, "m_iSubType", 0)
			NetProps.SetPropInt(weapong, "m_aBuildableObjectTypes.000",1)
			NetProps.SetPropInt(weapong, "m_aBuildableObjectTypes.001",1)
			NetProps.SetPropInt(weapong, "m_aBuildableObjectTypes.002",1)
		}
	}
	if (weaponname.find("tf_weapon_jar") != null) {
		weapong.SetClip2(1)
	}
	if (weaponname.find("tf_weapon_minigun") != null) {
			if (playerentitiy.GetPlayerClass() == 1) {
			weapong.AddAttribute("hidden primary max ammo bonus", 200 / 32, -1)
			}
			if (playerentitiy.GetPlayerClass() == 2) {
			weapong.AddAttribute("hidden primary max ammo bonus", 200 / 25, -1)
			}
			if (playerentitiy.GetPlayerClass() == 3) {
			weapong.AddAttribute("hidden primary max ammo bonus", 200 / 20, -1)
			}
			if (playerentitiy.GetPlayerClass() == 4) {
			weapong.AddAttribute("hidden primary max ammo bonus", 200 / 30, -1)
			}
			if (playerentitiy.GetPlayerClass() == 5) {
			weapong.AddAttribute("hidden primary max ammo bonus", 200 / 150, -1)
			}
			if (playerentitiy.GetPlayerClass() == 8) {
			weapong.AddAttribute("hidden primary max ammo bonus", 200 / 20, -1)
			}
			if (playerentitiy.GetPlayerClass() == 9) {
			weapong.AddAttribute("hidden primary max ammo bonus", 200 / 32, -1)
			}
	}
	playerentitiy.Weapon_Equip(weapong)	
	playerentitiy.Weapon_Switch(weapong)
	return weapong
}
function weapongivewithattributes(playerentitiy,weaponname,weaponindex,weaponattributes) {
		local attributename = ""
		local attributevalue = 0
		local weapong = weapongive(playerentitiy,weaponname,weaponindex)
		if (weapong == null) {
		ClientPrint(playerentitiy,3,"fbeccb[VSCRIPT] d13b30INVALID WEAPON CLASSNAME CHECK CUSTOM WEAPONS FILE FOR SPELLING ERRORS.")
		printl("[VSCRIPT] INVALID WEAPON CLASSNAME CHECK CUSTOM WEAPONS FILE FOR SPELLING ERRORS.")
		return;
		}
		local attribs = split(weaponattributes,";")
		ClientPrint(playerentitiy,2,"======================")
		foreach (item in attribs) {
		ClientPrint(playerentitiy,2,item)
		local attribvalues = split(item,",") 
		foreach (item in attribvalues) {
		if (item.find("0") == 0 || item.find("1") == 0||item.find("2") == 0||item.find("3") == 0||item.find("4") == 0||item.find("5") == 0||item.find("6") == 0||item.find("7") == 0||item.find("8") == 0||item.find("9") == 0||item.find("-") == 0||item.find(".") == 0) {
		attributevalue = item
		} else {
		attributename = item
		if (attributename.find("\"") != null) {
		attributename = attributename.slice(1,attributename.len() - 1)
					}
				}
			}
		weapong.AddAttribute(attributename,attributevalue.tofloat(),-1)
		}
		ClientPrint(playerentitiy,2,"======================")
		printl(weapong)
}
function giveweaponcustomCHAT(ply,data){
		local weaponlist = FileToString("chatcommands/cweapons.txt") //doing this to update the list immediately after a weapon is added. (So you don't need to reload the script)
		local weaponsinlist = split(weaponlist,"\n")
		local weaponnames = ""
		local weaponclassnames = ""
		local weaponindexs = ""
		local weaponattributes = ""
		foreach (item in weaponsinlist) {
		if (item.find("*") != null) {
		weaponnames = weaponnames + item.slice(item.find("*") + 1,item.find("*", 1)) + ","
		}
		if (item.find("classname") != null) { 
		weaponclassnames = weaponclassnames + item.slice(item.find("classname")+"classname".len() + 2) + "~"
		}
		if (item.find("itemindex") != null) { 
		weaponindexs = weaponindexs + item.slice(item.find("itemindex")+"itemindex".len() + 2) + "~"
		}
		if (item.find("attributes") != null) { 
		weaponattributes = weaponattributes + item.slice(item.find("attributes")+"attributes".len() + 2) + "~"
		//yes this is a lazy way to split the list.
		}
		}
		weaponnames = weaponnames.slice(0,weaponnames.len() - 1)
		weaponclassnames = weaponclassnames.slice(0,weaponclassnames.len() - 1)
		weaponindexs = weaponindexs.slice(0,weaponindexs.len() - 1)
		weaponattributes = weaponattributes.slice(0,weaponattributes.len() - 1) //these are backspaces
		local weaponnamesarray = split(weaponnames,",")
		local desiredweaponname = data.text.tolower().slice(data.text.tolower().find(" ") + 1)
		if (weaponnamesarray.find(desiredweaponname) != null) {
		local weaponclassnamesarray = split(weaponclassnames,"~")
		local weaponclassnametemp = weaponclassnamesarray.slice(weaponnamesarray.find(desiredweaponname),weaponnamesarray.find(desiredweaponname)+1).top()
		local desiredweaponclassname = weaponclassnametemp.slice(1,weaponclassnametemp.len() - 1)
		local weaponindexsarray = split(weaponindexs,"~")
		local desiredweaponindex = weaponindexsarray.slice(weaponnamesarray.find(desiredweaponname),weaponnamesarray.find(desiredweaponname)+1).top().tointeger()
		local weaponattributesarray = split(weaponattributes,"~")
		local desiredweaponattributes = weaponattributesarray.slice(weaponnamesarray.find(desiredweaponname),weaponnamesarray.find(desiredweaponname)+1).top()
		local desiredweaponattributes = desiredweaponattributes.slice(1,desiredweaponattributes.len() - 1)
		weapongivewithattributes(ply,desiredweaponclassname,desiredweaponindex,desiredweaponattributes)
		ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffWeapon has been successfully received.")
	} else {
		ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30Weapon named '"+ data.text.tolower().slice(data.text.tolower().find(" ") + 1) + "' not in weaponlist. Type !customweaponlist for said list.")
	}
}
function giveweaponcustom(ply,desiredweaponname){
		local weaponlist = FileToString("chatcommands/cweapons.txt") //doing this to update the list immediately after a weapon is added. (So you don't need to reload the script)
		local weaponsinlist = split(weaponlist,"\n")
		local weaponnames = ""
		local weaponclassnames = ""
		local weaponindexs = ""
		local weaponattributes = ""
		foreach (item in weaponsinlist) {
		if (item.find("*") != null) {
		weaponnames = weaponnames + item.slice(item.find("*") + 1,item.find("*", 1)) + ","
		}
		if (item.find("classname") != null) { 
		weaponclassnames = weaponclassnames + item.slice(item.find("classname")+"classname".len() + 2) + "~"
		}
		if (item.find("itemindex") != null) { 
		weaponindexs = weaponindexs + item.slice(item.find("itemindex")+"itemindex".len() + 2) + "~"
		}
		if (item.find("attributes") != null) { 
		weaponattributes = weaponattributes + item.slice(item.find("attributes")+"attributes".len() + 2) + "~"
		//yes this is a lazy way to split the list.
		}
		}
		weaponnames = weaponnames.slice(0,weaponnames.len() - 1)
		weaponclassnames = weaponclassnames.slice(0,weaponclassnames.len() - 1)
		weaponindexs = weaponindexs.slice(0,weaponindexs.len() - 1)
		weaponattributes = weaponattributes.slice(0,weaponattributes.len() - 1) //these are backspaces
		local weaponnamesarray = split(weaponnames,",")
		if (weaponnamesarray.find(desiredweaponname) != null) {
		local weaponclassnamesarray = split(weaponclassnames,"~")
		local weaponclassnametemp = weaponclassnamesarray.slice(weaponnamesarray.find(desiredweaponname),weaponnamesarray.find(desiredweaponname)+1).top()
		local desiredweaponclassname = weaponclassnametemp.slice(1,weaponclassnametemp.len() - 1)
		local weaponindexsarray = split(weaponindexs,"~")
		local desiredweaponindex = weaponindexsarray.slice(weaponnamesarray.find(desiredweaponname),weaponnamesarray.find(desiredweaponname)+1).top().tointeger()
		local weaponattributesarray = split(weaponattributes,"~")
		local desiredweaponattributes = weaponattributesarray.slice(weaponnamesarray.find(desiredweaponname),weaponnamesarray.find(desiredweaponname)+1).top()
		local desiredweaponattributes = desiredweaponattributes.slice(1,desiredweaponattributes.len() - 1)
		weapongivewithattributes(ply,desiredweaponclassname,desiredweaponindex,desiredweaponattributes)
		printl("[VSCRIPT] Weapon has been successfully received.")
	} else {
		printl("[VSCRIPT] Weapon named '"+ desiredweaponname + "' not in weaponlist. Use \"script listweapons()\" to list all weapons.")
	}
}
function listweapons() {
		local weaponlist = FileToString("chatcommands/cweapons.txt")
		local weaponsinlist = split(weaponlist,"\n")
		local weaponnames = ""
		foreach (item in weaponsinlist) {
		if (item.find("*") != null) {
		weaponnames = weaponnames + item.slice(item.find("*") + 1,item.find("*", 1)) + ","
		}
		}
		local weaponnamesarray = split(weaponnames,",")
		printl("======================")
		foreach (item in weaponnamesarray) {
		printl(item.tostring())
		}
		printl("======================")
}

function giverandomweapon(ply,chatmode) {
	local weaponlistlength = 0
	local weapons = FileToString("chatcommands/weapons.txt")
	local weaponnames = FileToString("chatcommands/weaponnames.txt")
	local weaponnameslist = split(weaponnames,"\n")
	local weaponsidlist = split(weapons,"\n")
	local weaponsclasslist = split(weapons,"\n")
	local itemclassname = null
	local itemdefindex = null
	local itemname = null
	local givepda = false
	foreach (item in weaponsidlist) {
		if(item.find("tf_") != null||item.find("saxxy") != null) {
		weaponsidlist.remove(weaponsidlist.find(item))
		}
	}
	foreach (item in weaponsclasslist) {
		if(item.find("0") != null||item.find("1") != null||item.find("2") != null||item.find("3") != null||item.find("4") != null||item.find("5") != null||item.find("6") != null||item.find("7") != null||item.find("8") != null||item.find("9") != null) {
		weaponsclasslist.remove(weaponsclasslist.find(item))
		}
	}
	
	local itemnumber = RandomInt(0,weaponnameslist.len() -1)
	if (weaponsclasslist[itemnumber].find("wearable") == null) {
		itemclassname = weaponsclasslist[itemnumber]
		if (itemclassname == "tf_weapon_wrench"||itemclassname == "tf_weapon_robot_arm") {
				givepda = true
		}
	}
	itemdefindex = weaponsidlist[itemnumber]
	itemname = weaponnameslist[itemnumber]
	if (itemclassname == "saxxy") {
		itemclassname = "tf_weapon_club"
		if (ply.GetPlayerClass() == 1) {
			itemclassname = "tf_weapon_bat"
		}
		if (ply.GetPlayerClass() == 3) {
			itemclassname = "tf_weapon_shovel"
		}
		if (ply.GetPlayerClass() == 4) {
			itemclassname = "tf_weapon_bottle"
		}
		if (ply.GetPlayerClass() == 5) {
			itemclassname = "tf_weapon_bonesaw"
		}
		if (ply.GetPlayerClass() == 6) {
			itemclassname = "tf_weapon_fists"
		}
		if (ply.GetPlayerClass() == 7) {
			itemclassname = "tf_weapon_fireaxe"
		}
		if (ply.GetPlayerClass() == 8) {
			itemclassname = "tf_weapon_knife"
		}
		if (ply.GetPlayerClass() == 9) {
			itemclassname = "tf_weapon_wrench"
		}
		weapongive(ply,itemclassname,itemdefindex.tointeger())
	} else if (itemclassname == "tf_weapon_shotgun") {
	itemclassname = "tf_weapon_shotgun_primary"
	if (ply.GetPlayerClass() == 3) {
		itemclassname = "tf_weapon_shotgun_soldier" // soldier
	}
	if (ply.GetPlayerClass() == 6) {
		itemclassname = "tf_weapon_shotgun_hwg" // heavy
	}
	if (ply.GetPlayerClass() == 7) {
		itemclassname = "tf_weapon_shotgun_pyro" // pyro
	}
	printl(itemclassname + ": " + itemdefindex)
	weapongive(ply,itemclassname,itemdefindex.tointeger())
	}
	else {
	printl(itemclassname + ": " + itemdefindex)
	weapongive(ply,itemclassname,itemdefindex.tointeger())
	}
	if (chatmode == true) {
		ClientPrint(ply,3,"[VSCRIPT] You have received '" + itemname + "'.")
	}
	if (givepda == true) {
		weapongive(ply,"tf_weapon_pda_engineer_build",25)
		weapongive(ply,"tf_weapon_pda_engineer_destroy",26)
		weapongive(ply,"tf_weapon_builder",28)
	}
}
function giverandomprimary(ply,chatmode) {
	local weaponlistlength = 0
	local weapons = FileToString("chatcommands/primaryweapons.txt")
	local weaponnames = FileToString("chatcommands/primaryweaponnames.txt")
	local weaponnameslist = split(weaponnames,"\n")
	local weaponsidlist = split(weapons,"\n")
	local weaponsclasslist = split(weapons,"\n")
	local itemclassname = null
	local itemdefindex = null
	local itemname = null
	local givepda = false
	foreach (item in weaponsidlist) {
		if(item.find("tf_") != null||item.find("saxxy") != null) {
		weaponsidlist.remove(weaponsidlist.find(item))
		}
	}
	foreach (item in weaponsclasslist) {
		if(item.find("0") != null||item.find("1") != null||item.find("2") != null||item.find("3") != null||item.find("4") != null||item.find("5") != null||item.find("6") != null||item.find("7") != null||item.find("8") != null||item.find("9") != null) {
		weaponsclasslist.remove(weaponsclasslist.find(item))
		}
	}
	local itemnumber = RandomInt(0,weaponnameslist.len() -1)
	if (weaponsclasslist[itemnumber].find("wearable") == null) {
		itemclassname = weaponsclasslist[itemnumber]
	}
	itemdefindex = weaponsidlist[itemnumber]
	itemname = weaponnameslist[itemnumber]
	if (itemclassname == "tf_weapon_shotgun") {
		itemclassname = "tf_weapon_shotgun_primary"
		if (ply.GetPlayerClass() == 3) {
			itemclassname = "tf_weapon_shotgun_soldier" // soldier
		}
		if (ply.GetPlayerClass() == 6) {
			itemclassname = "tf_weapon_shotgun_hwg" // heavy
		}
		if (ply.GetPlayerClass() == 7) {
			itemclassname = "tf_weapon_shotgun_pyro" // pyro
		}
		printl(itemclassname + ": " + itemdefindex)
		weapongive(ply,itemclassname,itemdefindex.tointeger())
	}
	else {
		printl(itemclassname + ": " + itemdefindex)
		weapongive(ply,itemclassname,itemdefindex.tointeger())
	}
	if (chatmode == true) {
		ClientPrint(ply,3,"[VSCRIPT] You have received '" + itemname + "'.")
	}
}
function giverandomsecondary(ply,chatmode) {
	local weaponlistlength = 0
	local weapons = FileToString("chatcommands/secondaryweapons.txt")
	local weaponnames = FileToString("chatcommands/secondaryweaponnames.txt")
	local weaponnameslist = split(weaponnames,"\n")
	local weaponsidlist = split(weapons,"\n")
	local weaponsclasslist = split(weapons,"\n")
	local itemclassname = null
	local itemdefindex = null
	local itemname = null
	local givepda = false
	foreach (item in weaponsidlist) {
		if(item.find("tf_") != null||item.find("saxxy") != null) {
		weaponsidlist.remove(weaponsidlist.find(item))
		}
	}
	foreach (item in weaponsclasslist) {
		if(item.find("0") != null||item.find("1") != null||item.find("2") != null||item.find("3") != null||item.find("4") != null||item.find("5") != null||item.find("6") != null||item.find("7") != null||item.find("8") != null||item.find("9") != null) {
		weaponsclasslist.remove(weaponsclasslist.find(item))
		}
	}
	
	local itemnumber = RandomInt(0,weaponnameslist.len() -1)
	if (weaponsclasslist[itemnumber].find("wearable") == null) {
		itemclassname = weaponsclasslist[itemnumber]
	}
	itemdefindex = weaponsidlist[itemnumber]
	itemname = weaponnameslist[itemnumber]
	if (itemclassname == "tf_weapon_shotgun") {
		itemclassname = "tf_weapon_shotgun_primary"
		if (ply.GetPlayerClass() == 3) {
			itemclassname = "tf_weapon_shotgun_soldier" // soldier
		}
		if (ply.GetPlayerClass() == 6) {
			itemclassname = "tf_weapon_shotgun_hwg" // heavy
		}
		if (ply.GetPlayerClass() == 7) {
			itemclassname = "tf_weapon_shotgun_pyro" // pyro
		}
		printl(itemclassname + ": " + itemdefindex)
		weapongive(ply,itemclassname,itemdefindex.tointeger())
	}
	else {
	printl(itemclassname + ": " + itemdefindex)
	weapongive(ply,itemclassname,itemdefindex.tointeger())
	}
	if (chatmode == true) {
	ClientPrint(ply,3,"[VSCRIPT] You have received '" + itemname + "'.")
	}
}
function giverandommelee(ply,chatmode) {
	local weaponlistlength = 0
	local weapons = FileToString("chatcommands/meleeweapons.txt")
	local weaponnames = FileToString("chatcommands/meleeweaponnames.txt")
	local weaponnameslist = split(weaponnames,"\n")
	local weaponsidlist = split(weapons,"\n")
	local weaponsclasslist = split(weapons,"\n")
	local itemclassname = null
	local itemdefindex = null
	local itemname = null
	local givepda = false
	foreach (item in weaponsidlist) {
		if(item.find("tf_") != null||item.find("saxxy") != null) {
		weaponsidlist.remove(weaponsidlist.find(item))
		}
	}
	foreach (item in weaponsclasslist) {
		if(item.find("0") != null||item.find("1") != null||item.find("2") != null||item.find("3") != null||item.find("4") != null||item.find("5") != null||item.find("6") != null||item.find("7") != null||item.find("8") != null||item.find("9") != null) {
		weaponsclasslist.remove(weaponsclasslist.find(item))
		}
	}
	local itemnumber = RandomInt(0,weaponnameslist.len() -1)
	if (weaponsclasslist[itemnumber].find("wearable") == null) {
		itemclassname = weaponsclasslist[itemnumber]
		if (itemclassname == "tf_weapon_wrench"||itemclassname == "tf_weapon_robot_arm") {
				givepda = true
		}
	}
	itemdefindex = weaponsidlist[itemnumber]
	itemname = weaponnameslist[itemnumber]
 	if (itemclassname == "saxxy") {
		itemclassname = "tf_weapon_club" //default
		if (ply.GetPlayerClass() == 1) {
			itemclassname = "tf_weapon_bat"
		}
		if (ply.GetPlayerClass() == 3) {
			itemclassname = "tf_weapon_shovel"
		}
		if (ply.GetPlayerClass() == 4) {
			itemclassname = "tf_weapon_bottle"
		}
		if (ply.GetPlayerClass() == 5) {
			itemclassname = "tf_weapon_bonesaw"
		}
		if (ply.GetPlayerClass() == 6) {
			itemclassname = "tf_weapon_fists"
		}
		if (ply.GetPlayerClass() == 7) {
			itemclassname = "tf_weapon_fireaxe"
		}
		if (ply.GetPlayerClass() == 8) {
			itemclassname = "tf_weapon_knife"
		}
		if (ply.GetPlayerClass() == 9) {
			itemclassname = "tf_weapon_wrench"
		}
		printl(itemclassname + ": " + itemdefindex)
		weapongive(ply,itemclassname,itemdefindex.tointeger())
	}
	else {
	printl(itemclassname + ": " + itemdefindex)
	weapongive(ply,itemclassname,itemdefindex.tointeger())
	}
	if (chatmode == true) {
		ClientPrint(ply,3,"[VSCRIPT] You have received '" + itemname + "'.")
	}
	if (givepda == true) {
		weapongive(ply,"tf_weapon_pda_engineer_build",25)
		weapongive(ply,"tf_weapon_pda_engineer_destroy",26)
		weapongive(ply,"tf_weapon_builder",28)
	}
}
function giverandomloadout(ply,chatmode) {
	local index = 0
	while(index <= 46) {
		local plyw = NetProps.GetPropEntityArray(ply,"m_hMyWeapons",index)
		if(plyw != null) {
			local plywwear = NetProps.GetPropEntity(plyw,"m_hExtraWearable")
			if (plywwear != null) {
				plywwear.Kill()
			}
			local plywwearvm = NetProps.GetPropEntity(plyw,"m_hExtraWearableViewModel")
			if (plywwearvm != null) {
				plywwearvm.Kill()
			}
			plyw.Kill()
		}
		index += 1
	}
	giverandomprimary(ply,chatmode)
	giverandomsecondary(ply,chatmode)
	giverandommelee(ply,chatmode)
	if(ply.GetPlayerClass() == 8) {
		weapongive(ply,"tf_weapon_pda_spy",27)
	}
}