init()
{
    replacefunc(maps\mp\gametypes\_quickmessages::init, ::blank);

    if ( !isdefined( game["gamestarted"] ) )
    {
        game["menu_class"] = "custom_options";
        game["menu_class_allies"] = "custom_options";
        game["menu_class_axis"] = "custom_options";
        game["menu_team"] = "team_marinesopfor";        
        game["menu_changeclass"] = "changeclass";
        game["menu_muteplayer"] = "muteplayer";
        game["menu_leavegame"] = "popup_leavegame";

        precachemenu( game["menu_muteplayer"] );
        precachemenu( game["menu_leavegame"] );
        precachemenu( game["menu_team"] );
        precachemenu( game["menu_changeclass"] );
        precachemenu( "scoreboard" );

        //+CUSTOM MENUS
        precachemenu("custom_options");
        precachemenu("custom_dynamic_menu");
        precachemenu("shop_menu");
        //-CUSTOM MENUS

        precachestring( &"MP_HOST_ENDED_GAME" );
        precachestring( &"MP_HOST_ENDGAME_RESPONSE" );
    }

    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  player  );  
        player thread onMenuResponse();        
        player maps\mp\dynamic_menu_utility::menuInit();
    }
}

onMenuResponse()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "menuresponse",  menu, response  );

        response = str(response);
        menu = str(menu);

        if(menu == "custom_dynamic_menu") continue;

        if ( response == "back" )
        {
            self closepopupmenu();
            self closeingamemenu();

            if (menu == game["menu_changeclass"] || menu == game["menu_team"])
            {
                self checkClassUI();
                self openpopupMenu("custom_options");
            }
            continue;
        }

        if ( response == "changeteam" )
        {
            self closepopupmenu();
            self closeingamemenu();
            self openpopupmenu( game["menu_team"] );
            continue;
        }

        if ( response == "changeclass" )
        {
            self closepopupmenu();
            self closeingamemenu();
            self checkClassUI();
            self openpopupmenu(game["menu_changeclass"]);
            continue;
        }

        if ( response == "endgame" )
        {
            if ( level.splitscreen )
            {
                endparty();

                if ( !level.gameEnded )
                    level thread maps\mp\gametypes\_gamelogic::forceEnd();
            }
            continue;
        }

        if ( response == "endround" )
        {
            if ( !level.gameEnded )
                level thread maps\mp\gametypes\_gamelogic::forceEnd();
            else
            {
                self closepopupmenu();
                self closeingamemenu();
                self iprintln( &"MP_HOST_ENDGAME_RESPONSE" );
            }
            continue;
        }

        if ( menu  == game["menu_team"] )
        {
            switch ( response )
            {
                case "allies":
                    self [[ level.allies ]]();
                    break;
                case "axis":
                    self [[ level.axis ]]();
                    break;
                case "autoassign":
                    self [[ level.autoassign ]]();
                    break;
                case "spectator":
                    self [[ level.spectator ]]();
                    break;
            }
            continue;
        }

        if ( menu  == game["menu_changeclass"])
        {
            self closepopupmenu();
            self closeingamemenu();
            self.selectedClass = 1;
            self [[ level.class ]]( response );
            self notify("change_class", response);
            continue;
        }
    }
}

getTeamAssignment()
{
    teams[0] = "allies";
    teams[1] = "axis";

    if ( !level.teamBased )
        return teams[randomint( 2 )];

    if ( self.sessionteam != "none" && self.sessionteam != "spectator" && self.sessionstate != "playing" && self.sessionstate != "dead" )
        assignment = self.sessionteam;
    else
    {
        playerCounts = maps\mp\gametypes\_teams::CountPlayers();

        if ( playerCounts["allies"] == playerCounts["axis"] )
        {
            if ( getteamscore( "allies" ) == getteamscore( "axis" ) )
                assignment = teams[randomint( 2 )];
            else if ( getteamscore( "allies" ) < getteamscore( "axis" ) )
                assignment = "allies";
            else
                assignment = "axis";
        }
        else if ( playerCounts["allies"] < playerCounts["axis"] )
            assignment = "allies";
        else
            assignment = "axis";
    }

    return assignment;
}

menuAutoAssign()
{
    maps\mp\_utility::closeMenus();
    assignment = getTeamAssignment();

    if ( isdefined( self.pers["team"] ) && ( self.sessionstate == "playing" || self.sessionstate == "dead" ) )
    {
        if ( assignment == self.pers["team"] )
        {
            beginClassChoice();
            return;
        }
        else
        {
            self.switching_teams = 1;
            self.joining_team = assignment;
            self.leaving_team = self.pers["team"];
            self suicide();
        }
    }

    addToTeam( assignment );
    self.pers["class"] = undefined;
    self.class = undefined;

    if ( !isalive( self ) )
        self.statusicon = "hud_status_dead";

    self notify( "end_respawn" );
    beginClassChoice();
}

beginClassChoice( forceNewChoice )
{
    team = self.pers["team"];

    self checkClassUI();    

    if ( maps\mp\_utility::allowClassChoice() )
        self openpopupmenu(game["menu_changeclass"]);
    else
        thread bypassClassChoice();

    if ( !isalive( self ) )
        thread maps\mp\gametypes\_playerlogic::predictAboutToSpawnPlayerOverTime( 0.1 );
}

bypassClassChoice()
{
    self.selectedClass = 1;
    self [[ level.class ]]( "class0" );
}

beginTeamChoice()
{
    self openpopupmenu( game["menu_team"] );
}

showMainMenuForTeam()
{
    team = self.pers["team"];
    self openpopupmenu( game["menu_class_" + team] );
}

menuAllies()
{
    maps\mp\_utility::closeMenus();

    if ( self.pers["team"] != "allies" )
    {
        if ( level.teamBased && !maps\mp\gametypes\_teams::getJoinTeamPermissions( "allies" ) )
        {
            self openpopupmenu( game["menu_team"] );
            return;
        }

        if ( level.inGracePeriod && !self.hasDoneCombat )
            self.hasSpawned = 0;

        if ( self.sessionstate == "playing" )
        {
            self.switching_teams = 1;
            self.joining_team = "allies";
            self.leaving_team = self.pers["team"];
            self suicide();
        }

        addToTeam( "allies" );
        self.pers["class"] = undefined;
        self.class = undefined;
        self notify( "end_respawn" );
    }

    beginClassChoice();
}

menuAxis()
{
    maps\mp\_utility::closeMenus();

    if ( self.pers["team"] != "axis" )
    {
        if ( level.teamBased && !maps\mp\gametypes\_teams::getJoinTeamPermissions( "axis" ) )
        {
            self openpopupmenu( game["menu_team"] );
            return;
        }

        if ( level.inGracePeriod && !self.hasDoneCombat )
            self.hasSpawned = 0;

        if ( self.sessionstate == "playing" )
        {
            self.switching_teams = 1;
            self.joining_team = "axis";
            self.leaving_team = self.pers["team"];
            self suicide();
        }

        addToTeam( "axis" );
        self.pers["class"] = undefined;
        self.class = undefined;
        self notify( "end_respawn" );
    }

    beginClassChoice();
}

menuSpectator()
{
    maps\mp\_utility::closeMenus();

    if ( isdefined( self.pers["team"] ) && self.pers["team"] == "spectator" )
        return;

    if ( isalive( self ) )
    {
        self.switching_teams = 1;
        self.joining_team = "spectator";
        self.leaving_team = self.pers["team"];
        self suicide();
    }

    addToTeam( "spectator" );
    self.pers["class"] = undefined;
    self.class = undefined;
    thread maps\mp\gametypes\_playerlogic::spawnSpectator();
}

menuClass( response )
{
    maps\mp\_utility::closeMenus();

    if ( response == "demolitions_mp,0" && self getplayerdata( "featureNew", "demolitions" ) )
        self setplayerdata( "featureNew", "demolitions", 0 );

    if ( response == "sniper_mp,0" && self getplayerdata( "featureNew", "sniper" ) )
        self setplayerdata( "featureNew", "sniper", 0 );

    if ( !isdefined( self.pers["team"] ) || self.pers["team"] != "allies" && self.pers["team"] != "axis" )
        return;

    class = maps\mp\gametypes\_class::getClassChoice( response );
    primary = maps\mp\gametypes\_class::getWeaponChoice( response );

    if ( class == "restricted" )
    {
        beginClassChoice();
        return;
    }

    if ( isdefined( self.pers["class"] ) && self.pers["class"] == class && ( isdefined( self.pers["primary"] ) && self.pers["primary"] == primary ) )
        return;

    if ( self.sessionstate == "playing" )
    {
        if ( isdefined( self.pers["lastClass"] ) && isdefined( self.pers["class"] ) )
        {
            self.pers["lastClass"] = self.pers["class"];
            self.lastClass = self.pers["lastClass"];
        }

        self.pers["class"] = class;
        self.class = class;
        self.pers["primary"] = primary;

        if ( game["state"] == "postgame" )
            return;

        if ( level.inGracePeriod && !self.hasDoneCombat )
        {
            maps\mp\gametypes\_class::setClass( self.pers["class"] );
            self.tag_stowed_back = undefined;
            self.tag_stowed_hip = undefined;
            maps\mp\gametypes\_class::giveLoadout( self.pers["team"], self.pers["class"] );
        }
        else
            self iprintlnbold( game["strings"]["change_class"] );
    }
    else
    {
        if ( isdefined( self.pers["lastClass"] ) && isdefined( self.pers["class"] ) )
        {
            self.pers["lastClass"] = self.pers["class"];
            self.lastClass = self.pers["lastClass"];
        }

        self.pers["class"] = class;
        self.class = class;
        self.pers["primary"] = primary;

        if ( game["state"] == "postgame" )
            return;

        if ( game["state"] == "playing" && !maps\mp\_utility::isInKillcam() )
            thread maps\mp\gametypes\_playerlogic::spawnClient();
    }

    thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}

addToTeam( team, firstConnect )
{
    if ( isdefined( self.team ) )
        maps\mp\gametypes\_playerlogic::removeFromTeamCount();

    self.pers["team"] = team;
    self.team = team;
    self checkClassUI();

    if ( !maps\mp\_utility::matchMakingGame() || isdefined( self.pers["isBot"] ) || !maps\mp\_utility::allowTeamChoice() )
    {
        if ( level.teamBased )
            self.sessionteam = team;
        else if ( team == "spectator" )
            self.sessionteam = "spectator";
        else
            self.sessionteam = "none";
    }

    if ( game["state"] != "postgame" )
        maps\mp\gametypes\_playerlogic::addToTeamCount();

    maps\mp\_utility::updateObjectiveText();

    if ( isdefined( firstConnect ) && firstConnect )
        waittillframeend;

    maps\mp\_utility::updateMainMenu();

    if ( team == "spectator" )
    {
        self notify( "joined_spectators" );
        level notify( "joined_team" );
    }
    else
    {
        self notify( "joined_team" );
        level notify( "joined_team" );
    }
}

checkClassUI()
{
    if( getDvarInt( "xblive_privatematch" ) )
        self SetClientDvar("ui_customClassLoc", "privateMatchCustomClasses");
	else 
        self SetClientDvar("ui_customClassLoc", "customClasses");

    if (self.pers["team"] == "allies")
        self SetClientDvar("ui_team", "marines");
    else if (self.pers["team"] == "axis")
        self SetClientDvar("ui_team", "opfor");
}

blank()
{
}