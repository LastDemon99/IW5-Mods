dynamic_properties = ["exp_rect_x", "exp_rect_y", "exp_rect_h", "exp_rect_w", "exp_forecolor_r", "exp_forecolor_g", "exp_forecolor_b", "exp_forecolor_a", "exp_text", "exp_material"]
item_actions = ["onOpen", "onClose", "onEsc", "mouseEnter", "mouseExit", "action"]
item_properties = ["name", "rect", "decoration", "autowrapped", "visible", "ownerdraw", "style", "type", "forecolor", "blurWorld", "border", "bordercolor", "background", "textfont", "textalign", "textscale", "textstyle", "text"] + dynamic_properties + item_actions


def generate_getter(property_name):
    def getter(self):
        return getattr(self, "_" + property_name)
    return getter

def generate_setter(property_name):
    def setter(self, value):
        setattr(self, "_" + property_name, value)
    return setter

class ItemDef:
    def __init__(self, item='itemDef', name=None, rect=(0, 0, 640, 480, 0, 0), decoration=True, visible=True, style=1, forecolor=(1, 1, 1, 1)):
        for p_name in item_properties:
            self.__add_property(p_name)
            setattr(self, p_name, None)

        if name is not None:
            self.name = f'"{name}"'

        self._item = item
        self.rect = rect
        self.decoration = decoration
        self.visible = visible
        self.style = style
        self.forecolor = forecolor
        self.mouseEnter = SimpleItem('mouseEnter', 1)
        self.mouseExit = SimpleItem('mouseExit', 1)
        self.action = SimpleItem('action', 1)
        self._itemDefs = []

    def add(self, ItemDef):
       self._itemDefs.append(ItemDef)
            
    def __add_property(self, property_name):
        setattr(ItemDef, property_name, property(generate_getter(property_name), generate_setter(property_name)))

    def dynamicForeColor(self, index):
        self.exp_forecolor_r = f'select(dvarInt("optionType{index}") < 2, 0, 1)'
        self.exp_forecolor_g = f'select(dvarInt("optionType{index}") < 4, 0, select(dvarInt("optionType{index}") < 6, 1, 0.4))'
        self.exp_forecolor_b = f'select(dvarInt("optionType{index}") == 4 || dvarInt("optionType{index}") == 5, 1, 0)'
        self.exp_forecolor_a = f'1 - ( ( localVarInt("ui_index") == {index} ) * ( ( sin( localclientuimilliseconds( ) / 90 ) ) * 0.65 ) )'
        self.visible_when = f'localVarString("menu_option{index}") != ""'

    def __str__(self):
        data = []
        
        for name in item_properties:
            value = getattr(self, name)
                
            if value is None:
                continue

            if name in item_actions and not len(value.lines):
                continue

            if name in dynamic_properties:
                value = f'( {value} )'

            if name == 'textstyle' and value == 0:
                continue

            if name == 'decoration' or name == 'autowrapped':
                value = '' if value else None

            if name == 'visible':
                value = 1 if value else None

            if value is None:
                continue

            _type = type(value)
            name = ' '.join(name.split('_'))

            if _type is str or _type is int or _type is float:
                data.append(f'    {name} {value}')
            elif _type is tuple or _type is list:
                data.append(f'    {name} ' + ' '.join(str(i) for i in value))
            elif _type is ItemDef or _type is SimpleItem:
                [data.append('    ' + i) for i in str(value).split('\n')]

        for i in self._itemDefs:
            [data.append('    ' + j) for j in str(i).split('\n')]

        if self._item == "menuDef":
            item = '\nmenuDef\n{\n' + '\n'.join(data) + '\n}'
            return '/* Menu building tool by LastDemon99 */ \n/* https://github.com/LastDemon99/IW5_Mods/tree/main/EasyMenuBuilder */ \n\n{' + '\n'.join(["    " + i for i in item.split('\n')]) + '\n}'
        else:
            return '\n' + self._item + '\n{\n' + '\n'.join(data) + '\n}'

class MenuDef(ItemDef):
    def __init__(self, **kwargs):
        super().__init__(item='menuDef', **kwargs)   
        
        self.decoration = None
        self.visible = None
        self.style = None
        self.onOpen = SimpleItem('onOpen', 1)
        self.onClose = SimpleItem('onClose', 1)
        self.onEsc = SimpleItem('onEsc', 1)

    def addImage(self, **kwargs):
        item = Image(**kwargs)
        self.add(item)
        return item

    def addText(self, **kwargs):
        item = Text(**kwargs)
        self.add(item)
        return item

    def addItem(self, **kwargs):
        item = ItemDef(**kwargs)
        self.add(item)
        return item

    def addDynamicsOptions(self, start, offset, amount):
        options = []        
        pos = start[1]
        for i in range(amount):
            _rect = list(start)
            _rect[1] = pos
            options.append(self.addDynamicOption(_rect, i))
            pos += offset
        return options

    def addDynamicOption(self, _rect, i):
        _text = localVarString(f'menu_option{i}')

        option = self.addText(rect=_rect, text=_text, exp=1)
        option.dynamicForeColor(1)
        option.mouseEnter.If(f'{_text} != ""', setLocalVarInt('ui_index', i), play('mouse_click'))
        option.mouseExit.If(f'{_text} != ""', setLocalVarInt('ui_index', -1), play('mouse_click'))

        onClick = self.addItem(rect=_rect, decoration=0, forecolor=None)
        onClick.action.If(f'{_text} != ""', scriptmenuresponse(localVarInt('ui_index')), play('mouse_click'))
        onClick.action.set = setDvar('ui_startIndex', i)

        return option, onClick

class Image(ItemDef):
    def __init__(self, image=None, material=0, ownerdraw=None, **kwargs):
        super().__init__(**kwargs)

        if ownerdraw is None:
            self.style = 3

            if image is None:
                image = 'white'

            if material:
                self.exp_material = image
            else:
                self.background = f'"{image}"'
        else:
            self.ownerdraw = ownerdraw
            self.decoration = None
            self.style = None
            self.background = f'"{image}"'

class Text(ItemDef):
    def __init__(self, textfont=3, textalign=8, textscale=0.375, textstyle=0, text=None, exp=0, ownerdraw=None, **kwargs):
        super().__init__(**kwargs)

        self.textfont = textfont
        self.textalign = textalign
        self.textscale = textscale
        self.textstyle = textstyle

        if ownerdraw is not None:
            self.ownerdraw = ownerdraw
            self.style = None

        if text is None:
            return

        if exp:
            self.exp_text = text
        else:
            self.text = f'"{text}"'

class SimpleItem():
    def __init__(self, header='itemDef', jumpLine=0, lines=None):
        self.header = header
        self.jumpLine = jumpLine
        self.lines = lines if lines else []

    def If(self, condition, *lines):
        self.appendItem(f'if ( {condition} )', *lines)

    def Else_If(self, condition, *lines):
        self.appendItem(f'else if ( {condition} )', *lines)

    def Else(self, *lines):
        self.appendItem(f'else', *lines)

    def appendItem(self, header, *lines):
        if isinstance(lines, str):
            lines = (lines,)
        self.set = SimpleItem(header, 0, lines)

    @property
    def values(self, index):
        return self.lines[index]

    @values.setter
    def set(self, value):
        _type = type(value)

        if _type is str:
            self.lines.append(value)
        elif _type is tuple:
            self.lines += [i for i in value]
        elif _type is SimpleItem:
            self.lines += [i for i in str(value).split('\n')]

    def __str__(self):
        if self.jumpLine:
            return '\n' + self.header + '\n{\n    ' + '\n    '.join(self.lines) + '\n}'
        else:
            return self.header + '\n{\n    ' + '\n    '.join(self.lines) + '\n}'


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