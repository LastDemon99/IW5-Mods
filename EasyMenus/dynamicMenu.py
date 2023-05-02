import simpleMenu as menu

codPath = 'D:/Program Files/Steam/steamapps/common/Call of Duty Modern Warfare 3'

menuFiles = menu.fastLoad()
menuFiles.precache_gsc_path = f'{codPath}/zonetool/mod/maps/mp/gametypes/_menus.gsc'
menuFiles.mod_csv_path = f'{codPath}/zone_source/mod.csv'
menuFiles.scriptmenus_folder_path = f'{codPath}/zonetool/mod/ui_mp/scriptmenus'

menuName = 'custom_dynamic_menu'
newMenu = menu.defaultMultiplayerMenu(menuName)
newMenu.createOptions(
    'dvarstring( "menu_title" )', 
    [f'dvarstring( "menu_option{i}" )' for i in range(20)],
    [True for i in range(20)],
    True)
menuFiles.loadMenuFiles(menuName, newMenu)

menuFiles.loadMod(codPath, 'zonetool.exe', 'lb_server')