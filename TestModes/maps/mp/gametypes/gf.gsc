/*
============================
|   Lethal Beats Team 	   |
============================
|Game : IW5				   |
|Mod : extra_gametypes     |
|Gametype : Gun Fight      |
|Creator : LastDemon99	   |
============================
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\_lb_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
    maps\mp\gametypes\_globallogic::init();
    maps\mp\gametypes\_callbacksetup::SetupCallbacks();
    maps\mp\gametypes\_globallogic::SetupCallbacks();

    level.initializeMatchRules = ::initializeMatchRules;
	[[ level.initializeMatchRules ]]();

    level.teamBased = 1;
    level.onStartGameType = ::onStartGameType;
    level.getSpawnPoint = ::getSpawnPoint;
    level.onNormalDeath = ::onNormalDeath;

    replacefunc(maps\mp\_utility::allowTeamChoice, ::_allowTeamChoice);
	replacefunc(maps\mp\_utility::allowClassChoice, ::_allowClassChoice);
}

_allowTeamChoice() { return true; }
_allowClassChoice() { return true; }
_blank() { }

initializeMatchRules()
{
    setdynamicdvar( "scr_" + level.gameType + "_timeLimit", 2);
	registerTimeLimitDvar(level.gameType, 2);
	
	setdynamicdvar( "scr_" + level.gameType + "_scorelimit", 6);
	registerScoreLimitDvar(level.gameType, 6);
	
	setdynamicdvar( "scr_" + level.gameType + "_numLives", 1);
	registerNumLivesDvar(level.gameType,  1);
	
	setdynamicdvar( "scr_player_maxhealth", 100);
	setdynamicdvar( "scr_player_healthregentime", 5);
	
	setdynamicdvar( "scr_" + level.gameType + "_winlimit", 6);
    registerWinLimitDvar(level.gameType, 6);
	
    setdynamicdvar( "scr_" + level.gameType + "_roundlimit", 0);
    registerRoundLimitDvar(level.gameType, 0);
	
	setdynamicdvar( "scr_" + level.gameType + "_roundswitch", 1);
    registerRoundSwitchDvar(level.gameType, 1, 0, 9);
	
    setdynamicdvar( "scr_" + level.gameType + "_halftime", 0 );
    registerHalfTimeDvar(level.gameType, 0 );
	
    setdynamicdvar( "scr_" + level.gameType + "_promode", 0 );
	registerNumLivesDvar(level.gameType, 0 );	
	
	setdynamicdvar( "scr_" + level.gameType + "_playerrespawndelay", 0);
	setdynamicdvar( "scr_" + level.gameType + "_waverespawndelay", 0);
	
	setdynamicdvar( "scr_game_spectatetype", 1);
	setdynamicdvar( "scr_game_allowkillcam", 1);
	setdynamicdvar( "scr_game_forceuav", 0);
	setdynamicdvar( "scr_game_hardpoints",0);
	setdynamicdvar( "scr_game_perks", 0);
	setdynamicdvar( "scr_game_onlyheadshots",0);
	
	setdynamicdvar( "scr_thirdPerson", 0);
	setdynamicdvar( "scr_player_forcerespawn", 1);
	setdynamicdvar( "camera_thirdPerson", 0);
	setdynamicdvar( "g_hardcore", 0);
}

onStartGameType()
{
	setClientNameMode("auto_change");
	
	setObjectiveText( "allies", &"OBJECTIVES_WAR" );
	setObjectiveText( "axis", &"OBJECTIVES_WAR" );
	
	if ( level.splitscreen )
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_WAR" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_WAR" );
	}
	else
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_WAR_SCORE" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_WAR_SCORE" );
	}
	setObjectiveHintText( "allies", &"OBJECTIVES_WAR_HINT" );
	setObjectiveHintText( "axis", &"OBJECTIVES_WAR_HINT" );
	
	PreCacheShader("cardicon_seasnipers");
	PreCacheShader(getDvar("g_TeamIcon_Axis"));
	PreCacheShader(getDvar("g_TeamIcon_Allies"));
			
	game["strings"]["axis_name"] = "Gun Fight";
	game["strings"]["allies_name"] = "Gun Fight";
	
	game["icons"]["axis"] = "cardicon_seasnipers";
	game["icons"]["allies"] = "cardicon_seasnipers";

	setTeamScore("allies", game["roundsWon"]["allies"]);
	setTeamScore("axis", game["roundsWon"]["axis"]);
	
    if ( !isdefined( game["switchedsides"] ) )
        game["switchedsides"] = 0;

    if ( game["switchedsides"] )
    {		
        oldAttackers = game["attackers"];
        oldDefenders = game["defenders"];
        game["attackers"] = oldDefenders;
        game["defenders"] = oldAttackers;
    }
	
    level.spawnMins = ( 0, 0, 0 );
    level.spawnMaxs = ( 0, 0, 0 );
	
    maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
    maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
	
    level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
    setmapcenter( level.mapCenter );
	
    allowed[0] = "war";
    allowed[1] = "airdrop_pallet";
	
    maps\mp\gametypes\_gameobjects::main( allowed );
	
	level.QuickMessageToAll = true;
	level.killstreakRewards = 0;
	level.teamBased = 1;
	
	clearScoreInfo();
	maps\mp\gametypes\_rank::registerScoreInfo( "team_defeat", 1);
}

getSpawnPoint()
{
    spawnteam = self.pers["team"];

    if ( game["switchedsides"] )
        spawnteam = maps\mp\_utility::getOtherTeam( spawnteam );
	
	spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn_" + spawnteam + "_start" );
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
    return spawnPoint;
}

getRoundWinner()
{
	axisCount = 0;
	alliesCount = 0;
	
	foreach(player in level.players)
		if(isReallyAlive(player))
		{
			if(player.team == "axis") axisCount++;
			else if(player.team == "allies") alliesCount++;
		}
		
	if(axisCount == 0) return "allies";
	else if (alliesCount == 0) return "axis";
	else return "none";
}

onNormalDeath( victim, attacker, lifeId )
{
	winners = getRoundWinner();
	if (winners == "none") return;
	losers = getOtherTeam(winners);
	
	game["icons"]["axis"] = getDvar("g_TeamIcon_Axis");
	game["icons"]["allies"] = getDvar("g_TeamIcon_Allies");
	
	attacker.finalKill = true;
	game["teamScores"][winners] = game["roundsWon"][winners] + 1;
	game["teamScores"][losers] = game["roundsWon"][losers];
	
	thread maps\mp\gametypes\_gamelogic::endGame(winners, game["strings"][losers + "_eliminated"]);
}

onTimeLimit()
{
	game["icons"]["axis"] = getDvar("g_TeamIcon_Axis");
	game["icons"]["allies"] = getDvar("g_TeamIcon_Allies");
	
	game["teamScores"]["axis"] = game["roundsWon"]["axis"];
	game["teamScores"]["allies"] = game["roundsWon"]["allies"];
	
    level.finalKillCam_winner = "none";
    thread maps\mp\gametypes\_gamelogic::endGame("forfeit", game["strings"]["time_limit_reached"] );
}
