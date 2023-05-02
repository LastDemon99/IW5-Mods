#include common_scripts\utility;
#include maps\mp\_utility;

getClassUIName()
{
	class_num = maps\mp\gametypes\_class::getClassIndex(self.curClass);	
	return self getPlayerData("customClasses", class_num, "name");
}

setClassData(target, value, index)
{
	class_num = maps\mp\gametypes\_class::getClassIndex(self.curClass);	
	if(isDefined(index)) self setPlayerData("customClasses", class_num, target, index, value);
	else self setPlayerData("customClasses", class_num, target, value);
}

setWeaponData(index1, target, value, index2)
{
	class_num = maps\mp\gametypes\_class::getClassIndex(self.curClass);	
	
	if(target == "weapon" && value != self getPlayerData("customClasses", class_num, "weaponSetups" , index1, "weapon"))
	{
		self setPlayerData("customClasses", class_num, "weaponSetups" , index1, target, value);
		self setPlayerData("customClasses", class_num, "weaponSetups" , index1, "attachment", 0, "none");
		self setPlayerData("customClasses", class_num, "weaponSetups" , index1, "attachment", 1, "none");
		self setPlayerData("customClasses", class_num, "weaponSetups" , index1, "camo", "none");
		self setPlayerData("customClasses", class_num, "weaponSetups" , index1, "buff", "specialty_null");
		self setPlayerData("customClasses", class_num, "weaponSetups" , index1, "reticle", "none");
	}
	else if (isDefined(index2))
		self setPlayerData("customClasses", class_num, "weaponSetups" , index1, target, index2, value);
	else
		self setPlayerData("customClasses", class_num, "weaponSetups" , index1, target, value);
}

getClassData(arg1, arg2, arg3, arg4)
{
	class_num = maps\mp\gametypes\_class::getClassIndex(self.curClass);

	if (isDefined(arg4)) return self getPlayerData("customClasses", class_num, arg1, arg2, arg3, arg4);
	if (isDefined(arg3)) return self getPlayerData("customClasses", class_num, arg1, arg2, arg3);
	if (isDefined(arg2)) return self getPlayerData("customClasses", class_num, arg1, arg2);
	return self getPlayerData("customClasses", class_num, arg1);
}

is_bot()
{
	return ( ( isDefined( self.pers["isBot"] ) && self.pers["isBot"] ) || ( isDefined( self.pers["isBotWarfare"] ) && self.pers["isBotWarfare"] ) || isSubStr( self getguid() + "", "bot" ) );
}

getStreakType(streakType)
{
	type = undefined;
	switch(streakType)
	{
		case "streaktype_support":
			type = "defenseStreaks";
			break;
		case "streaktype_specialist":
			type = "specialistStreaks";
			break;
		case "streaktype_assault":
			type = "assaultStreaks";
			break;
		default:
			type = "specialty_null";
			break;
	}
	return type;
}

_getWeaponClass( weapon )
{
	if(weapon == "at4") return "weapon_projectile";
	return getWeaponClass(weapon);
}

getGrenadeLauncher(weapon)
{
	if (weapon == "iw5_ak47") return "gp25";
	else if(weapon == "iw5_m16" || weapon == "iw5_m4") return "gl";
	else return "320";
}

contains(arr, value, binarySearch)
{
	if (isDefined(binarySearch))
		return binary_search(arr, value) != -1;

	foreach(val in arr)
		if(val == value) return true;

	return false;
}

binary_search(arr, val)
{
    low = 0;
    high = arr.size - 1;

    while (low <= high)
	{
		mid = (low + high);
        if (arr[mid] < val) low = mid + 1;
        else if (arr[mid] > val) high = mid - 1;
        else return mid;
	}
    return -1;
}

getIndex(arr, value)
{
	index = -1;
	for(i = 0; i < arr.size; i++)
		if(value == arr[i])
		{
			index = i;
			break;
		}
	return index;
}

_toUpper(text) 
{
    upper = "";    
	for (i = 0; i < text.size; i++)
	{
		test = level.upper[text[i]];		
		if(isDefined(test)) upper += test;
		else upper += text[i];
	}
    return upper;
}