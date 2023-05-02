#include common_scripts\utility;
#include maps\mp\_utility;

_openMenu(menu)
{
	self closeMenus();
	if (menu != "") self openpopupMenu(menu);
}

menuInit()
{
	self setClientDvar("ui_startIndex", -1);
	self setClientDvar("menu_title", "");
	self.pers["menu_pages"] = [];
}

getMenu(count)
{
	count = isDefined(count) ? count + 1 : 1;
	return self.pers["menu_pages"][self.pers["menu_pages"].size - count];
}

pushMenu(title, table, startIndex, range)
{
	menu = [];
	menu["title"] = title;
	menu["table"] = table;
	menu["startIndex"] = startIndex;
	menu["range"] = range;

	self.pers["menu_pages"][self.pers["menu_pages"].size] = menu;
	self openDynamicMenu();
}

popMenu()
{
	if (!isDefined(self.pers["menu_pages"]) || self.pers["menu_pages"].size < 1) return;
	
	newMenuPages = [];	
	for (i = 0; i < self.pers["menu_pages"].size - 1; i++)
		newMenuPages[i] = self.pers["menu_pages"][i];
	
	self.pers["menu_pages"] = newMenuPages;	
	self openDynamicMenu();
}

openDynamicMenu()
{
	menu = self getMenu();
    self setClientDvar("menu_title", "@" + menu["title"]);
	
	for(i = 0; i < 20; i++)
	{
		self setClientDvar("optionType" + i, 1);
		if(i < menu["range"]) self setClientDvar("menu_option" + i, "@" + tableLookup("mp/" + menu["table"] + ".csv", 0, i + menu["startIndex"], 2));
		else self setClientDvar("menu_option" + i, "");
	}	
	self _openMenu("custom_dynamic_menu");
}

setOptionType(type, table, startIndex, range, target)
{
	for(i = 0; i < range; i++)
		if(target == tableLookup("mp/"+ table + ".csv", 0, i + startIndex, 1))
		{
			self setClientDvar("optionType" + i, type);
			break;
		}
}

setOptionsType(type, table, startIndex, range, targets)
{
	for(i = 0; i < range; i++)
	{
		val = tableLookup("mp/"+ table + ".csv", 0, i + startIndex, 1);
		if(maps\mp\_lb_utility::contains(targets, val)) self setClientDvar("optionType" + i, type);
	}
}