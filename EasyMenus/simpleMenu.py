import buildMod as mod
from os.path import exists

class itemDef:
    def __init__(self, name = 'itemDef'):
        self.name = name
        self._values = []

    @property
    def values(self, index):
        return self._values[index]

    @values.setter
    def set(self, value):
        self._values.append('    ' + value)

    def add(self, itemDef):
        self._values.append('')
        [self._values.append('    ' + i) for i in str(itemDef).split('\n')]

    def __str__(self):
     return self.name + '\n{\n' + '\n'.join(self._values) + '\n}'

class defaultMultiplayerMenu:
    def __init__(self, name = 'itemDef'):
        self.mainMenu = itemDef('menuDef')
        self.mainMenu.set = f'name "{name}"'
        self.mainMenu.set = 'rect 0 0 640 480 0 0;'
        self.mainMenu.set = 'forecolor 1 1 1 1'
        self.mainMenu.set = 'blurWorld 4.8'

        self.onOpen = itemDef('onOpen')
        self.onOpen.set = 'setLocalVarInt "ui_index" dvarInt( "ui_startIndex" );'
        self.mainMenu.add(self.onOpen)

        self.onEsc = itemDef('onEsc')
        self.onEsc.set = 'scriptmenuresponse "back";'
        self.mainMenu.add(self.onEsc)

        self.leftPanel = itemDef()
        self.leftPanel.set = 'rect -64 -36 301.5 480 1 1'
        self.leftPanel.set = 'decoration'
        self.leftPanel.set = 'visible 1'
        self.leftPanel.set = 'style 3'
        self.leftPanel.set = 'forecolor 0 0 0 0.4'
        self.leftPanel.set = 'background "white"'
        self.mainMenu.add(self.leftPanel)

        self.panelShadow = itemDef()
        self.panelShadow.set = 'rect 237.5 -236 13 680 1 1'
        self.panelShadow.set = 'decoration'
        self.panelShadow.set = 'visible 1'
        self.panelShadow.set = 'style 3'
        self.panelShadow.set = 'forecolor 1 1 1 0.75'
        self.panelShadow.set = 'background "navbar_edge"'
        self.mainMenu.add(self.panelShadow)

        self.navBar = itemDef()
        self.navBar.set = 'rect -88 34.667 325.333 17.333 1 1'
        self.navBar.set = 'decoration'
        self.navBar.set = 'visible 1'
        self.navBar.set = 'style 3'
        self.navBar.set = 'background "navbar_selection_bar"'
        self.navBar.set = 'exp rect y ( 20 * localvarint("ui_index") + 34.667)'
        self.navBar.set = 'visible when ( localvarint("ui_index") >= 0 )'
        self.mainMenu.add(self.navBar)

        self.navBarShadow = itemDef()
        self.navBarShadow.set = 'rect -88 52 325.333 8.666 1 1'
        self.navBarShadow.set = 'decoration'
        self.navBarShadow.set = 'visible 1'
        self.navBarShadow.set = 'style 3'
        self.navBarShadow.set = 'background "navbar_selection_bar_shadow"'
        self.navBarShadow.set = 'exp rect y ( 20 * localvarint("ui_index") + 52)'
        self.navBarShadow.set = 'visible when ( localvarint("ui_index") >= 0 )'
        self.mainMenu.add(self.navBarShadow)

        self.titlesPos = 3
        self.optionsPos = 33.334
        self.optionsCount = 0

    def createOptions(self, title, options, splitbar = None, colorvar = False):
        createTitle(self.mainMenu, title, self.titlesPos)
        createSplitBar(self.mainMenu, self.titlesPos + 27)

        for option in options:  

            if splitbar is not None and splitbar[self.optionsCount] == True:
                createSplitBar(self.mainMenu, self.optionsPos, self.optionsCount)

            createOption(self.mainMenu, option, self.optionsCount, self.optionsPos, colorvar)

            self.optionsPos += 20
            self.optionsCount += 1

        self.titlesPos = self.optionsPos + 9.567
        self.optionsPos = self.titlesPos + 30.334
        self.optionsCount += 2

    def __str__(self):
        container = itemDef('')
        container.add(self.mainMenu)
        return str(container)

class fastLoad:
    def __init__(self):
        self.precache_gsc_path = ''
        self.mod_csv_path = ''
        self.scriptmenus_folder_path = ''

    def loadMenuFiles(self, name, menu):
        if not exists(self.precache_gsc_path) or not exists(self.mod_csv_path) or not exists(self.scriptmenus_folder_path):
            return

        self.updateFile(self.precache_gsc_path, f'        precachemenu("{name}");', '//-CUSTOM MENUS')
        self.updateFile(self.mod_csv_path, f'menufile,ui_mp/scriptmenus/{name}.menu', '# -MENUS')

        with open(f'{self.scriptmenus_folder_path}/{name}.menu', 'w') as file:
            file.write(str(menu))

    def updateFile(self, path, strTarget, strEnd):
        with open(path, 'r') as f:
            contents = f.readlines()

        for index in range(len(contents)):
            target = contents[index].strip()

            if target.startswith(strTarget.strip()):
                break

            if target.startswith(strEnd):
                contents.insert(index, strTarget + '\n')
                break

        with open(path, 'w') as f:
            contents = "".join(contents)
            f.write(contents)

    def loadMod(self, codPath, exeName, modFolderName):
        mod.build(codPath, exeName, modFolderName)

def createSplitBar(menu, position, index = None):
        splitbar = itemDef()
        splitbar.set = f'rect -64 {position} 301.5 5.333 1 1'
        splitbar.set = 'decoration'
        splitbar.set = 'visible 1'
        splitbar.set = 'style 3'
        splitbar.set = 'forecolor 1 1 1 1'
        splitbar.set = 'background "navbar_tick"'
        splitbar.set = 'textscale 0.5'

        if index is not None:
            splitbar.set = f'visible when (dvarInt("optionType{index}") == 2 || dvarInt("optionType{index}") == 3 || dvarInt("optionType{index}") == 5)'

        menu.add(splitbar)

def createTitle(menu, text, position):
    title = itemDef()
    title.set = f'rect -64 {position} 276.667 24.233 1 1'
    title.set = 'decoration'
    title.set = 'visible 1'
    title.set = 'style 1'
    title.set = 'forecolor 1 1 1 1'
    title.set = 'textfont 9'
    title.set = 'textalign 10'
    title.set = 'textscale 0.5'
    title.set = f'exp text ( {text} )'
    menu.add(title)

def createOption(menu, text, index, position, colorvar = False):
    option = itemDef()
    option.set = f'rect -64 {position} 276.667 19.567 1 1'
    option.set = 'decoration'
    option.set = 'visible 1'
    option.set = 'style 1'
    option.set = 'forecolor 1 1 1 1'
    option.set = 'textfont 3'
    option.set = 'textalign 10'
    option.set = 'textscale 0.375'
    option.set = f'exp text ( {text} )'
    
    if colorvar:
        option.set = f'exp forecolor r ( select(dvarInt("optionType{index}") != 0 && dvarInt("optionType{index}") != 2, select(dvarInt("optionType{index}") != 1 && dvarInt("optionType{index}") != 3, 1, 1), 0) )'
        option.set = f'exp forecolor g ( select(dvarInt("optionType{index}") != 0 && dvarInt("optionType{index}") != 2, select(dvarInt("optionType{index}") != 1 && dvarInt("optionType{index}") != 3, 0.49, 1), 0) )'
        option.set = f'exp forecolor b ( select(dvarInt("optionType{index}") != 0 && dvarInt("optionType{index}") != 2, select(dvarInt("optionType{index}") != 1 && dvarInt("optionType{index}") != 3, 0, 1), 0) )'

    option.set = f'exp forecolor a ( 1 - ( ( localvarint("ui_index") == {index} ) * ( ( sin( localclientuimilliseconds( ) / 90 ) ) * 0.65 ) ) )'
    option.set = f'visible when ( ( {text} ) != "" )'

    menu.add(option)

    optionAction = itemDef()
    optionAction.set = f'rect -68 {position + 1.333} 305.333 20 1 1'
    optionAction.set = 'visible 1'
    optionAction.set = 'type 1'

    action = itemDef('action')
    action.set = f'if (( {text} ) != "" && dvarInt("optionType{index}") != 0)'
    action.set = '{'
    action.set = '    scriptmenuresponse localvarint( "ui_index" );'
    action.set = '    play "mouse_click";'
    action.set = '}'
    optionAction.add(action)

    mouseEnter = itemDef('mouseEnter')
    mouseEnter.set = f'if (( {text} ) != "")'
    mouseEnter.set = '{'
    mouseEnter.set = f'    setLocalVarInt "ui_index" {index};'
    mouseEnter.set = '    play "mouse_over";'
    mouseEnter.set = '}'
    mouseEnter.set = f'setdvar "ui_startIndex" {index};'
    optionAction.add(mouseEnter)

    mouseExit = itemDef('mouseExit')
    mouseExit.set = f'if (( {text} ) != "")'
    mouseExit.set = '{'
    mouseExit.set = '    play "mouse_over";'
    mouseExit.set = '}'
    mouseExit.set = 'setLocalVarInt "ui_index" -1;'
    mouseExit.set = 'setdvar "ui_startIndex" -1;'
    optionAction.add(mouseExit)
    
    menu.add(optionAction)