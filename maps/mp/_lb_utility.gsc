#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

serverHasBots()
{
	return isDefined(game["botWarfare"]);
}

is_bot()
{
	assert( isDefined( self ) );
	assert( isPlayer( self ) );

	return ( ( isDefined( self.pers["isBot"] ) && self.pers["isBot"] ) || ( isDefined( self.pers["isBotWarfare"] ) && self.pers["isBotWarfare"] ) || isSubStr( self getguid() + "", "bot" ) );
}

hasBot()
{
	return isDefined(game["botWarfare"]);
}

splashWeapon(weapon)
{
	if(self isFirstSpawn()) return;
	self maps\mp\gametypes\_rank::xpEventPopup(getWeaponBaseName(weapon));
}

splashInfo()
{
	notifyData = spawnStruct();
	notifyData.titleText = level.modeTittle;
	notifyData.notifyText = "Free for all";
	notifyData.glowColor = level.modeTittleColor;
	//notifyData.sound = "mp_challenge_complete";
	
	self maps\mp\gametypes\_hud_message::notifyMessage(notifyData);
	wait(4.8);
	self maps\mp\gametypes\_rank::xpEventPopup(getWeaponBaseName(level.ss_currentWeapon));
}

refillAmmo()
{
    level endon( "game_ended" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill("reload");
		
		if(isInfect(self)) break;
		
		currWep = self getCurrentWeapon();
		
		if(currWep == "riotshield_mp" || !isDefined(currWep)) continue;		
		self giveMaxAmmo(currWep);
    }
}

refillSingleCountAmmo()
{
    level endon( "game_ended" );
    self endon( "disconnect" );

    for (;;)
    {
		wait 0.3;
		if(isInfect(self)) break;
		
		currWep = self getCurrentWeapon();
		if(currWep == "riotshield_mp" || !isDefined(currWep))
			continue;
		
        if (isAlive(self) && self getammocount(currWep) == 0)
			self notify("reload");
	}
}

refillNades()
{
	self endon("disconnect");
	level endon( "game_ended" );
	
	for (;;)
    {
		self waittill("grenade_fire", grenade, weaponName);
		
		if(isInfect(self)) break;
		
		if(contains(weaponName, level.weapons["lethal"]))
		{
			if(weaponName != "c4_mp") wait(1);
			else wait(3);
		}
		else if(contains(weaponName, level.weapons["tactical"])) wait(4);
		
		if(weaponName == "scrambler_mp") self thread maps\mp\gametypes\_scrambler::setScrambler();
		else if (weaponName == "portable_radar_mp") self thread maps\mp\gametypes\_portable_radar::setPortableRadar();
		else if (weaponName == "flare_mp") self maps\mp\perks\_perkfunctions::setTacticalInsertion();
		else self giveStartAmmo(weaponName);
		
		self playLocalSound("scavenger_pack_pickup");
	}
}

stingerFire()
{
	level endon("game_ended");
	self endon("disconnect");
	
	self notifyOnPlayerCommand("attack", "+attack");
	
	for(;;)
	{
		if (self is_bot()) wait(1);
		else self waittill("attack");
		
		if (self getCurrentWeapon() == "stinger_mp" && self playerAds() >= 1)
			if (self getWeaponAmmoClip(self getCurrentWeapon()) != 0)
			{
				vector = anglesToForward(self getPlayerAngles());
				dsa = (vector[0] * 1000000, vector[1] * 1000000, vector[2] * 1000000);
				magicBullet("stinger_mp", self getTagOrigin("tag_weapon_left"), dsa, self);
				self setWeaponAmmoClip("stinger_mp", 0);
			}
			
		wait(0.3);
	}
}

giveModeAllPerks(splashPerks)
{
	if(self is_bot()) return;
	
	perks = [ "specialty_longersprint",
				"specialty_fastreload",
				"specialty_blindeye",
				"specialty_paint",
				"specialty_coldblooded",
				"specialty_quickdraw",				
				"specialty_autospot",
				"specialty_bulletaccuracy",
				"specialty_quieter",
				"specialty_stalker",
				"specialty_bulletpenetration",
				"specialty_marksman",
				"specialty_sharp_focus",
				"specialty_longerrange",
				"specialty_fastermelee",
				"specialty_reducedsway",
				"specialty_lightweight"];
				
	if(level.hasInfinteAmmo == 0)
		perks[perks.size] = "specialty_scavenger";
			
	foreach(perk in perks)
		if(!self _hasPerk(perk))
		{
			self givePerk(perk, false);
			if(maps\mp\gametypes\_class::isPerkUpgraded(perk))
			{
				perkUpgrade = tablelookup( "mp/perktable.csv", 1, perk, 8);
				self givePerk(perkUpgrade, false);
			}
		}
	
	if (splashPerks) self splashAllPerks();
}

splashAllPerks()
{
	if(self isFirstSpawn()) wait(4.8);
	self maps\mp\gametypes\_hud_message::killstreakSplashNotify("all_perks_bonus");
}

_giveUpgradePerk(perk)
{
	self givePerk(perk, false);
	if(maps\mp\gametypes\_class::isPerkUpgraded(perk))
	{
		perkUpgrade = tablelookup( "mp/perktable.csv", 1, perk, 8);
		self givePerk(perkUpgrade, false);
	}
}

isInfect(player)
{
	return getDvar("g_gametype") == "infect" && player.sessionTeam == "axis";
}

loadWeaponData()
{
	level.weapons = [];
	level.weapons["assault"]["name"] = ["iw5_m4", "iw5_ak47", "iw5_m16", "iw5_fad", "iw5_acr", "iw5_type95", "iw5_mk14", "iw5_scar", "iw5_g36c", "iw5_cm901"];
	level.weapons["smg"]["name"] = ["iw5_mp7", "iw5_m9", "iw5_p90", "iw5_pp90m1", "iw5_ump45", "iw5_mp5", "iw5_ak74u"];	
	level.weapons["lmg"]["name"] = ["iw5_m60", "iw5_mk46", "iw5_pecheneg", "iw5_sa80", "iw5_mg36"];
	level.weapons["sniper"]["name"] = ["iw5_barrett", "iw5_rsass", "iw5_dragunov", "iw5_msr", "iw5_l96a1", "iw5_as50", "iw5_cheytac"];
	level.weapons["shotgun"]["name"] = ["iw5_ksg", "iw5_1887", "iw5_striker", "iw5_aa12", "iw5_usas12", "iw5_spas12"];
	level.weapons["riot"]["name"] = ["riotshield"];	
	
	level.weapons["machine_pistol"]["name"] = ["iw5_g18", "iw5_fmg9", "iw5_mp9", "iw5_skorpion"];
	level.weapons["pistol"]["name"] = ["iw5_44magnum", "iw5_usp45", "iw5_deserteagle", "iw5_mp412", "iw5_p99", "iw5_fnfiveseven"];
	level.weapons["projectile"]["name"] = ["m320", "rpg", "iw5_smaw", "stinger", "xm25", "javelin", "at4"];
	
	level.weapons["frag"] = ["frag_grenade_mp"];	
	level.weapons["other"] = ["semtex_mp", "bouncingbetty_mp", "claymore_mp", "c4_mp"];
	level.weapons["throwingknife"] = ["throwingknife_mp"];	
	level.weapons["flash"] = ["flash_grenade_mp", "scrambler_mp", "emp_grenade_mp", "trophy_mp", "flare_mp", "portable_radar_mp"];
	level.weapons["smoke"] = ["concussion_grenade_mp", "smoke_grenade_mp"];
	
	level.weapons["primary"] = arrayUnion([level.weapons["assault"]["name"], level.weapons["smg"]["name"], level.weapons["lmg"]["name"], level.weapons["sniper"]["name"], level.weapons["shotgun"]["name"], level.weapons["riot"]["name"]]);
	level.weapons["secondary"] = arrayUnion([level.weapons["machine_pistol"]["name"], level.weapons["pistol"]["name"], level.weapons["projectile"]["name"]]);
	level.weapons["lethal"] = arrayUnion([level.weapons["frag"], level.weapons["other"], level.weapons["throwingknife"]]);
	level.weapons["tactical"] = arrayUnion([level.weapons["flash"], level.weapons["smoke"]]);
	level.weapons["equipment"] = arrayUnion([level.weapons["lethal"], level.weapons["tactical"]]);
	
	level.weapons["assault"]["silencer"] = "silencer";
	level.weapons["assault"]["sight"] = ["reflex", "acog", "eotech", "hybrid", "thermal"];
	level.weapons["assault"]["extraAttach"] = [ "heartbeat", "shotgun", "xmags"];
	level.weapons["assault"]["buff"] = [ "specialty_marksman", "specialty_bulletpenetration", "specialty_bling", "specialty_sharp_focus", "specialty_holdbreathwhileads", "specialty_reducedsway"];
	
	level.weapons["smg"]["silencer"] = "silencer";
	level.weapons["smg"]["sight"] = ["reflexsmg", "acogsmg", "eotechsmg", "hamrhybrid", "thermalsmg"];
	level.weapons["smg"]["extraAttach"] = [ "xmags", "rof"];
	level.weapons["smg"]["buff"] = [ "specialty_marksman", "specialty_longerrange", "specialty_bling", "specialty_sharp_focus", "specialty_fastermelee", "specialty_reducedsway"];
	
	level.weapons["lmg"]["silencer"] = "silencer";
	level.weapons["lmg"]["sight"] = ["acog", "reflexlmg", "eotechlmg", "thermal"];
	level.weapons["lmg"]["extraAttach"] = [ "heartbeat", "xmags", "grip", "rof"];
	level.weapons["lmg"]["buff"] = [ "specialty_marksman", "specialty_bulletpenetration", "specialty_bling", "specialty_sharp_focus", "specialty_lightweight", "specialty_reducedsway"];
	
	level.weapons["sniper"]["silencer"] = "silencer03";
	level.weapons["sniper"]["sight"] = ["acog", "thermal"]; 
	level.weapons["sniper"]["extraAttach"] = [ "heartbeat", "xmags"];	
	level.weapons["sniper"]["buff"] = [ "specialty_marksman", "specialty_bulletpenetration", "specialty_bling", "specialty_sharp_focus", "specialty_lightweight", "specialty_reducedsway"];
	
	level.weapons["shotgun"]["silencer"] = "silencer03";
	level.weapons["shotgun"]["sight"] = ["reflex", "eotech"];
	level.weapons["shotgun"]["extraAttach"] = [ "xmags", "grip"];
	level.weapons["shotgun"]["buff"] = [ "specialty_marksman", "specialty_sharp_focus", "specialty_bling", "specialty_fastermelee", "specialty_moredamage"];
	
	level.weapons["riot"]["buff"] = ["specialty_fastermelee", "specialty_lightweight"];
	
	level.weapons["machine_pistol"]["silencer"] = "silencer02";
	level.weapons["machine_pistol"]["sight"] = ["reflexsmg"];
	level.weapons["machine_pistol"]["extraAttach"] = [ "xmags", "akimbo"];
	
	level.weapons["pistol"]["silencer"] = "silencer02";
	level.weapons["pistol"]["extraAttach"] = [ "xmags", "akimbo", "tactical"];
	
	level.weapons["specialAttach"] = [];
	level.weapons["specialAttach"]["m320"] = ["iw5_acr", "iw5_type95", "iw5_g36c", "iw5_scar", "iw5_fad", "iw5_cm901"];	
	level.weapons["specialAttach"]["rof"] = ["iw5_type95", "iw5_m16", "iw5_mk14"];
	level.weapons["specialAttach"]["gl"] = ["iw5_m4", "iw5_m16"];
	level.weapons["specialAttach"]["gp25"] = ["iw5_ak47"];
	
	level.weapons["camos"] = ["none", "classic", "snow", "multi", "d_urban", "hex", "choco", "marine", "snake", "winter", "blue", "red", "autumn", "gold"];
}

clearScoreInfo()
{
	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 0 );
    maps\mp\gametypes\_rank::registerScoreInfo( "assist", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "execution", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "avenger", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "defender", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "posthumous", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "revenge", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "double", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "triple", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "multi", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "buzzkill", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "firstblood", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "comeback", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "longshot", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "assistedsuicide", 0);
    maps\mp\gametypes\_rank::registerScoreInfo( "knifethrow", 0 );
}

getRandomWeapon(wepClass)
{
	if(!isDefined(wepClass))
		weapons = listRandomizer(arrayUnion([level.weapons["primary"], level.weapons["secondary"]]));
	else
	{
		if(!isDefined(level.weapons[wepClass]["name"])) weapons = listRandomizer(level.weapons[wepClass]);
		else weapons = listRandomizer(level.weapons[wepClass]["name"]);
	}

	return weapons[randomInt(weapons.size)];
}

getRandomAttachs(weapon)
{
	attachs = [];
	
	if(weapon == "iw5_1887") 
		return ["none", "none"];
	
	if (randomInt(2)) 
		attachs[attachs.size] = getSilencer(weapon);
		
	if (randomInt(2)) 
		attachs[attachs.size] = getRandomSight(weapon);
	
	//if (attachs.size != 2 && randomInt(2)) 
		//attachs[attachs.size] = getRandomExtraAttach(weapon, contains("hybrid", attachs));

	if(!isdefined(attachs[0])) attachs[0] = "none";	
	if(!isdefined(attachs[1])) attachs[1] = "none";	
	return attachs;
}

getSilencer(weapon)
{
	if(weapon == "iw5_44magnum" || weapon == "iw5_mp412") 
		return "none";
	
	wepClass = getsubstr(_getWeaponClass(weapon), 7);	
	if(isDefined(level.weapons[wepClass]["silencer"])) return level.weapons[wepClass]["silencer"];
	return "none";
}

getRandomSight(weapon)
{
	wepClass = getsubstr(_getWeaponClass(weapon), 7);
	attach = "none";
	
	if(isDefined(level.weapons[wepClass]["sight"]))
	{
		attach = level.weapons[wepClass]["sight"][randomInt(level.weapons[wepClass]["sight"].size)];
		
		if(weapon == "iw5_ak74u" && attach == "hamrhybrid") 
			return "none";
	}	
	return attach;
}

getRandomExtraAttach(weapon, hasHybridSight)
{
	wepClass = getsubstr(_getWeaponClass(weapon), 7);
	
	if(isDefined(level.weapons[wepClass]["extraAttach"]))
	{
		attachs = level.weapons[wepClass]["extraAttach"];
		
		if(!hasHybridSight)
			foreach(attach in ["m320", "rof", "gl", "gp25"])
				if(contains(weapon, level.weapons["specialAttach"][attach])) 
					attachs[attachs.size] = attach;
				
		return attachs[randomInt(attachs.size)];
	}
	return "none";
}

getRandomCamo(weapon)
{
	if(weapon == "riotshield") return "none";
	if(contains(weapon, level.weapons["primary"])) return level.weapons["camos"][randomIntRange(1, level.weapons["camos"].size)];
	else return "none";
}

getEquipmentClass(nade)
{
	target = "specialty_null";
	foreach(nadeClass in ["frag", "other", "throwingknife", "flash", "smoke"])
		if(contains(nade, level.weapons[nadeClass]))
		{
			target = nadeClass;
			break;
		}
	return target;
}

getWeaponBaseName(weapon)
{
	if(weapon == "iw5_knife_mp") return "KNIFE";
	
	weaponBaseName = "";
	weaponName = "";
	
	for(weaponId = 0; weaponId <= 149; weaponId++)
	{
		weaponBaseName = tablelookup( "mp/statstable.csv", 0, weaponId, 4);
		weaponName = tablelookup( "mp/statstable.csv", 0, weaponId, 3);
		
		if(weapon == weaponBaseName) break;
	}
	
	wep = getsubstr(weaponName, 7);	
	if(tolower(wep) == "cheytac") wep = "INTERVENTION";
	
	return wep;
}

_getWeaponClass( weapon )
{
	if(weapon == "at4") return "weapon_projectile";	
	
	tokens = strTok( weapon, "_" );
	
	if ( tokens[0] == "iw5" )
	{
		concatName = tokens[0] + "_" + tokens[1];
		weaponClass = tablelookup( "mp/statstable.csv", 4, concatName, 2 );
	}
	else if ( tokens[0] == "alt" )
	{
		concatName = tokens[1] + "_" + tokens[2];
		weaponClass = tablelookup( "mp/statstable.csv", 4, concatName, 2 );
	}
	else
	{
		weaponClass = tablelookup( "mp/statstable.csv", 4, tokens[0], 2 );
	}
	
	if ( weaponClass == "" )
	{
		weaponName = strip_suffix( weapon, "_mp" );
		weaponClass = tablelookup( "mp/statstable.csv", 4, weaponName, 2 );
	}	
	return weaponClass;
}

_createTimer(time, font, size, align, relative, x, y, client)
{
	if(isdefined(client)) timer = client createTimer(font, size);
	else timer = createServerTimer(font, size);
	
	timer setpoint(align, relative, x, y);
	timer.alpha = 1;
	timer.hideWhenInMenu = true;
	timer.foreground = true;
	timer.archived = 0;
	timer setTimer(time);	
	return timer;
}

_createHudText(text, font, size, align, relative, x, y, client)
{
	if(isdefined(client)) hudText = client createFontString(font, size);
	else hudText = createServerFontString(font, size);
	
	hudText setpoint(align, relative, x, y);
	hudText setText(text); 
	hudText.alpha = 1;
	hudText.hideWhenInMenu = true;
	hudText.foreground = true;
	hudText.archived = 0;
	return hudText;
}

_createIcon(shader, icon_x, icon_y, align, relative, x, y)
{
	icon = createIcon( shader, icon_x, icon_y);
	icon setpoint(align, relative, x, y);
	icon.alpha = 1;
	icon.hideWhenInMenu = true;
	icon.foreground = true;
	icon.archived = 0;	
	return icon;
}

recordFinalKillCam( delay, victim, attacker, attackerNum, killCamEntityIndex, killCamEntityStartTime, sWeapon, deathTimeOffset, psOffsetTime )
{
	winner = maps\mp\gametypes\_gamescore::getHighestScoringPlayer();
	if(isdefined(winner) && attacker != winner) return; 
	
	// save this kill as the final kill cam so we can play it back when the match ends
	// we want to save each team seperately so we can show the winning team's kill when applicable
	if( level.teambased && IsDefined( attacker.team ) )
	{
		level.finalKillCam_delay[ attacker.team ]					= delay;
		level.finalKillCam_victim[ attacker.team ]					= victim;
		level.finalKillCam_attacker[ attacker.team ]				= attacker;
		level.finalKillCam_attackerNum[ attacker.team ]				= attackerNum;
		level.finalKillCam_killCamEntityIndex[ attacker.team ]		= killCamEntityIndex;
		level.finalKillCam_killCamEntityStartTime[ attacker.team ]	= killCamEntityStartTime;
		level.finalKillCam_sWeapon[ attacker.team ]					= sWeapon;
		level.finalKillCam_deathTimeOffset[ attacker.team ]			= deathTimeOffset;
		level.finalKillCam_psOffsetTime[ attacker.team ]			= psOffsetTime;
		level.finalKillCam_timeRecorded[ attacker.team ]			= getSecondsPassed();
		level.finalKillCam_timeGameEnded[ attacker.team ]			= getSecondsPassed(); // this gets set in endGame()
	}

	// none gets filled just in case we need something without a team or this is ffa
	level.finalKillCam_delay[ "none" ]					= delay;
	level.finalKillCam_victim[ "none" ]					= victim;
	level.finalKillCam_attacker[ "none" ]				= attacker;
	level.finalKillCam_attackerNum[ "none" ]			= attackerNum;
	level.finalKillCam_killCamEntityIndex[ "none" ]		= killCamEntityIndex;
	level.finalKillCam_killCamEntityStartTime[ "none" ]	= killCamEntityStartTime;
	level.finalKillCam_sWeapon[ "none" ]				= sWeapon;
	level.finalKillCam_deathTimeOffset[ "none" ]		= deathTimeOffset;
	level.finalKillCam_psOffsetTime[ "none" ]			= psOffsetTime;
	level.finalKillCam_timeRecorded[ "none" ]			= getSecondsPassed();
	level.finalKillCam_timeGameEnded[ "none" ]			= getSecondsPassed(); // this gets set in endGame()
}

onKillStreakMode()
{
	if(!getdvarint("scr_" + level.gameType +"_killstreak")) return;	
	if(self is_bot() || self.killstreak >= level.modeKillstreak.size) return;
	
	perk = level.modeKillstreak[self.killstreak];
		
	if(perk == "all_perks")
	{
		self giveModeAllPerks(false);
		self thread maps\mp\gametypes\_hud_message::killstreakSplashNotify("all_perks_bonus", self.killstreak);
	}
	else
	{
		self _giveUpgradePerk(perk);
		self thread maps\mp\gametypes\_hud_message::killstreakSplashNotify(level.modeKillstreakSplash[self.killstreak], self.killstreak, "pro");	
	}
}

updateKillStreakMode()
{
	if(!getdvarint("scr_" + level.gameType +"_killstreak")) self thread giveModeAllPerks(false);
	else
	{
		for(i = 1; i <= self.killstreak; i++)
		{
			if(i >= level.modeKillstreak.size) break;
			
			perk = level.modeKillstreak[i];
	
			if(perk == "all_perks") self thread giveModeAllPerks(false);
			else self _giveUpgradePerk(perk);
		}
	}
}

isSpecialist(streakName)
{
	return maps\mp\killstreaks\_killstreaks::isSpecialistKillstreak(streakName); 
}

setVoidLoadouts()
{
    level.mode_loadouts["allies"]["loadoutPrimary"] = "none";
    level.mode_loadouts["allies"]["loadoutPrimaryAttachment"] = "none";
    level.mode_loadouts["allies"]["loadoutPrimaryAttachment2"] = "none";
    level.mode_loadouts["allies"]["loadoutPrimaryBuff"] = "specialty_null";
    level.mode_loadouts["allies"]["loadoutPrimaryCamo"] = "none";
    level.mode_loadouts["allies"]["loadoutPrimaryReticle"] = "none";
    level.mode_loadouts["allies"]["loadoutSecondary"] = "none";
    level.mode_loadouts["allies"]["loadoutSecondaryAttachment"] = "none";
    level.mode_loadouts["allies"]["loadoutSecondaryAttachment2"] = "none";
    level.mode_loadouts["allies"]["loadoutSecondaryBuff"] = "specialty_null";
    level.mode_loadouts["allies"]["loadoutSecondaryCamo"] = "none";
    level.mode_loadouts["allies"]["loadoutSecondaryReticle"] = "none";
    level.mode_loadouts["allies"]["loadoutEquipment"] = "specialty_null";
    level.mode_loadouts["allies"]["loadoutOffhand"] = "none";
    level.mode_loadouts["allies"]["loadoutPerk1"] = "specialty_null";
    level.mode_loadouts["allies"]["loadoutPerk2"] = "specialty_null";
    level.mode_loadouts["allies"]["loadoutPerk3"] = "specialty_null";
	level.mode_loadouts["allies"]["loadoutKillstreak1"] = "none";
	level.mode_loadouts["allies"]["loadoutKillstreak2"] = "none";
	level.mode_loadouts["allies"]["loadoutKillstreak3"] = "none";
    level.mode_loadouts["allies"]["loadoutDeathstreak"] = "specialty_null";
    level.mode_loadouts["allies"]["loadoutJuggernaut"] = false;
	
	level.mode_loadouts["axis"] = level.mode_loadouts["allies"];
}

listRandomizer(list)
{
	newIndex = randomNum(list.size, 0, list.size);
	newlist = [];
	
	for (i = 0; i < newIndex.size; i++)
		newlist[i] = list[newIndex[i]];

	return newlist;
}

contains(item, data)
{
	_contains = false;
	foreach(i in data)
		if(item == i)
		{
			_contains = true;
			break;
		}
	return _contains;
}

arrayUnion(arrays)
{
	data = [];
	foreach(array in arrays)
		foreach(item in array)
			data[data.size] = item;
	return data;
}

randomNum(size, min, max)
{
	uniqueArray = [size];
	random = 0;

	for (i = 0; i < size; i++)
	{
		random = randomIntRange(min, max);
		for (j = i; j >= 0; j--)
			if (isDefined(uniqueArray[j]) && uniqueArray[j] == random)
			{
				random = randomIntRange(min, max);
				j = i;
			}
		uniqueArray[i] = random;
	}
	return uniqueArray;
}

giveLoadout(team, class, allowCopycat, setPrimarySpawnWeapon) 
{
	if(!isDefined(game["botWarfare"])) self maps\mp\gametypes\_class::giveLoadout(team, class, allowCopycat, setPrimarySpawnWeapon);
	else
	{
		if(self is_bot()) self maps\mp\bots\_bot_utility::botGiveLoadout(team, class, allowCopycat, setPrimarySpawnWeapon);
		else self maps\mp\gametypes\_class::giveLoadout(team, class, allowCopycat, setPrimarySpawnWeapon);
	}
}

statusDialog( dialog, team, forceDialog )
{
	time = getTime();
	
	if ( getTime() < level.lastStatus[team] + 5000 && (!isDefined( forceDialog ) || !forceDialog) )
		return;
		
	thread delayedLeaderDialog( dialog, team );
	level.lastStatus[team] = getTime();	
}
delayedLeaderDialog( sound, team )
{
	level endon ( "game_ended" );
	wait .1;
	WaitTillSlowProcessAllowed();
	
	leaderDialog( sound, team );
}
delayedLeaderDialogBothTeams( sound1, team1, sound2, team2 )
{
	level endon ( "game_ended" );
	wait .1;
	WaitTillSlowProcessAllowed();
	
	leaderDialogBothTeams( sound1, team1, sound2, team2 );
}

isFirstSpawn()
{
	return !gameFlag( "prematch_done" ) || !self.hasSpawned && game["state"] == "playing" && game["status"] != "overtime";
}

/*
SetDvarIfUninitialized("scr_game_killcam_highestScore", 0);
	if(getdvarint("scr_game_killcam_highestScore"))
		replacefunc(maps\mp\gametypes\_damage::recordFinalKillCam, ::recordFinalKillCam);
*/
