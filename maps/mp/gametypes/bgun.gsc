/*
============================
|   Lethal Beats Team 	   |
============================
|Game : IW5				   |
|Mod : extra_gametypes     |
|Gametype : Gun Game       |
|Creator : LastDemon99	   |
============================
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\_lb_utility;

main()
{
	PreCacheItem("iw5_knife_mp");
	PreCacheItem("at4_mp");
	
	setVoidLoadouts();
	loadWeaponData();
	setGuns();
	
    maps\mp\gametypes\_globallogic::init();
    maps\mp\gametypes\_callbacksetup::SetupCallbacks();
    maps\mp\gametypes\_globallogic::SetupCallbacks();
	
    level.initializeMatchRules = ::initializeMatchRules;
	[[ level.initializeMatchRules ]]();
	
    level.onStartGameType = ::onStartGameType;
    level.getSpawnPoint = ::getSpawnPoint;
    level.onPlayerKilled = ::onPlayerKilled;
    level.onTimeLimit = ::onTimeLimit;
	
	game["dialog"]["gametype"] = "freeforall";
}

initializeMatchRules()
{
	setdynamicdvar( "scr_" + level.gameType + "_timeLimit", 0);
	registerTimeLimitDvar(level.gameType, 0);
	
	setdynamicdvar( "scr_" + level.gameType + "_scorelimit", level.gun_guns.size);
	registerScoreLimitDvar(level.gameType, level.gun_guns.size);
	
	setdynamicdvar( "scr_" + level.gameType + "_roundswitch", 0);
	
	setdynamicdvar( "scr_" + level.gameType + "_numLives", 0);
	registerNumLivesDvar(level.gameType,  0);
	
	setdynamicdvar( "scr_" + level.gameType + "_winlimit", 1);
    registerWinLimitDvar(level.gameType, 1);
	
    setdynamicdvar( "scr_" + level.gameType + "_roundlimit", 1);
    registerRoundLimitDvar(level.gameType, 1 );
	
    setdynamicdvar( "scr_" + level.gameType + "_halftime", 0);
    registerHalfTimeDvar(level.gameType, 0 );
	
    setdynamicdvar( "scr_" + level.gameType + "_promode", 0);
	registerNumLivesDvar(level.gameType, 0);
	
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
	
	setdvar("disable_challenges", 1);
	
	SetDvarIfUninitialized("scr_bgun_fastswitch", 0);
	SetDvarIfUninitialized("scr_bgun_attachs", 1);
	SetDvarIfUninitialized("scr_bgun_camos", 1);
	SetDvarIfUninitialized("scr_bgun_killstreak", 0);
	SetDvarIfUninitialized("scr_bgun_credits", "Gamemode Developed by LastDemon99");
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
	
	PreCacheShader("iw5_cardicon_gunstar");
	
	game["strings"]["axis_name"] = "Gun Game";
	game["strings"]["allies_name"] = "Gun Game";
	
	game["icons"]["axis"] = "iw5_cardicon_gunstar";
	game["icons"]["allies"] = "iw5_cardicon_gunstar";
    
	level.spawnMins = ( 0, 0, 0 );
    level.spawnMaxs = ( 0, 0, 0 );
    
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
    maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );
    
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
    setmapcenter( level.mapCenter );
	
	allowed = [];  
	maps\mp\gametypes\_gameobjects::main( allowed );
	
	level.QuickMessageToAll = 1;
	level.blockWeaponDrops = 1;
	level.killstreakRewards = 0;
	level.teamBased = 0;
	level.hasInfinteAmmo = 1;
    
	clearScoreInfo();
    maps\mp\gametypes\_rank::registerScoreInfo( "gained_gun_score", 1 );
    maps\mp\gametypes\_rank::registerScoreInfo( "dropped_gun_score", -1 );
    maps\mp\gametypes\_rank::registerScoreInfo( "gained_gun_rank", 100 );
    maps\mp\gametypes\_rank::registerScoreInfo( "dropped_enemy_gun_rank", 100 );
	
	level.modeKillstreak = ["none", "specialty_fastreload", "specialty_lightweight", "specialty_reducedsway", "all_perks"];
	level.modeKillstreakSplash = ["none", "specialty_fastreload_ks", "specialty_longersprint_ks", "specialty_bulletaccuracy_ks", "all_perks_bonus"];
		
	level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  player  );
		
		player.gunGameGunIndex = 0;
        player.gunGamePrevGunIndex = 0;
        player initGunHUD();
		
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
		
		self giveNextGun();
		self openMenu("perk_hide");
		self thread giveModeAllPerks(true);
	}
}

onTimeLimit()
{
    level.finalKillCam_winner = "none";
    winners = getHighestProgressedPlayers();

    if ( !isdefined( winners ) || !winners.size )
        thread maps\mp\gametypes\_gamelogic::endGame( "tie", game["strings"]["time_limit_reached"] );
    else if ( winners.size == 1 )
        thread maps\mp\gametypes\_gamelogic::endGame( winners[0], game["strings"]["time_limit_reached"] );
    else if ( winners[winners.size - 1].gunGameGunIndex > winners[winners.size - 2].gunGameGunIndex )
        thread maps\mp\gametypes\_gamelogic::endGame( winners[winners.size - 1], game["strings"]["time_limit_reached"] );
    else
        thread maps\mp\gametypes\_gamelogic::endGame( "tie", game["strings"]["time_limit_reached"] );
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, lifeId)
{
	if(sWeapon == "iw5_knife_mp")
	{
		attacker.gunGamePrevGunIndex = attacker.gunGameGunIndex;
		attacker.gunGameGunIndex++;
		attacker thread maps\mp\gametypes\_rank::giveRankXP( "gained_gun_rank" );
		maps\mp\gametypes\_gamescore::givePlayerScore( "gained_gun_score", attacker, self, 1, 1 );
		return;
	}	
	
    if ( sMeansOfDeath == "MOD_FALLING" || isdefined( attacker ) && isplayer( attacker ) )
    {
        if ( sMeansOfDeath == "MOD_FALLING" || attacker == self || sMeansOfDeath == "MOD_MELEE" && sWeapon != "riotshield_mp")
        {
            self playlocalsound( "mp_war_objective_lost" );
            self.gunGamePrevGunIndex = self.gunGameGunIndex;
            self.gunGameGunIndex = int( max( 0, self.gunGameGunIndex - 1 ) );

            if ( self.gunGamePrevGunIndex > self.gunGameGunIndex )
                maps\mp\gametypes\_gamescore::givePlayerScore( "dropped_gun_score", self, undefined, 1, 1 );

            if ( sMeansOfDeath == "MOD_MELEE" )
            {
                if ( self.gunGamePrevGunIndex )
                {
                    attacker thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_DROPPED_ENEMY_GUN_RANK" );
                    attacker thread maps\mp\gametypes\_rank::giveRankXP( "dropped_enemy_gun_rank" );
                }
            }
        }
        else if ( sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_HEAD_SHOT" || sMeansOfDeath == "MOD_PROJECTILE" || sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_GRENADE" || sMeansOfDeath == "MOD_GRENADE_SPLASH" || sMeansOfDeath == "MOD_MELEE" && sWeapon == "riotshield_mp")
        {			
            if ( sWeapon != attacker.primaryWeapon && sWeapon != "alt_" + attacker.primaryWeapon)
                return;

            attacker.gunGamePrevGunIndex = attacker.gunGameGunIndex;
            attacker.gunGameGunIndex++;
            attacker thread maps\mp\gametypes\_rank::giveRankXP( "gained_gun_rank" );
            maps\mp\gametypes\_gamescore::givePlayerScore( "gained_gun_score", attacker, self, 1, 1 );

            if ( attacker.gunGameGunIndex == level.gun_guns.size - 1 )
            {
                playSoundOnPlayers( "mp_enemy_obj_captured" );
                level thread teamPlayerCardSplash( "callout_top_gun_rank", attacker );
            }

            if ( attacker.gunGameGunIndex < level.gun_guns.size )
            {
                attacker playlocalsound( "mp_war_objective_taken" );
                attacker giveNextGun();
				attacker giveModeAllPerks(false);
            }
        }
    }
}

initGunHUD()
{
    self.gun_progressDisplay[0] = _createHudText(&"MP_WEAPON", "small", 1.2, "TOP LEFT", "TOP LEFT", 115, 5, self);
	self.gun_progressDisplay[1] = _createHudText("1 / " + level.gun_guns.size, "small", 1.2, "TOP LEFT", "TOP LEFT", 115, 17, self);

    thread hideOnGameEnd();
    thread hideinkillcam();
}

updateGunHUD()
{
    self.gun_progressDisplay[1] settext( self.gunGameGunIndex + 1 + " / " + level.gun_guns.size );
}

hideinkillcam()
{
    self endon( "disconnect" );
    visible = 1;

    for (;;)
    {
        if ( visible && ( !isalive( self ) || isInKillcam() ) )
        {
            self.gun_progressDisplay[0].alpha = 0;
            self.gun_progressDisplay[1].alpha = 0;
            visible = 0;
        }
        else if ( !visible && ( isalive( self ) && !isInKillcam() ) )
        {
            self.gun_progressDisplay[0].alpha = 1;
            self.gun_progressDisplay[1].alpha = 1;
            visible = 1;
        }
        wait 0.05;
    }
}

hideOnGameEnd()
{
    self endon( "disconnect" );
    level waittill( "game_ended" );
    
	self.gun_progressDisplay[0].alpha = 0;
    self.gun_progressDisplay[1].alpha = 0;
}

setGuns()
{
    level.gun_guns = [];
	level.gun_attachs = [];
	level.gun_camo = [];
	
	foreach(wepClass in listRandomizer(["assault", "smg", "lmg", "sniper", "shotgun", "riot", "machine_pistol", "pistol", "projectile"]))
	{
		foreach(weapon in listRandomizer(level.weapons[wepClass]["name"]))
		{
			level.gun_guns[level.gun_guns.size] = weapon;
			level.gun_attachs[level.gun_attachs.size] = getdvarint("scr_bgun_attachs") ? getRandomAttachs(weapon) : ["none", "none"];
			level.gun_camo[level.gun_camo.size] = getdvarint("scr_bgun_camos") ? int(tableLookup( "mp/camoTable.csv", 1, getRandomCamo(weapon), 0 )) : "none";
		}
	}	
	level.gun_guns[level.gun_guns.size] = "knife";
}

giveNextGun()
{
	if (level.gun_guns[self.gunGameGunIndex] != "knife")
	{
		newWeapon = level.gun_guns[self.gunGameGunIndex];
		attachs = level.gun_attachs[self.gunGameGunIndex];
		camo = level.gun_camo[self.gunGameGunIndex];		
		weapon = self maps\mp\gametypes\_class::buildWeaponName( newWeapon, attachs[0], attachs[1], camo, 0);
	}
	else
	{
		newWeapon = "KNIFE";
		weapon = "iw5_knife_mp";
	}
	
	self takeAllWeapons();
	self _giveWeapon(weapon);
	self.primaryWeapon = weapon;
	self.pers["primaryWeapon"] = weapon;
	
	if(getdvarint("scr_bgun_fastswitch") || !self.pers["cur_kill_streak"])
		self setSpawnWeapon(weapon);
	else
		self switchToWeaponImmediate(weapon);
	
	if(!self.pers["cur_kill_streak"])
		splashWeapon(newWeapon);
	else
		self thread splashEventPopup(newWeapon);	
	
	self thread giveModeAllPerks(false);
    self.gunGamePrevGunIndex = self.gunGameGunIndex;
    updateGunHUD();
}

splashEventPopup(weapon)
{
	if ( self.gunGamePrevGunIndex > self.gunGameGunIndex ) thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_DROPPED_GUN_RANK" );
    else if ( self.gunGamePrevGunIndex < self.gunGameGunIndex ) thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_GAINED_GUN_RANK" );
	
	wait(0.5);
	splashWeapon(weapon);
}

getHighestProgressedPlayers()
{
    highestProgress = -1;
    highestProgressedPlayers = [];

    foreach ( player in level.players )
    {
        if ( isdefined( player.gunGameGunIndex ) && player.gunGameGunIndex >= highestProgress )
        {
            highestProgress = player.gunGameGunIndex;
            highestProgressedPlayers[highestProgressedPlayers.size] = player;
        }
    }

    return highestProgressedPlayers;
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
