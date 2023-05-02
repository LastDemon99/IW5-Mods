#include maps\mp\dynamic_menu_utility;
#include maps\mp\_lb_utility;
#include maps\mp\_utility;

init()
{
	if(!int(tablelookup("mp/gametypesTable.csv", 0, getDvar("g_gametype"), 5))) return;
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill("connected", player);
		
		player.firstSpawn = 1;
		player.classMsg = 0;
		player.clearStreak = 0;
		
		player thread onMenuResponse();
		player thread onPlayerSpawn();
		player thread onChangeClass();
    }
}

onChangeClass()
{
	self endon("disconnect");	
	for(;;)
	{
		self waittill("change_class", class);		
		if(!isSubstr(class, "custom")) self setClientDvar("ui_editClass", 0);
		else
		{
			self setClientDvar("ui_editClass", 1);
			self.isCurrClass = self.curClass == class;
			self.curClass = class;
			self updateClass();
		}
	}
}

onPlayerSpawn()
{
	self endon("disconnect");	
	for(;;)
	{
		self waittill("spawned_player");
		self updateClass(1);
	}
}

onMenuResponse()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "menuresponse",  menu, response  );
		
		response = str(response);
		
		if(response == "create_class")
		{
			self setClientDvar("ui_startIndex", 2);
			self _pushMenu(self getClassUIName(), 0, 10);
			self setClassSplitDecoration();
			continue;
		}
		
		if (menu != "custom_dynamic_menu") continue;
		
		menuCount = self.pers["menu_pages"].size;
		menu = self getMenu()["title"];
		
		if (response == "back")
		{
			if (menuCount == 1) self _closeMenu();
			else
			{
				self popMenu();
				currMenu = self getMenu();	
				if(isDefined(currMenu["response"])) self setCurrentOption(strclassTable(0, currMenu["startIndex"] + currMenu["response"], 1), currMenu["startIndex"], currMenu["range"]);
				if (currMenu["title"] == self getClassUIName()) self setClassSplitDecoration();
			}
			continue;
		}
		
		response = int(response);
		
		if(menuCount > 1) self.pers["menu_pages"][self.pers["menu_pages"].size - 1]["response"] = response;		
		if (self.pers["menu_pages"][0]["title"] != self getClassUIName()) continue;
		
		if (menu == self getClassUIName())
		{
			self _pushMenu(strclassTable(0, response, 2), intclassTable(0, response, 4), intclassTable(0, response, 5));			
			switch(response)
			{
				case 2: self setCurrentOption(self getClassData("perks", 0)); continue;
				case 3: self setCurrentOption(self getClassData("perks", 6)); continue;
				case 4: self setCurrentOption(self getClassData("perks", 1)); continue;
				case 5: self setCurrentOption(self getClassData("perks", 2)); continue;
				case 6: self setCurrentOption(self getClassData("perks", 3)); continue;
				case 7: self setCurrentOption(self getClassData("perks", 5)); continue;
				case 8: self setCurrentOption(self getClassData("deathstreak")); continue;
			}
			
			weapon = response == 0 ? self getClassData("weaponSetups", 0, "weapon") : self getClassData("weaponSetups", 1, "weapon");
			if (weapon == "none") self setClientDvar("optionType0", 4);
			else self setCurrentOption(getWeaponClass(weapon));
			continue;
		}
		
		menuInfoIndex = response + self getMenu()["startIndex"];
		itemName = strclassTable(0, menuInfoIndex, 1);
		
		switch(menu)
		{
			case "MENU_PRIMARY_CAPS": self pushWeaponMenu(0, itemName, menuInfoIndex); continue;
			case "MENU_SECONDARY_CAPS": self pushWeaponMenu(1, itemName, menuInfoIndex); continue;
			case "MENU_STREAK_TYPE_CAPS":
				self.clearStreak = 1;
				if (itemName == "specialty_null")
				{
					for(i = 0; i < 3; i++)
					{
						self setClassData("assaultStreaks", "none", i);
						self setClassData("defenseStreaks", "none", i);
						self setClassData("specialistStreaks", "none", i);
					}
					self setClassData("perks", itemName, 5);
					self _closeMenu();
					continue;
				}
				startIndex = intclassTable(0, menuInfoIndex, 4);
				range = intclassTable(0, menuInfoIndex, 5);
				self setClassData("perks", itemName, 5);
				self _pushMenu(strclassTable(0, menuInfoIndex, 2), startIndex, range);
				streaks = self getKillStreaks();				
				if(streaks[0] == "specialistStreaks") self setCurrentOptions([(self getClassData("perks", 1) + "_ks"), (self getClassData("perks", 2) + "_ks"), (self getClassData("perks", 3) + "_ks")], startIndex, range, 0);
				else
				{
					self setCurrentOptions([streaks[1], streaks[2], streaks[3]], startIndex, range);
					self checkStreakCombos(streaks[0], streaks[1], streaks[2], startIndex, range);
				}
				continue;
		}
		
		perkIndex = undefined;
		if(menu == "MENU_EQUIPMENT_CAPS") perkIndex = 0;
		else if(menu == "MENU_SPECIAL_EQUIPMENT_CAPS") perkIndex = 6;
		else if(menu == "MENU_PERK1_CAPS") perkIndex = 1;
		else if(menu == "MENU_PERK2_CAPS") perkIndex = 2;
		else if(menu == "MENU_PERK3_CAPS") perkIndex = 3;
		
		if(isDefined(perkIndex))
		{
			self setClassData("perks", itemName, perkIndex);
			self _closeMenu();
			continue;
		}
		
		if(menu == "MENU_DEATHSTREAK_CAPS")
		{
			self setClassData("deathstreak", itemName);
			self _closeMenu();
			continue;
		}
		
		if(menuCount < 3) continue;
		prevMenu = self getMenu(1)["title"];
		
		if(prevMenu == "MENU_PRIMARY_CAPS")
		{
			wepClass = getWeaponClass(itemName);
			startIndex = intclassTable(1, wepClass, 6);
			range = intclassTable(1, wepClass, 7);
			
			self setWeaponData(0, "weapon", itemName);
			self _pushMenu("PROFICIENCY", startIndex, range);
			self setCurrentOption(self getClassData("weaponSetups", 0, "buff"), startIndex, range);
			if(itemName == "iw5_1887") self setCurrentOption("specialty_bling", startIndex, range, 0);
			continue;
		}
		
		if(prevMenu == "MENU_SECONDARY_CAPS")
		{
			self setWeaponData(1, "weapon", itemName);
			if(getWeaponClass(self getClassData("weaponSetups", 1, "weapon")) == "weapon_projectile")
			{
				self _closeMenu();
				continue;
			}			
			startIndex = intclassTable(0, menuInfoIndex, 4);
			range = intclassTable(0, menuInfoIndex, 5);			
			self _pushMenu("ATTACHMENTS", startIndex, range);
			self setCurrentOption(self getClassData("weaponSetups", 1, "attachment", 0), startIndex, range);
			continue;
		}
		
		if(prevMenu == "MENU_STREAK_TYPE_CAPS")
		{
			self.clearStreak = 1;
			currMenu = self getMenu();
			startIndex = currMenu["startIndex"];
			range = currMenu["range"];
			
			streaks = self getKillStreaks();			
			if (itemName == streaks[1])
			{
				if (streaks[2] == "none") self setClassData(streaks[0], "none", 0);
				else
				{
					self setClassData(streaks[0], streaks[2], 0);
					self setClassData(streaks[0], streaks[3], 1);
					self setClassData(streaks[0], "none", 2);
				}
			}
			else if (itemName == streaks[2])
			{
				if (streaks[3] == "none") self setClassData(streaks[0], "none", 1);
				else
				{
					self setClassData(streaks[0], streaks[3], 1);
					self setClassData(streaks[0], "none", 2);
				}
			}
			else if (itemName == streaks[3]) self setClassData(streaks[0], "none", 2);
			else if (streaks[1] == "none" && streaks[2] == "none" && streaks[3] == "none") self setClassData(streaks[0], itemName, 0);
			else if (streaks[2] == "none" && streaks[3] == "none") self setClassData(streaks[0], itemName, 1);
			else
			{
				self setClassData(streaks[0], itemName, 2);
				self _closeMenu();
				continue;
			}			
			self popMenu();
			self _pushMenu(currMenu["title"], startIndex, range);
			streaks = self getKillStreaks();
			self setCurrentOptions([streaks[1], streaks[2], self getClassData(streaks[0], 2)], startIndex, range);
			if(streaks[0] == "specialistStreaks") self setCurrentOptions([(self getClassData("perks", 1) + "_ks"), (self getClassData("perks", 2) + "_ks"), (self getClassData("perks", 3) + "_ks")], startIndex, range, 0);
			else self checkStreakCombos(streaks[0], streaks[1], streaks[2], startIndex, range);
			continue;
		}
		
		if(menuCount < 4) continue;		
		prevMenu = self getMenu(2)["title"];
		
		if(prevMenu == "MENU_PRIMARY_CAPS")
		{			
			weapon = self getClassData("weaponSetups", 0, "weapon");
			startIndex = intclassTable(1, weapon, 4);
			range = intclassTable(1, weapon, 5);			
			self setWeaponData(0, "buff", itemName);
			
			if(getWeaponClass(weapon) == "weapon_riot")
			{
				self _closeMenu();
				continue;
			}
			
			self _pushMenu("ATTACHMENTS", startIndex, range);
			
			if(weapon == "iw5_ak74u") self setCurrentOption("hamrhybrid", startIndex, range, 0);
			if(itemName == "specialty_bling")
			{
				attach1 = self getClassData("weaponSetups", 0, "attachment", 0);
				self setCurrentOptions([attach1, self getClassData("weaponSetups", 0, "attachment", 1)], startIndex, range);
				self checkAttachCombos(attach1, startIndex, range);
				continue;
			}
			
			self setCurrentOption(self getClassData("weaponSetups", 0, "weapon"), startIndex, range);
			self setWeaponData(0, "attachment", "none", 1);
			continue;
		}
		
		if(prevMenu == "MENU_SECONDARY_CAPS")
		{
			self setWeaponData(1, "attachment", itemName, 0);
			self checkReticle(1, itemName, "none");
			continue;
		}
		
		if(menuCount < 5) continue;
		
		if(menu == "RETICLE")
		{
			wepIndex = self getMenu(4)["title"] == "MENU_PRIMARY_CAPS" ? 0 : 1;
			self setWeaponData(wepIndex, "reticle", itemName);			
			if (wepIndex == 0) self _pushMenu("CAMOUFLAGE", 321, 14);
			else self _closeMenu();
			continue;
		}
		
		prevMenu = self getMenu(3)["title"];
		if(prevMenu == "MENU_PRIMARY_CAPS")
		{
			weapon = self getClassData("weaponSetups", 0, "weapon");
			if(strclassTable(0, menuInfoIndex, 2) == "GRENADE LAUNCHER") itemName = getGrenadeLauncher(weapon);	
			if(self getClassData("weaponSetups", 0, "buff") != "specialty_bling")
			{
				self setWeaponData(0, "attachment", itemName, 0);
				self checkReticle(0, itemName, "none");
				continue;
			}			
			if (response == 0)
			{
				self _closeMenu();
				continue;
			}
			
			currMenu = self getMenu();
			startIndex = currMenu["startIndex"];
			range = currMenu["range"];
			attach1 = self getClassData("weaponSetups", 0, "attachment", 0);
			attach2 = self getClassData("weaponSetups", 0, "attachment", 1);
			
			if (itemName == attach1)
			{
				if (attach2 == "none") self setWeaponData(0, "attachment", "none", 0);
				else
				{
					self setWeaponData(0, "attachment", attach2, 0);
					self setWeaponData(0, "attachment", "none", 1);
				}
			}
			else if (itemName == attach2) self setWeaponData(0, "attachment", "none", 1);
			else if (attach1 == "none" && attach2 == "none") self setWeaponData(0, "attachment", itemName, 0);
			else
			{
				self setWeaponData(0, "attachment", itemName, 1);
				self checkReticle(0, attach1, itemName);
				if(weapon == "iw5_ak74u") self setCurrentOption("hamrhybrid", startIndex, range, 0);
				continue;
			}
			
			self popMenu();
			self _pushMenu("ATTACHMENTS", startIndex, range);
			attach1 = self getClassData("weaponSetups", 0, "attachment", 0);			
			self setCurrentOptions([attach1, self getClassData("weaponSetups", 0, "attachment", 1)], startIndex, range);
			self checkAttachCombos(attach1, startIndex, range);
			if(weapon == "iw5_ak74u") self setCurrentOption("hamrhybrid", startIndex, range, 0);
			continue;
		}
		
		if(menuCount < 6) continue;		
		if(menu == "CAMOUFLAGE")
		{
			self setWeaponData(0, "camo", itemName);
			self _closeMenu();
			continue;
		}
	}
}

pushWeaponMenu(wepIndex, weapon, menuInfoIndex)
{
	if(weapon == "none") 
	{
		self setWeaponData(wepIndex, "weapon", "none");
		self _closeMenu();
		return;
	}
	
	startIndex = intclassTable(0, menuInfoIndex, 4);
	range = intclassTable(0, menuInfoIndex, 5);
	self _pushMenu(strclassTable(0, menuInfoIndex, 2), startIndex, range);
	self setCurrentOption(self getClassData("weaponSetups", wepIndex, "weapon"), startIndex, range);
}

checkReticle(wepIndex, attach1, attach2)
{
	if((attach1 == "reflex" || attach1 == "acog") || (attach2 == "reflex" || attach2 == "acog"))
	{
		self _pushMenu("RETICLE", 313, 7);
		self setCurrentOption(self getClassData("weaponSetups", wepIndex, "reticle"), 313, 7);
	}
	else
	{
		self setWeaponData(wepIndex, "reticle", "none");
		if (wepIndex == 0) self _pushMenu("CAMOUFLAGE", 321, 14);
		else self _closeMenu();
	}
}

getKillStreaks()
{
	streakType = self _getStreakType();
	return [streakType, self getClassData(streakType, 0), self getClassData(streakType, 1), self getClassData(streakType, 2)];
}

updateClass(arg)
{	
	if((level.inGracePeriod && !self.hasDoneCombat) || isDefined(arg))
	{
		self.pers["gamemodeLoadout"] = self maps\mp\gametypes\_class::cloneLoadout();
		self.pers["gamemodeLoadout"]["loadoutJuggernaut"] = false;
		
		self maps\mp\gametypes\_class::giveLoadout(self.team, "gamemode", false, true);		
		if(self.clearStreak)
		{
			self maps\mp\killstreaks\_killstreaks::clearKillstreaks();
			self.clearStreak = 0;
		}
		self.classMsg = 0;
	}
	else self.classMsg = 1;
}

_pushMenu(title, startIndex, range)
{
	self updateClass();
	self pushMenu(title, "editClassMenu", startIndex, range);
}

_closeMenu()
{
	self updateClass();
	self closeMenus();
	self menuInit();
	if (self.classMsg && !isInKillcam()) self iprintlnbold(game["strings"]["change_class"]);
}

setCurrentOption(target, startIndex, range, type)
{
	menu = self getMenu();
	startIndex = isDefined(startIndex) ? startIndex : menu["startIndex"];
	range = isDefined(range) ? range : menu["range"];
	type = isDefined(type) ? type : 4;
	self setOptionType(type, "editClassMenu", startIndex, range, target);
}

setCurrentOptions(targets, startIndex, range, type)
{
	menu = self getMenu();
	startIndex = isDefined(startIndex) ? startIndex : menu["startIndex"];
	range = isDefined(range) ? range : menu["range"];
	type = isDefined(type) ? type : 4;
	self setOptionsType(type, "editClassMenu", menu["startIndex"], menu["range"], targets);
}

setClassSplitDecoration()
{
	self setClientDvar("optionType2", 3);
	self setClientDvar("optionType4", 3);
	self setClientDvar("optionType7", 3);
	self setClientDvar("optionType9", 3);
}

checkAttachCombos(attach1, startIndex, range)
{
	if(attach1 == "none") return;
	for(i = 0; i < range; i++)
	{
		attach = strclassTable(0, i + startIndex, 1);
		colIndex = tableLookupRowNum("mp/attachmentCombos.csv", 0, attach1);
		
		if (attach != attach1 && tableLookup( "mp/attachmentCombos.csv", 0, attach, colIndex) == "no")
			self setClientDvar("optionType" + i, 0);
	}
}

checkStreakCombos(streakType, streak1, streak2, startIndex, range)
{
	if(streak1 == "none") return;
	for(i = 0; i < range; i++)
	{
		streak = strclassTable(0, i + startIndex, 1);
		
		colIndex = tableLookupRowNum("mp/streaksCombos.csv", 0, streak1);				
		if (streak != streak1 && tableLookup( "mp/streaksCombos.csv", 0, streak, colIndex) == "no")
			self setClientDvar("optionType" + i, 0);
		
		if(streak2 == "none") return;
		
		colIndex = tableLookupRowNum("mp/streaksCombos.csv", 0, streak2);				
		if (streak != streak2 && tableLookup( "mp/streaksCombos.csv", 0, streak, colIndex) == "no")
			self setClientDvar("optionType" + i, 0);
	}
}

_getStreakType(type)
{
	streakType = isDefined(type) ? type : self getClassData("perks", 5);
	if (streakType == "streaktype_support") return "defenseStreaks";
	else if (streakType == "streaktype_specialist") return "specialistStreaks";
	else return "assaultStreaks";
}

strclassTable(c_target, value, c_result)
{
	return tableLookup("mp/editClassMenu.csv", c_target, value, c_result);
}

intclassTable(c_target, value, c_result)
{
	return int(tableLookup("mp/editClassMenu.csv", c_target, value, c_result));
}