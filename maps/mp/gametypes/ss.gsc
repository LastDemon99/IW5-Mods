/*
============================
|   Lethal Beats Team 	   |
============================
|Game : IW5				   |
|Mod : extra_gametypes     |
|Gametype : SharpShooter   |
|Creator : LastDemon99	   |
============================
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\_lb_utility;

main()
{
	setVoidLoadouts();
	loadWeaponData();
	
    maps\mp\gametypes\_globallogic::init();
    maps\mp\gametypes\_callbacksetup::SetupCallbacks();
    maps\mp\gametypes\_globallogic::SetupCallbacks();

    level.initializeMatchRules = ::initializeMatchRules;
	[[ level.initializeMatchRules ]]();
	level thread maps\mp\_utility::reInitializeMatchRulesOnMigration();
	
    level.onStartGameType = ::onStartGameType;
    level.getSpawnPoint = ::getSpawnPoint;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onPlayerDamage = ::onPlayerDamage;	
	replacefunc(maps\mp\bots\_bot::onPlayerDamage, ::onPlayerDamage);

    game["dialog"]["gametype"] = "freeforall";
}

initializeMatchRules()
{
    setdynamicdvar( "scr_" + level.gameType + "_timeLimit", 10);
	registerTimeLimitDvar(level.gameType, 10);
	
	setdynamicdvar( "scr_" + level.gameType + "_scorelimit", 1500);
	registerScoreLimitDvar(level.gameType, 1500);
	
	setdynamicdvar( "scr_" + level.gameType + "_numLives", 0);
	registerNumLivesDvar(level.gameType,  0);
	
	setdynamicdvar( "scr_player_maxhealth", 100);
	setdynamicdvar( "scr_player_healthregentime", 5);
	
	setdynamicdvar( "scr_" + level.gameType + "_winlimit", 1 );
    registerWinLimitDvar(level.gameType, 1 );
	
    setdynamicdvar( "scr_" + level.gameType + "_roundlimit", 1 );
    registerRoundLimitDvar(level.gameType, 1 );
	
    setdynamicdvar( "scr_" + level.gameType + "_halftime", 0 );
    registerHalfTimeDvar(level.gameType, 0 );
	
    setdynamicdvar( "scr_" + level.gameType + "_promode", 0 );
	registerNumLivesDvar(level.gameType, 0 );	
	
	setdynamicdvar( "scr_" + level.gameType + "_playerrespawndelay", 0);
	setdynamicdvar( "scr_" + level.gameType + "_waverespawndelay", 0);
	
	setdynamicdvar( "scr_game_spectatetype", 2);
	setdynamicdvar( "scr_game_allowkillcam", 1);
	setdynamicdvar( "scr_game_forceuav", 0);
	setdynamicdvar( "scr_game_hardpoints",0);
	setdynamicdvar( "scr_game_perks", 0);
	setdynamicdvar( "scr_game_onlyheadshots",0);
	
	setdynamicdvar( "scr_thirdPerson", 0);
	setdynamicdvar( "scr_player_forcerespawn", 1);
	setdynamicdvar( "camera_thirdPerson", 0);
	setdynamicdvar( "g_hardcore", 0);
	
	SetDvarIfUninitialized("scr_ss_fastswitch", 0);
	SetDvarIfUninitialized("scr_ss_cicle_time", 30);
	SetDvarIfUninitialized("scr_ss_attachs", 1);
	SetDvarIfUninitialized("scr_ss_camos", 1);
	SetDvarIfUninitialized("scr_ss_killstreak", 0);
	SetDvarIfUninitialized("scr_ss_knife", 1);
	SetDvarIfUninitialized("scr_ss_credits", "Gamemode Developed by LastDemon99");
}

onStartGameType()
{
	setClientNameMode("auto_change");

	setObjectiveText( "allies", &"OBJECTIVES_DM" );
	setObjectiveText( "axis", &"OBJECTIVES_DM" );

	if ( level.splitscreen )
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_DM" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_DM" );
	}
	else
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_DM_SCORE" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_DM_SCORE" );
	}
	setObjectiveHintText( "allies", &"OBJECTIVES_DM_HINT" );
	setObjectiveHintText( "axis", &"OBJECTIVES_DM_HINT" );
	
	PreCacheShader("iw5_cardicon_skullguns");
			
	game["strings"]["axis_name"] = "SharpShooter";
	game["strings"]["allies_name"] = "SharpShooter";
	
	game["icons"]["axis"] = "iw5_cardicon_skullguns";
	game["icons"]["allies"] = "iw5_cardicon_skullguns";
	
    setObjectiveScoreText( "allies", &"OBJECTIVES_DM_SCORE" );
	setObjectiveScoreText( "axis", &"OBJECTIVES_DM_SCORE" );

    maps\mp\_utility::setObjectiveHintText( "allies", &"OBJECTIVES_DM_HINT" );
    maps\mp\_utility::setObjectiveHintText( "axis", &"OBJECTIVES_DM_HINT" );
    
	level.spawnMins = ( 0, 0, 0 );
    level.spawnMaxs = ( 0, 0, 0 );
	
    maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
    maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );
	
    level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
    
	setmapcenter( level.mapCenter );
	
    allowed[0] = "dm";
    maps\mp\gametypes\_gameobjects::main( allowed );
	
	clearScoreInfo();
	maps\mp\gametypes\_rank::registerScoreInfo( "normal_kill", 25);
	maps\mp\gametypes\_rank::registerScoreInfo( "weapon_kill", 50);
	maps\mp\gametypes\_rank::registerScoreInfo( "knife_kill", -100);
	
	level.modeKillstreak = ["none", "specialty_fastreload", "specialty_longersprint", "specialty_bulletaccuracy", "all_perks"];
	level.modeKillstreakSplash = ["none", "specialty_fastreload_ks", "specialty_longersprint_ks", "specialty_bulletaccuracy_ks", "all_perks_bonus"];
	
	level.QuickMessageToAll = true;	
	level.teamBased = 0;
	level.killstreakRewards = 0;
	level.blockWeaponDrops = 1;
	level.hasInfinteAmmo = 1;
	
	level thread onPlayerConnect();
	level thread hudInit();	
	setGun();
}

onPlayerConnect()
{
	level endon("game_ended");
	
	for (;;)
	{
		level waittill("connected", player);
		
		player thread refillAmmo();
		player thread refillSingleCountAmmo();
		player thread stingerFire();
		player thread onSpawnPlayer();
	}
}

onSpawnPlayer()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("spawned_player");
		
		self.isSpawned = 1;		
		self giveGun();
		self openMenu("perk_hide");		
		self.killstreak = 0;
		if(!getdvarint("scr_ss_killstreak")) self thread giveModeAllPerks(true);
	}
}

setGun()
{
	weapon = getRandomWeapon();
	attachs = getdvarint("scr_ss_attachs") ? getRandomAttachs(weapon) : ["none", "none"];
	camo = getdvarint("scr_ss_camos") ? int(tableLookup( "mp/camoTable.csv", 1, getRandomCamo(weapon), 0 )) : "none";
	level.ss_currentWeapon = self maps\mp\gametypes\_class::buildWeaponName( weapon, attachs[0], attachs[1], camo, 0);
	
	playSoundOnPlayers("mp_killconfirm_tags_pickup");
}

hudInit()
{
	level endon("game_ended");
	
	level.ssHud = _createHudText("Next Weapon: ", "small", 1.6, "TOP LEFT", "TOP LEFT", 115, 5);
	level.ssTimer = _createHudText("0:" + getDvarInt("scr_ss_cicle_time"), "small", 1.6, "TOP LEFT", "TOP LEFT", 115, 22);
	
	level waittill("prematch_over");
	
	level thread timerInit();
	level thread hudHideOnGameEnd();
}

timerInit()
{
	level endon("game_ended");
	
	for(;;)
	{
		level.ssTimer destroy();
		level.ssTimer = _createTimer(getDvarInt("scr_ss_cicle_time"), "small", 1.6, "TOP LEFT", "TOP LEFT", 115, 22);
		
		wait(getDvarInt("scr_ss_cicle_time"));
		setGun();
		
		foreach(player in level.players)
			player giveGun();
	}
}

hudHideOnGameEnd()
{
	level waittill("game_ended");
	
    level.ssHud.alpha = 0;
    level.ssTimer.alpha = 0;
}

giveGun()
{
	if(!isAlive(self)) return;
	
	self takeAllWeapons();
	self _giveWeapon(level.ss_currentWeapon);
	self.primaryWeapon = level.ss_currentWeapon;
	self.pers["primaryWeapon"] = level.ss_currentWeapon;
	
	if(getdvarint("scr_ss_fastswitch") || self.isSpawned)
		self setSpawnWeapon(level.ss_currentWeapon);
	else
		self switchToWeaponImmediate(level.ss_currentWeapon);
	
	self thread splashWeapon(level.ss_currentWeapon);
	self.isSpawned = 0;
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, lifeId)
{
	if(attacker == self || !isPlayer(attacker)) return;
	
	if (sMeansOfDeath == "MOD_MELEE" && sWeapon != "riotshield_mp")
	{
		attacker thread maps\mp\gametypes\_rank::giveRankXP("knife_kill");
	    maps\mp\gametypes\_gamescore::givePlayerScore("knife_kill", attacker, self, 1, 1 );
	}
	else if (sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_HEAD_SHOT" || sMeansOfDeath == "MOD_PROJECTILE" || sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_GRENADE" || sMeansOfDeath == "MOD_GRENADE_SPLASH" || sMeansOfDeath == "MOD_MELEE" && sWeapon == "riotshield_mp")
	{
		attacker thread maps\mp\gametypes\_rank::giveRankXP("weapon_kill");
		maps\mp\gametypes\_gamescore::givePlayerScore("weapon_kill", attacker, self, 1, 1 );
		
		attacker.killstreak++;
		attacker onKillStreakMode();
	}
	else
	{
		attacker thread maps\mp\gametypes\_rank::giveRankXP("normal_kill");
		maps\mp\gametypes\_gamescore::givePlayerScore("normal_kill", attacker, self, 1, 1 );
	}
}

onPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if(sMeansOfDeath == "MOD_MELEE" && !getdvarint("scr_ss_knife"))
	{
		eAttacker maps\mp\gametypes\_damagefeedback::updateDamageFeedback("");
		if (!(eAttacker is_bot())) eAttacker iPrintLnBold("Knife is not allowed");
		return;
	}
	
	if (self is_bot())
	{
		self maps\mp\bots\_bot_internal::onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
		self maps\mp\bots\_bot_script::onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
	}

	self [[level.prevCallbackPlayerDamage]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
}

getSpawnPoint()
{
	if (self isFirstSpawn())
    {
		self.pers["gamemodeLoadout"] = level.mode_loadouts[self.pers["team"]];
		
        self.pers["class"] = "gamemode";
        self.pers["lastClass"] = "";
        self.class = self.pers["class"];
        self.lastClass = self.pers["lastClass"];

        if ( common_scripts\utility::cointoss() )
            maps\mp\gametypes\_menus::addToTeam( "axis", 1 );
        else
            maps\mp\gametypes\_menus::addToTeam( "allies", 1 );
    }
	
    spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
    spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );    
	return spawnPoint;
}
