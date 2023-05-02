/*
============================
|   Lethal Beats Team 	   |
============================
|Game : IW5				   |
|Mod : extra_gametypes     |
|Gametype : Cranked        |
|Creator : LastDemon99	   |
============================
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\_lb_utility;

main()
{
    maps\mp\gametypes\_globallogic::init();
    maps\mp\gametypes\_callbacksetup::SetupCallbacks();
    maps\mp\gametypes\_globallogic::SetupCallbacks();

    level.initializeMatchRules = ::initializeMatchRules;
	[[ level.initializeMatchRules ]]();
	level thread maps\mp\_utility::reInitializeMatchRulesOnMigration();
	
    level.onStartGameType = ::onStartGameType;
    level.getSpawnPoint = ::getSpawnPoint;
	level.onPlayerKilled = ::onPlayerKilled;

    game["dialog"]["gametype"] = "freeforall";
	
	replacefunc(maps\mp\_utility::allowTeamChoice, ::_allowTeamChoice);
	replacefunc(maps\mp\_utility::allowClassChoice, ::_allowClassChoice);
}

_allowTeamChoice() { return false; }
_allowClassChoice() { return true; }

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
	
	SetDvarIfUninitialized("scr_crank_killstreak", 1);
	SetDvarIfUninitialized("scr_crank_time", 30);
	SetDvarIfUninitialized("scr_crank_credits", "Gamemode Developed by LastDemon99");
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
    
	preCache();
	
	game["strings"]["axis_name"] = "Cranked";
	game["strings"]["allies_name"] = "Cranked";
	
	game["icons"]["axis"] = "iw5_cardicon_bomb";
	game["icons"]["allies"] = "iw5_cardicon_bomb";
	
	level.spawnMins = ( 0, 0, 0 );
    level.spawnMaxs = ( 0, 0, 0 );
	
    maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
    maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );
	
    level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
    setmapcenter( level.mapCenter );
	
    allowed[0] = "dm";
    maps\mp\gametypes\_gameobjects::main( allowed );
	
	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 10 );
	maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0 );
	
	level.modeKillstreak = ["none", "specialty_fastreload", "specialty_longersprint", "specialty_bulletaccuracy", "all_perks"];
	level.modeKillstreakSplash = ["none", "specialty_fastreload_ks", "specialty_longersprint_ks", "specialty_bulletaccuracy_ks", "all_perks_bonus"];
	
	level.QuickMessageToAll = true;
	level.killstreakRewards = 1;
	level.teamBased = 0;
	level.hasInfinteAmmo = 0;
	
	level thread onPlayerConnect();
}

preCache()
{
	PreCacheShader("gradient");
	PreCacheShader("gradient_fadein");
	PreCacheShader("waypoint_bomb");
	PreCacheShader("line_vertical");
	PreCacheShader("iw5_cardicon_bomb");
	
	level.explosionFx = loadfx("explosions/oxygen_tank_explosion");
}

onPlayerConnect()
{
	level endon("game_ended");
	
	for (;;)
	{
		level waittill("connected", player);
		
		player.isCrank = false;
		
		player hudInit();	
		player thread onChangeKit();
		player thread onSpawnedPlayer();
	}
}

onSpawnedPlayer()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("spawned_player");
		
		self cleanCrank();
		self clearPerks();
		
		self.killstreak = 0;
		if(!getdvarint("scr_crank_killstreak")) self thread giveModeAllPerks(true);
	}
}

onChangeKit()
{
	self endon("disconnect");
	
	if ((self is_bot())) return;
	
	self.oldClass = "";
	
	for(;;)
	{
		self waittill("changed_kit");
		
		loadout = self maps\mp\gametypes\_class::cloneLoadout();
		loadout["loadoutJuggernaut"] = false;
		
		isTarget = false;
		
		if (loadout["loadoutPerk1"] != "specialty_null")
		{
			isTarget = true;
			loadout["loadoutPerk1"] = "specialty_null";
			loadout["loadoutPerk2"] = "specialty_null";
			loadout["loadoutPerk3"] = "specialty_null";
		}		

		if(isSpecialist(loadout["loadoutKillstreak1"]))
		{
			isTarget = true;
			loadout["loadoutKillstreak1"] = "none";
			loadout["loadoutKillstreak2"] = "none";
			loadout["loadoutKillstreak3"] = "none";
		}
		
		if(isTarget && self.oldClass != self.pers["class"])
		{
			self.pers["gamemodeLoadout"] = loadout;
			self giveLoadout(self.team, "gamemode", false, true);
			self maps\mp\killstreaks\_killstreaks::clearKillstreaks();
			
			self iPrintLnBold("Perks & Specialist streak has been disabled for this mode");
		}
		
		self.oldClass = self.pers["class"];
	}
}

setCrank()
{
	if(!isAlive(self)) return;
	
	level endon("game_ended");
	self endon("disconnect");
	self endon("clean_crank");
		
	self.isCrank = true;
	self showHud();
	time = getDvarInt("scr_crank_time");
	self playlocalsound("recondrone_tag");
	
	while(time != 0)
	{
		if (time == 1) self playlocalsound("javelin_clu_lock");
		else if (time < (35 * getDvarInt("scr_crank_time")) / 100)
		{
			self timerMotion();
			self playlocalsound("scrambler_beep");
		}	
		wait(1);
		time--;
	}
	
	self hideHud();
	playSoundAtPos(self.origin, "detpack_explo_default");
	playSoundAtPos(self.origin, "talon_destroyed");
	playfx(level.explosionFx, self getTagOrigin("tag_origin"));
	earthquake( 0.4, 1, self.origin, 1000 );
	self suicide();
}

resetCrank()
{
	self notify("clean_crank");
	self thread setCrank();
}

cleanCrank()
{
	self playlocalsound("talon_damaged");
	self notify("clean_crank");
	self hideHud();
	self.isCrank = false;
}

hudInit()
{
	if(self is_bot()) return;
	
	self.crankHud["timer"] = _createHudText("0:" + getDvarInt("scr_crank_time") + ":0", "objective", 1.5, "CENTER", "CENTER", -180, 35, self);
	self.crankHud["timer"].Alpha = 0;
	self.crankHud["timer"].sort = 10000;
	
	self.crankHud["string"] = _createHudText("^3CRANKED", "objective", 0.7, "CENTER", "CENTER", -143, 45, self);
	self.crankHud["string"].Alpha = 0;
	self.crankHud["string"].sort = 10000;
	
	self.crankHud["icon"] = self _createIcon("waypoint_bomb", 13, 12, "CENTER", "CENTER", -117, 43);
	self.crankHud["icon"].Alpha = 0;
	self.crankHud["icon"].sort = 10000;
	
	self.crankHud["bar1"] = self _createIcon("gradient", 120, 23, "CENTER", "CENTER", -150, 39);
	self.crankHud["bar1"].Alpha = 0;
	
	self.crankHud["bar2"] = self _createIcon("gradient", 120, 15, "CENTER", "CENTER", -150, 35);
	self.crankHud["bar2"].Alpha = 0;
	
	self.crankHud["bar3"] = self _createIcon("line_vertical", 5, 23, "CENTER", "CENTER", -212, 39);
	self.crankHud["bar3"].Alpha = 0;
	
	self thread hideOnGameEnd();
}

showHud()
{
	if(self is_bot()) return;
	
	self.crankHud["timer"] destroy();
	self.crankHud["timer"] = _createTimer(getDvarInt("scr_crank_time"), "objective", 1.5, "CENTER", "CENTER", -180, 35, self);
	self.crankHud["timer"] setTenthsTimer(getDvarInt("scr_crank_time"));
	self.crankHud["timer"].sort = 10000;
	self.crankHud["timer"] FadeOverTime(0.85);
	self.crankHud["timer"].Alpha = 1;
	
	self.crankHud["string"] FadeOverTime(0.85);
	self.crankHud["string"].Alpha = 1;
	
	self.crankHud["icon"] FadeOverTime(0.85);
	self.crankHud["icon"].Alpha = 1;
	
	self.crankHud["bar1"] FadeOverTime(0.85);
	self.crankHud["bar1"].Alpha = 0.8;
	
	
	self.crankHud["bar2"] FadeOverTime(0.85);
	self.crankHud["bar2"].Alpha = 0.5;
	
	self.crankHud["bar3"] FadeOverTime(0.85);
	self.crankHud["bar3"].Alpha = 1;
	
	self thread timerMotion();
}

hideHud()
{
	if(self is_bot()) return;
	
	foreach(hud in self.crankHud)
		hud.Alpha = 0;
}

hideOnGameEnd()
{
    self endon( "disconnect" );
    level waittill( "game_ended" );
	self cleanCrank();
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, lifeId)
{
	self cleanCrank();
	
	if(attacker == self || !isPlayer(attacker)) return;
	
	if(attacker.isCrank) attacker resetCrank();
	else attacker thread setCrank();
	
	if(isKillstreakWeapon(sWeapon)) return;	
	if ( sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_HEAD_SHOT" || sMeansOfDeath == "MOD_PROJECTILE" || sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_GRENADE" || sMeansOfDeath == "MOD_GRENADE_SPLASH" || sMeansOfDeath == "MOD_MELEE" && sWeapon == "riotshield_mp")
	{
		attacker.killstreak++;
		attacker onKillStreakMode();
	}
}

getSpawnPoint()
{
    spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
    spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );    
	return spawnPoint;
}

timerMotion()
{
	if(self is_bot()) return;
	
	current_scale = self.crankHud["timer"].FontScale;
	self.crankHud["timer"].Color = (1, 0, 0);
	self.crankHud["timer"].FontScale = (current_scale + 0.15);
	
	self thread fx_1(current_scale);
	self thread fx_2();
}

fx_1(current_scale)
{
	wait(0.35);
	self.crankHud["timer"].FontScale = current_scale;
}

fx_2()
{
	wait(0.6);
	self.crankHud["timer"].Color = (1, 1, 1);
}
