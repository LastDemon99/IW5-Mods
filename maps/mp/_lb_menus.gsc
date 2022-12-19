#include maps\mp\_utility;

init()
{
	game["testmenu"] = "testmenu"; 
	precacheMenu(game["testmenu"]);
	
	game["gf_loadout_preview"] = "gf_loadout_preview"; 
	precacheMenu(game["gf_loadout_preview"]);
	
	PreCacheItem("iw5_butterflyknife_mp");
	PreCacheItem("iw5_knifebo2_mp");
	PreCacheItem("iw5_knife_mp");
	PreCacheItem("at4_mp");
	
	PreCacheShader("iw5_cardicon_rampage");
}