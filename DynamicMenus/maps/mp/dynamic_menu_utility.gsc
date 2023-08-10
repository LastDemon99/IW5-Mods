#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\survival\_utility;

openDynamicMenu(menu)
{
	self setClientDvar("ui_startIndex", -1);
	self.currMenu = menu;
	self.pers["menu_pages"] = [];
	self pushPage("main");
}

closeDynamicMenu()
{
	self _closeMenu(level.dynamicMenu[self.currMenu]["_menu_"]);
	self.currMenu = undefined;
	self.pers["menu_pages"] = [];
}

getPage(count)
{
	count = isDefined(count) ? count + 1 : 1;
	return self.pers["menu_pages"][self.pers["menu_pages"].size - count];
}

getPageData(count)
{
	return level.dynamicMenu[self.currMenu][self getPage(count)];
}

pushPage(page, selected)
{
	if(isDefined(selected)) self.prevResponse = selected;
	else self.prevResponse = undefined;
	
	self.pers["menu_pages"][self.pers["menu_pages"].size] = page;
	
	self setPage(page);
	
	if (page == "main")
	{
		self closeMenus();
		self _openMenu(level.dynamicMenu[self.currMenu]["_menu_"]);
	}
}

popPage()
{
	if (self.pers["menu_pages"].size == 1)
	{
		self closeDynamicMenu();
		self notify("show_hud");
		return;
	}
	if (!isDefined(self.pers["menu_pages"]) || self.pers["menu_pages"].size < 1) return;
	
	newMenuPages = [];	
	for (i = 0; i < self.pers["menu_pages"].size - 1; i++)
		newMenuPages[i] = self.pers["menu_pages"][i];
	
	self.pers["menu_pages"] = newMenuPages;	
	self setPage(self getPage());
}

setPage(page)
{
	pages = level.dynamicMenu[self.currMenu];
	page_data = pages[page];
	table = "mp/" + self.currMenu + ".csv";
	
	self setClientDvar("menu_title", "@" + page_data[0]);
	
	for(i = 0; i < 20; i++)
	{
		self setClientDvar("optionType" + i, 4);
		text = tableLookupByRow(table, i + page_data[1], 1);		
		if(i < page_data[2] && text != "-") self setClientDvar("menu_option" + i, "@" + text);
		else self setClientDvar("menu_option" + i, "");
	}
}

loadMenuData(menu, table)
{
	menu_data = [];
	menu_data["_menu_"] = menu;
	menu_data["_table_"] = table;	
	
	table = "mp/" + table + ".csv";
	page = tableLookupByRow(table, 0, 2);
	menu_data[page] = [tableLookupByRow(table, 0, 1), 1];
	
	for (row = 0; tableLookupByRow(table, row, 0) != ""; row++)
		if(tableLookupByRow(table, row, 1) == "")
		{
			menu_data[page][2] = row - menu_data[page][1];
			menu_data[page][3] = page;
			
			if(tableLookupByRow(table, row + 1, 1) != "")
			{
				page = tableLookupByRow(table, row + 1, 2);
				menu_data[page] = [tableLookupByRow(table, row + 1, 1), row + 2];
			}
		}
		
	level.dynamicMenu[menu_data["_table_"]] = menu_data;
}