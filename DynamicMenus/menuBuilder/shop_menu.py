from simpleMenu import *
from simpleMenu import _if
#import pyperclip

shopMenu = menuDef('shop_menu')

shopMenu.onOpen = (exec('closemenu survival_hud'), setLocalVarInt('ui_index', dvarInt('ui_startIndex')), setLocalVarInt('onBack', 0))
shopMenu.onClose = exec('openmenu survival_hud')
shopMenu.onEsc = scriptmenuresponse('back') 

shopMenu.add(background(rect=(-1280, -480, 2560, 960, 2, 2), forecolor=(0, 0, 0, 0.8)))
shopMenu.add(background(rect=(-175, -170, 350, 20, 2, 2), forecolor=(0.1569, 0.1725, 0.1608, 1)))
shopMenu.add(background(rect=(-175, -150, 350, 65, 2, 2), forecolor=(0.3098, 0.349, 0.2745, 1)))
shopMenu.add(background(rect=(-175, -150, 350, 3, 2, 2), background='black'))
shopMenu.add(text(rect=(-170, -170, 350, 20, 2, 2), textfont=9, textscale=0.4, text=dvarString('menu_title'), exp=1))

desc = text(rect=(-170, -145, 300, 20, 2, 2), textalign=4, text='dvarString("item_desc")', exp=1)
desc.visibleWhen = 'dvarString("item_desc") != ""'
shopMenu.add(desc)

pos = -85
for index in range(10):
    shopMenu.add(background(rect=(-175, pos, 350, 20, 2, 2), forecolor=(0.1569, 0.1725, 0.1608, 1) if index % 2 == 0 else (0.2118, 0.2314, 0.22, 1)))
    pos += 20

navBar = background(rect=(-175, 0, 350, 20, 2, 2), forecolor=(0.55, 0.55, 0.55, 1), background='gradient_fadein')
navBar.expRectY = '20 * localvarint("ui_index") - 85'
navBar.visibleWhen = 'localvarint("ui_index") >= 0 && dvarstring( "menu_option" +  localvarint("ui_index") ) != ""'
shopMenu.add(navBar)

navBarShadow = background(rect=(-175, -85, 350, 2, 2, 2), background='black')
navBarShadow.expRectY = '20 * localvarint("ui_index") - 65'
navBarShadow.visibleWhen = 'localvarint("ui_index") >= 0 && dvarstring( "menu_option" +  localvarint("ui_index") ) != ""'
shopMenu.add(navBarShadow)

shopMenu.addDynamicsOptions((-165, -85, 350, 20, 2, 2), 20, 10) 

pos = -85
for i in range(10, 20):
    label = text(rect=(0, pos, 160, 20, 2, 2), textalign=10, 
        text=f'select(dvarInt("optionType{i}") == 6, "Owned", select(dvarInt("optionType{i}") == 7, "> Upgrade", "$ " + dvarstring( "menu_option{i}" )))',
        exp=1)
    shopMenu.optionForeColor(label, i)
    shopMenu.add(label)
    pos += 20

shopMenu.add(background(rect=(-175, 115, 350, 2, 2, 2), background='black'))
shopMenu.add(background(rect=(-175, 117, 350, 22, 2, 2), forecolor=(0.1569, 0.1725, 0.1608, 1)))
shopMenu.add(background(rect=(-175, 137, 350, 3, 2, 2), forecolor=(0.3098, 0.349, 0.2745, 1)))
shopMenu.add(text(rect=(-160, 117, 350, 20, 2, 2), forecolor=(0.55, 0.71, 0, 1), text='"$ " + dvarInt("ui_money")', exp=1))

backPanel = background(rect=(105, 117, 67, 20, 2, 2))
backPanel.expForecolorA = 'localvarint("onBack") * 0.65'
shopMenu.add(backPanel)

backEsc = text(rect=(0, 117, 165, 20, 2, 2), textalign=10, text='"Back ^2ESC"')
backEsc.expForecolorA = '1 - ( localvarint("onBack") * ( ( sin( localclientuimilliseconds( ) / 90 ) ) * 0.65 ) )'
backEsc.mouseEnter = (setLocalVarInt('onBack', 1), play('mouse_over'))
backEsc.mouseExit = (setLocalVarInt('onBack', 0), play('mouse_over'))
shopMenu.add(backEsc)

backEscAction = itemDef()
backEscAction.rect = (105, 117, 67, 20, 2, 2)
backEscAction.visible = 1
backEscAction.type = 1
backEscAction.action = scriptmenuresponse('back')
shopMenu.add(backEscAction)
    
print(str(shopMenu))
#pyperclip.copy(str(shopMenu))