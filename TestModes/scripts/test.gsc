#include common_scripts\utility;
#include maps\mp\_utility;

init() 
{
	PreCacheShader("iw5_cardicon_rampage");
	level.test = "hola";
	
	//makeDvarServerInfo( "test_dvar", "hola");

	/*
	if(getdvar("g_gametype") != "bgun")
	{
		setDvar("g_gametype", "bgun");
		cmdexec("map mp_dome");
	}
	//*/
	
	level thread onSay();
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	level endon("game_ended");
	for (;;)
	{
		level waittill("connected", player);
	}
}


test()
{
	makeDvarServerInfo( "cg_drawCrosshairNames", 0);
	setDvar( "cg_drawCrosshairNames", 0);
	
	makeDvarServerInfo( "g_compassShowEnemies", 1);
	setDvar( "g_compassShowEnemies", 1);
	
	makeDvarServerInfo( "g_hardcore", 1);
	setDvar( "g_hardcore", 1);
	
	makeDvarServerInfo( "scr_hardcore", 1);
	setDvar( "scr_hardcore", 1);
	
	makeDvarServerInfo( "scr_diehard", 1);
	setDvar( "scr_diehard", 1);
	
	makeDvarServerInfo( "scr_oldschool", 1);
	setDvar( "scr_oldschool", 1);
	
	makeDvarServerInfo( "ui_hud_hardcore", 1);
	setDvar( "ui_hud_hardcore", 1);
	
	makeDvarServerInfo( "ui_hud_obituaries", 0);
	setDvar( "ui_hud_obituaries", 0);
	
	self setClientDvar( "ui_hud_hardcore", 1);
	self setClientDvar( "ui_hud_obituaries", 0);
}

onSay()
{
	level endon("game_ended");
	
	for(;;) 
	{
		level waittill("say", message, player);
		
		level.args = [];	
		str = strTok(message, "");
		i = 0;
		foreach (s in str) 
		{
			if ( i > 2 ) break;
			level.args[i] = s;
			i++;
		}
		
		str = strTok( level.args[0], " ");
		i = 0;
		foreach(s in str) 
		{
			if ( i > 2 ) break;
			level.args[i] = s;
			i++;
		}	
		
		if(string_starts_with(level.args[0], "!"))
			onCommand(player, level.args);
	}
}

onCommand(player, msg)
{
	args = [];
	foreach(i in msg)
		args[args.size] = tolower(i);
	
	switch(args[0])
	{
		case "!suicide":
		case "!s":
			player suicide();
			break;
		case "!fastrestart":
		case "!res":
			cmdexec("fast_restart");
			break;
		case "!restart":
			cmdexec("map_restart");
			break;
		case "!map":
			if (!isdefined(findMap(args[1]))) break;
			cmdexec("map " + findMap(args[1]));
			break;
		case "!dsr":
			cmdexec("load_dsr " + args[1]);
			wait(0.35);
			cmdexec("map_restart");
			break;
		case "!pos":
			logprint("CurrentPos: " + player.origin);
			player iPrintLnBold("CurrentPos: " + player.origin);
			break;
		case "!test":
			level notify("vote_start");
			break;
		case "!test2":
			player openpopupMenu(game["crosshair"]);
			break;
		case "!wep":
			player _giveWeapon("iw5_knifebo2_mp");
			player switchToWeapon( "iw5_knifebo2_mp" );
			print(getBaseWeaponName("iw5_knifebo2_mp"));
			break;
		case "!wep1":
			player _giveWeapon("iw5_butterflyknife_mp");
			player switchToWeapon( "iw5_butterflyknife_mp" );
			break;
		case "!wep2":
			player _giveWeapon("iw5_knife_mp");
			player switchToWeapon( "iw5_knife_mp" );
			break;
	}
}

findMap(target)
{
	foreach (item in level.maps)
		if(isSubStr(tolower(item), tolower(target)))
			return StrTok(item, ";")[0];
		
	return undefined;	
}

findPlayer(target)
{
	for(i = 0; i < level.players.size; i++)
	{
		if(!string_starts_with(target, "#")) break;
		
		if(string_end_with(target, "" + i))
			return level.players[i];
	}
	
	foreach (Player in level.players)
		if(isSubStr(tolower(Player.name), tolower(target)))
			return Player;
		
	return undefined;
}

string_end_with(string, end)
{
	test = "";	
	for (i = string.size - 1; i > 0; i--)
		test += string[i];
	
	return string_starts_with(test, end);
}

loadData()
{
	level.maps = [ "mp_plaza2;Arkaden",
            "mp_mogadishu;Bakaara",
            "mp_bootleg;Bootleg",
            "mp_carbon;Carbon",
            "mp_dome;Dome",
            "mp_exchange;Downturn",
            "mp_lambeth;Fallen",
            "mp_hardhat;Hardhat",
            "mp_interchange;Interchange",
            "mp_alpha;Lockdown",
            "mp_bravo;Mission",
            "mp_radar;Outpost",
            "mp_paris;Resistance",
            "mp_seatown;Seatown",
            "mp_underground;Underground",
            "mp_village;Village",
			"mp_morningwood;Blackbox",
            "mp_park;Liberation",
            "mp_qadeem;Oasis",
            "mp_overwatch;Overwatch",
            "mp_italy;Piazza",
            "mp_meteora;Sanctuary",
            "mp_cement;Foundation",
            "mp_aground_ss;Aground",
            "mp_hillside_ss;Getaway",
            "mp_restrepo_ss;Lookout",
            "mp_courtyard_ss;Erosion",
            "mp_terminal_cls;Terminal" ];
}