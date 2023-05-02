init()
{
    level.splitscreen = issplitscreen();
    level.ps3 = getdvar( "ps3Game" ) == "true";
    level.xenon = getdvar( "xenonGame" ) == "true";
    level.console = level.ps3 || level.xenon;
    level.onlinegame = getdvarint( "onlinegame" );
    level.rankedmatch = !level.onlinegame || !getdvarint( "xblive_privatematch" );
    level.script = tolower( getdvar( "mapname" ) );
    level.gametype = tolower( getdvar( "g_gametype" ) );
    level.otherteam["allies"] = "axis";
    level.otherteam["axis"] = "allies";
    level.teambased = 0;
    level.objectivebased = 0;
    level.endgameontimelimit = 1;
    level.showingfinalkillcam = 0;
    level.tispawndelay = getdvarint( "scr_tispawndelay" );

    if ( !isdefined( level.tweakablesinitialized ) )
        maps\mp\gametypes\_tweakables::init();

    precachestring( &"MP_HALFTIME" );
    precachestring( &"MP_OVERTIME" );
    precachestring( &"MP_ROUNDEND" );
    precachestring( &"MP_INTERMISSION" );
    precachestring( &"MP_SWITCHING_SIDES" );
    precachestring( &"MP_FRIENDLY_FIRE_WILL_NOT" );
    precachestring( &"PLATFORM_REVIVE" );
    precachestring( &"MP_OBITUARY_NEUTRAL" );
    precachestring( &"MP_OBITUARY_FRIENDLY" );
    precachestring( &"MP_OBITUARY_ENEMY" );

    if ( level.splitscreen )
        precachestring( &"MP_ENDED_GAME" );
    else
        precachestring( &"MP_HOST_ENDED_GAME" );

    level.halftimetype = "halftime";
    level.halftimesubcaption = &"MP_SWITCHING_SIDES";
    level.laststatustime = 0;
    level.waswinning = "none";
    level.lastslowprocessframe = 0;
    level.placement["allies"] = [];
    level.placement["axis"] = [];
    level.placement["all"] = [];
    level.postroundtime = 5.0;
    level.playerslookingforsafespawn = [];
    
	registerdvars();
    
	precachemodel( "vehicle_mig29_desert" );
    precachemodel( "projectile_cbu97_clusterbomb" );
    precachemodel( "tag_origin" );
    
	level.fx_airstrike_afterburner = loadfx( "fire/jet_afterburner" );
    level.fx_airstrike_contrail = loadfx( "smoke/jet_contrail" );

    if ( maps\mp\_utility::matchmakinggame() )
    {
        var_0 = " LB_MAP_" + getdvar( "ui_mapname" );
        var_1 = " LB_GM_" + level.gametype;

        if ( getdvarint( "g_hardcore" ) )
            var_1 += "_HC";

        precacheleaderboards( "LB_GB_TOTALXP_AT LB_GB_TOTALXP_LT LB_GB_WINS_AT LB_GB_WINS_LT LB_GB_KILLS_AT LB_GB_KILLS_LT LB_GB_ACCURACY_AT LB_ACCOLADES" + var_1 + var_0 );
    }

    level.teamcount["allies"] = 0;
    level.teamcount["axis"] = 0;
    level.teamcount["spectator"] = 0;
    level.alivecount["allies"] = 0;
    level.alivecount["axis"] = 0;
    level.alivecount["spectator"] = 0;
    level.livescount["allies"] = 0;
    level.livescount["axis"] = 0;
    level.onelefttime = [];
    level.hasspawned["allies"] = 0;
    level.hasspawned["axis"] = 0;

    maps\mp\_lb_menus::init();
    
    replacefunc(maps\mp\gametypes\_quickmessages::init, ::blank);
    replacefunc(maps\mp\gametypes\_quickmessages::quickcommands, ::blank);
    replacefunc(maps\mp\gametypes\_quickmessages::quickstatements, ::blank); 
    replacefunc(maps\mp\gametypes\_quickmessages::quickresponses, ::blank);
}

registerdvars()
{
    makedvarserverinfo( "ui_bomb_timer", 0 );
    makedvarserverinfo( "ui_nuke_end_milliseconds", 0 );
    makedvarserverinfo( "ui_danger_team", "" );
    makedvarserverinfo( "ui_inhostmigration", 0 );
    makedvarserverinfo( "ui_override_halftime", 0 );
    makedvarserverinfo( "camera_thirdPerson", getdvarint( "scr_thirdPerson" ) );
}

SetupCallbacks()
{
    level.onxpevent = ::onxpevent;
    level.getspawnpoint = ::blank;
    level.onspawnplayer = ::blank;
    level.onrespawndelay = ::blank;
    level.ontimelimit = maps\mp\gametypes\_gamelogic::default_ontimelimit;
    level.onhalftime = maps\mp\gametypes\_gamelogic::default_onhalftime;
    level.ondeadevent = maps\mp\gametypes\_gamelogic::default_ondeadevent;
    level.ononeleftevent = maps\mp\gametypes\_gamelogic::default_ononeleftevent;
    level.onprecachegametype = ::blank;
    level.onstartgametype = ::blank;
    level.onplayerkilled = ::blank;
    level.autoassign = maps\mp\gametypes\_menus::menuautoassign;
    level.spectator = maps\mp\gametypes\_menus::menuspectator;
    level.class = maps\mp\gametypes\_menus::menuclass;
    level.allies = maps\mp\gametypes\_menus::menuallies;
    level.axis = maps\mp\gametypes\_menus::menuaxis;
}

blank( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
{

}

testmenu()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        wait 10.0;
        
		notifyData = spawnstruct();
        notifyData.titletext = &"MP_CHALLENGE_COMPLETED";
        notifyData.notifytext = "wheee";
        notifyData.sound = "mp_challenge_complete";
        
		thread maps\mp\gametypes\_hud_message::notifymessage( notifyData );
    }
}

testshock()
{
    self endon( "death" );
    self endon( "disconnect" );

    for (;;)
    {
        wait 3.0;
        numShots = randomint( 6 );

        for ( i = 0; i < numShots; i++ )
        {
            iprintlnbold( numShots );
            self shellshock( "frag_grenade_mp", 0.2 );
            wait 0.1;
        }
    }
}

onxpevent( event )
{
    thread maps\mp\gametypes\_rank::giverankxp( event );
}

fakelag()
{
    self endon( "disconnect" );
    self.fakelag = randomintrange( 50, 150 );

    for (;;)
    {
        self setclientdvar( "fakelag_target", self.fakelag );
        wait(randomfloatrange( 5.0, 15.0 ));
    }
}

debugline( start, end )
{
    for ( i = 0; i < 50; i++ )
	{
		line( start, end );
		wait 0.05;
	}
}