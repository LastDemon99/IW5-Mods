from simpleMenu import *

dynamicMenu = mainMenu('custom_options')
dynamicMenu.visibleWhen = '!(localVarInt("ui_hideBack"))'

dynamicMenu.onOpen = (exec('closemenu survival_hud'), setLocalVarInt('ui_index', dvarInt('ui_startIndex')))

dynamicMenu.add(dynamicMenu.createTittle(0, 'dvarstring( "menu_title" )'))
dynamicMenu.add(dynamicMenu.createSplitBar(0, 1))

for i in range(20):
    dynamicMenu.createOption(i)

    splitBar = dynamicMenu.createSplitBar(i)
    splitBar.visibleWhen = f'dvarInt("optionType{i}") % 2'
    dynamicMenu.add(splitBar)

print(str(dynamicMenu))