"""
material class
"""

class itemDef:
    def __init__(self, type = 'itemDef', index = -1):
        self._item = type
        self._values = [''] * 12
        self._values2 = [''] * 9

        self._itemsDefCount = 0
        self._itemsDef = { 'action': None,
            'mouseEnter': None,
            'mouseExit': None,
            'execKeyInt': None }
        
    def add(self, itemDef):
        data = str(itemDef).split('\n')
        type = data[4] if data[4] == '    menuDef' else data[1]

        if type == 'itemDef':
            self._itemsDef[self._itemsDefCount] = itemDef
            self._itemsDefCount += 1
        else:
            self._itemsDef[type] = itemDef

    def addItem(self, type, lines):
        self.add(createItem(type, lines))

    def insert(self, key, itemDef):
        self._itemsDef[key] = itemDef
        
    def insertItem(self, index, type, lines):             
        self.insert(index, createItem(type, lines))
    
    def getItem(self, key):
        return self._itemsDef[key]

    def setBorder(self, type = 1, size = 1, color = (1, 1, 1, 1)):
        self.border = type
        self.bordersize = size
        self.bordercolor = color
        
    def __getRectValue(self, index):
        return self._values[1].split()[index + 1]
        
    def __setRectValue(self, index, value):
        rect = self.rect.split()[1:]
        rect[index] = str(value)    
        self._values[1] = '    rect ' + " ".join(i for i in rect)
    
    @property
    def action(self):
        return self.getItem('action')

    @action.setter
    def action(self, lines):
        self.addItem('action', lines)

    @property
    def mouseEnter(self):
        return self.getItem('mouseEnter')

    @mouseEnter.setter
    def mouseEnter(self, lines):
        self.addItem('mouseEnter', lines)

    @property
    def mouseExit(self):
        return self.getItem('mouseExit')

    @mouseExit.setter
    def mouseExit(self, lines):
        self.addItem('mouseExit', lines)

    @property
    def expRectX(self):
        return self._values2[0]

    @expRectX.setter
    def expRectX(self, value):
        self._values2[0] = f'    exp rect x ({value})'
        
    @property
    def expRectY(self):
        return self._values2[1]

    @expRectY.setter
    def expRectY(self, value):
        self._values2[1] = f'    exp rect y ({value})'
        
    @property
    def expRectH(self):
        return self._values2[2]

    @expRectH.setter
    def expRectH(self, value):
        self._values2[2] = f'    exp rect h ({value})'
        
    @property
    def expRectW(self):
        return self._values2[3]

    @expRectW.setter
    def expRectW(self, value):
        self._values2[3] = f'    exp rect w ({value})'
        
    @property
    def expForecolorR(self):
        return self._values2[4]

    @expForecolorR.setter
    def expForecolorR(self, value):
        self._values2[4] = f'    exp forecolor r ({value})'
        
    @property
    def expForecolorG(self):
        return self._values2[5]

    @expForecolorG.setter
    def expForecolorG(self, value):
        self._values2[5] = f'    exp forecolor g ({value})'
        
    @property
    def expForecolorB(self):
        return self._values2[6]

    @expForecolorB.setter
    def expForecolorB(self, value):
        self._values2[6] = f'    exp forecolor b ({value})'
        
    @property
    def expForecolorA(self):
        return self._values2[7]

    @expForecolorA.setter
    def expForecolorA(self, value):
        self._values2[7] = f'    exp forecolor a ({value})'
    
    @property
    def visibleWhen(self):
        return self._values2[8]

    @visibleWhen.setter
    def visibleWhen(self, value):
        self._values2[8] = f'    visible when ( {value} )'

    @property
    def name(self):
        return self._values[0]

    @name.setter
    def name(self, value):
        self._values[0] = f'    name "{value}"'
        
    @property
    def rect(self):
        return self._values[1]
    
    @rect.setter
    def rect(self, value):
        self._values[1] = '    rect ' + " ".join(str(i) for i in value)
        
    @property
    def x(self):
        return self.__getRectValue(0)
    
    @x.setter
    def x(self, value):
        self.__setRectValue(0, value)
        
    @property
    def y(self):
        return self.__getRectValue(1)
    
    @y.setter
    def y(self, value):
        self.__setRectValue(1, value)
        
    @property
    def width(self):
        return self.__getRectValue(2)
    
    @width.setter
    def width(self, value):
        self.__setRectValue(2, value)
        
    @property
    def height(self):
        return self.__getRectValue(3)
    
    @height.setter
    def height(self, value):
        self.__setRectValue(3, value)
        
    @property
    def height(self):
        return self.__getRectValue(3)
    
    @height.setter
    def height(self, value):
        self.__setRectValue(3, value)
        
    @property
    def horizontalAlign(self):
        return self.__getRectValue(4)
    
    @horizontalAlign.setter
    def horizontalAlign(self, value):
        self.__setRectValue(4, value)
        
    @property
    def verticalAlign(self):
        return self.__getRectValue(5)
    
    @verticalAlign.setter
    def verticalAlign(self, value):
        self.__setRectValue(5, value)
    
    @property
    def decoration(self):
        return self._values[2]
    
    @decoration.setter
    def decoration(self, value):
        self._values[2] = '    decoration' if value else ''
        
    @property
    def visible(self):
        return self._values[3]
    
    @visible.setter
    def visible(self, value):
        self._values[3] = '    visible 1' if value else ''
    
    @property
    def style(self):
        return self._values[4]
        
    @style.setter
    def style(self, value):
        self._values[4] = f'    style {value}'
        
    @property
    def type(self):
        return self._values[5]
        
    @type.setter
    def type(self, value):
        self._values[5] = f'    type {value}'
    
    @property
    def forecolor(self):
        return self._values[6]
    
    @forecolor.setter
    def forecolor(self, value):
        self._values[6] = '    forecolor ' + " ".join(str(i) for i in value)
        
    @property
    def border(self):
        return self._values[7]
        
    @border.setter
    def border(self, value):
        self._values[7] = f'    border {value}'
        
    @property
    def bordersize(self):
        return self._values[8]
        
    @bordersize.setter
    def bordersize(self, value):
        self._values[8] = f'    bordersize {value}'
        
    @property
    def bordercolor(self):
        return self._values[9]
    
    @bordercolor.setter
    def bordercolor(self, value):
        self._values[9] = '    bordercolor ' + " ".join(str(i) for i in value)

    @property
    def background(self):
        return self._values[10]
    
    @background.setter
    def background(self, value):
        self._values[10] = f'    background "{value}"'

    @property
    def values(self, index):
        return self._values[index]

    @values.setter
    def set(self, value):
        self._values.append(f'    {value}')

    def __str__(self):
        export = self._values + self._values2
        
        for itemdef in self._itemsDef.values():
            if itemdef is None:
                continue

            export.append('    ')
            [export.append('    ' + i) for i in str(itemdef).split('\n') if i != '']
    
        return '\n' + self._item + '\n{\n' + '\n'.join([i for i in export if i != '']) + '\n}'

class background(itemDef):
    def __init__(self,
        rect = (0, 0, 640, 480, 0, 0),
        decoration = True,
        visible = True,
        style = 3,
        forecolor = (1, 1, 1, 1),
        background = 'white'):
    
        self._item = 'itemDef'
        self._values = [''] * 12
        self._values2 = [''] * 9

        self._itemsDefCount = 0
        self._itemsDef = { 'action': None,
            'mouseEnter': None,
            'mouseExit': None,
            'execKeyInt': None }
        
        self.rect = rect
        self.decoration = decoration
        self.visible = visible
        self.style = style
        self.forecolor = forecolor
        self.background = background
        
class text(itemDef):
    def __init__(self, 
        rect = (0, 0, 640, 480, 0, 0),
        decoration = True,
        visible = True,
        style = 1,
        forecolor = (1, 1, 1, 1),
        textfont = 3,
        textalign = 8,
        textscale = 0.375,
        textstyle = 0,
        text = '""',
        exp = 0):        
        
        self._item = 'itemDef'
        self._values = [''] * 17
        self._values2 = [''] * 9

        self._itemsDefCount = 0
        self._itemsDef = { 'action': None,
            'mouseEnter': None,
            'mouseExit': None,
            'execKeyInt': None }
        self._isExp = exp
        
        self.rect = rect
        self.decoration = decoration
        self.visible = visible
        self.style = style
        self.forecolor = forecolor
        self.textfont = textfont
        self.textalign = textalign
        self.textscale = textscale
        self.textstyle = textstyle
        self.text = text
    
    @property
    def textfont(self):
        return self._values[11]
    
    @textfont.setter
    def textfont(self, value):
        self._values[11] = f'    textfont {value}'
    
    @property
    def textalign(self):
        return self._values[12]
    
    @textalign.setter
    def textalign(self, value):
        self._values[12] = f'    textalign {value}'
    
    @property
    def textscale(self):
        return self._values[13]
    
    @textscale.setter
    def textscale(self, value):
        self._values[13] = f'    textscale {value}'

    @property
    def textstyle(self):
        return self._values[14]
    
    @textstyle.setter
    def textstyle(self, value):
        self._values[14] = f'    textstyle {value}'
        
    @property
    def text(self):
        return self._values[15]
    
    @text.setter
    def text(self, value):
        self._values[15] = f'    exp text ( {value} )' if self._isExp else f'    text {value}'
        
class ownerdraw(text):
    def __init__(self,
        rect = (0, 0, 640, 480, 0, 0),
        decoration = True,
        visible = True,
        forecolor = (1, 1, 1, 1),
        type = 8,
        isText = False,
        textfont = 3,
        textalign = 8,
        textscale = 0.375,
        textstyle = 0,
        ownerdraw = 0):
    
        self._item = 'itemDef'
        self._values = [''] * 18
        self._values2 = [''] * 9

        self._itemsDefCount = 0
        self._itemsDef = { 'action': None,
            'mouseEnter': None,
            'mouseExit': None,
            'execKeyInt': None }
        
        self.rect = rect
        self.decoration = decoration
        self.visible = visible
        self.forecolor = forecolor
        self.type = type      
        
        if isText:
            self.textfont = textfont
            self.textalign = textalign
            
        self.textscale = textscale
        self.textstyle = textstyle
        self._values[15] = ''
        self.ownerdraw = ownerdraw
        
    @property
    def ownerdraw(self):
        return self._values[16]
    
    @ownerdraw.setter
    def ownerdraw(self, value):
        self._values[16] = f'    ownerdraw {value}'

class menuDef(itemDef):
    def __init__(self, name = '',
        rect = (0, 0, 640, 480, 0, 0),
        forecolor = (1, 1, 1, 1)):
        
        self._item = 'menuDef'
        self._values = [''] * 12
        self._values2 = [''] * 9
        self._blurworld = ''

        self._itemsDefCount = 0
        self._itemsDef = { 'action': None,
            'mouseEnter': None,
            'mouseExit': None,
            'onOpen': None,
            'onClose': None,
            'onEsc': None,
            'execKeyInt': None }
        
        self.name = name
        self.rect = rect
        self.forecolor = forecolor

    @property
    def onOpen(self):
        return self.getItem('onOpen')

    @onOpen.setter
    def onOpen(self, lines):
        self.addItem('onOpen', lines)
    
    @property
    def onClose(self):
        return self.getItem('onClose')

    @onClose.setter
    def onClose(self, lines):
        self.addItem('onClose', lines)

    @property
    def onEsc(self):
        return self.getItem('onEsc')

    @onEsc.setter
    def onEsc(self, lines):
        self.addItem('onEsc', lines)

    @property
    def execKeyInt(self, keyint):
        return self.getItem(f'execKeyInt {keyint}')

    @execKeyInt.setter
    def execKeyInt(self, keyint, lines):
        self.addItem(f'execKeyInt {keyint}', lines)

    @property
    def blurWorld(self):
        return self._blurworld
    
    @blurWorld.setter
    def blurWorld(self, value):
        self._blurworld = f'    blurWorld {value}'

    def optionForeColor(self, option, index):
        option.expForecolorR = f'select(dvarInt("optionType{index}") < 2, 0, 1)'
        option.expForecolorG = f'select(dvarInt("optionType{index}") < 4, 0, select(dvarInt("optionType{index}") < 6, 1, 0.4))'
        option.expForecolorB = f'select(dvarInt("optionType{index}") == 4 || dvarInt("optionType{index}") == 5, 1, 0)'
        option.expForecolorA = f'1 - ( ( localvarint("ui_index") == {index} ) * ( ( sin( localclientuimilliseconds( ) / 90 ) ) * 0.65 ) )'
        option.visibleWhen = f'dvarstring( "menu_option{index}" ) != ""'

    def addDynamicOption(self, _rect, i):
        _text = dvarString(f'menu_option{i}')
        _type = dvarInt(f'optionType{i}')

        textOption = text(rect=_rect, text=_text, exp=1)
        self.optionForeColor(textOption, i)
        
        textOption.mouseEnter = _if(
            f'( {_text} ) != ""',
            setLocalVarInt('ui_index', i),
            play('mouse_click')
        )
        
        textOption.mouseExit = _if(
            f'( {_text} ) != ""',
            setLocalVarInt('ui_index', -1),
            play('mouse_click')
        )
        self.add(textOption)

        optionAction = itemDef()
        optionAction.rect = _rect
        optionAction.visible = 1
        optionAction.type = 1

        optionAction.action = _if(
            f'( {_text} ) != "" && dvarInt("optionType{i}") != 0',
            scriptmenuresponse(localVarInt('ui_index')),
            play('mouse_click')
        )

        action = optionAction.action
        action.set = setDvar('ui_startIndex', i)
        self.add(optionAction)

        return [textOption, optionAction]

    def addDynamicsOptions(self, start, offset, amount):
        options = []        
        pos = start[1]
        for i in range(amount):
            _rect = list(start)
            _rect[1] = pos
            options.append(self.addDynamicOption(_rect, i))
            pos += offset
        return options
        
    def __str__(self):
        export = self._values
        export.append(self._blurworld)
        export = export + self._values2
        
        for itemdef in self._itemsDef.values():
            if itemdef is None:
                continue

            export.append('    ')
            [export.append('    ' + i) for i in str(itemdef).split('\n') if i != '']
          
        return '/* Menu building tool by LastDemon99 */ \n/* https://github.com/LastDemon99/IW5_Mods/tree/main/DynamicMenus */ \n\n{\n    ' + self._item + '\n    {\n' + '\n'.join(['    ' + i for i in export if i != '']) + '\n    }\n}'

class mainMenu(menuDef):
    def __init__(self, name = ''):
    
        self._item = 'menuDef'
        self._values = [''] * 12
        self._values2 = [''] * 9
        self._blurworld = ''

        self._itemsDefCount = 0
        self._itemsDef = { 'action': None,
            'mouseEnter': None,
            'mouseExit': None,
            'onOpen': None,
            'onClose': None,
            'onEsc': None,
            'execKeyInt': None }
        
        self.name = name
        self.rect = (0, 0, 640, 480, 0, 0)
        self.forecolor = (1, 1, 1, 1)
        self.blurWorld = 4.8
        
        self.onOpen = setLocalVarInt('ui_index', dvarInt('ui_startIndex'))
        self.onEsc = scriptmenuresponse('"back"')
        
        leftPanel = background(rect=(-64, -36, 301.5, 480, 1, 1), forecolor=(0, 0, 0, 0.4))
        self.add(leftPanel)

        panelShadow = background(rect=(237.5, -236, 13, 680, 1, 1),
            forecolor=(1, 1, 1, 0.75),
            background='navbar_edge')
        self.add(panelShadow)

        navBar = background(rect=(-88, 34.667, 325.333, 17.333, 1, 1), background='navbar_selection_bar')
        navBar.expRectY = '20 * localvarint("ui_index") + 34.667'
        navBar.visibleWhen = 'localvarint("ui_index") >= 0'
        self.add(navBar)

        navBarShadow = background(rect=(-88, 52, 325.333, 8.666, 1, 1),
            background='navbar_selection_bar_shadow')
        navBarShadow.expRectY = '20 * localvarint("ui_index") + 52'
        navBarShadow.visibleWhen = 'localvarint("ui_index") >= 0'
        self.add(navBarShadow)


    def createTittle(self, index, _text):
        pos = 3 if not index else (20 * index) + 42.901

        title = text(rect=(-64, pos, 276.667, 24.233, 1, 1),
            textfont=9,
            textalign=10,
            textscale=0.5,
            text=_text,
            exp=1)
        return title

    def createOption(self, index, title_index=0):
        pos = (20 * index) + 33.334 if not title_index else (20 * index) + 73.235

        option = self.addDynamicOption((-64, pos, 276.667, 19.567, 1, 1), index)
        textOption = option[0]
        textOption.textfont = 3
        textOption.textalign = 10

        return [textOption, option[1]]

    def createSplitBar(self, index, title_split=0):
        offset = 30 if title_split else 51.5

        splitbar = background(rect=(-64, (20 * index) + offset, 301.5, 5.333, 1, 1),
            background='navbar_tick')
        return splitbar


def createItem(type, lines):
    if isinstance(lines, str):
        lines = (lines,)

    item = itemDef(type)
    for line in lines:
        item.set = line
    return item

def _if(condition, *lines):
    if isinstance(lines, str):
        lines = (lines,)

    data = [f'if ( {condition} )', '{']
    for i in lines:
        data.append('    ' + i)
    data.append('}')

    return data

def _else(*lines):
    if isinstance(lines, str):
        lines = (lines,)

    data = ['else', '{']
    for i in lines:
        data.append('    ' + i)
    data.append('}')

    return data

def exec(val):
    return f'exec "{val}";'

def play(val):
    return f'play "{val}";'

def setDvar(var, val):
    return f'setdvar {var} {val};'

def setLocalVarInt(var, val):
    return f'setLocalVarInt {var} {val};'
    
def setLocalVarString(var, val):
    return f'setLocalVarString {var} {val};'

def localVarInt(var):
    return f'localVarInt( "{var}" )' if ' + ' not in var else f'localVarInt( {var} )'

def localVarString(var):
    return f'localVarString( "{var}" )' if ' + ' not in var else f'localVarString( {var} )'

def dvarInt(var):
    return f'dvarInt( "{var}" )' if ' + ' not in var else f'dvarInt( {var} )'
    
def dvarString(var):
    return f'dvarString( "{var}" )' if ' + ' not in var else f'dvarString( {var} )'
    
def scriptmenuresponse(val):
    return f'scriptmenuresponse {val};'