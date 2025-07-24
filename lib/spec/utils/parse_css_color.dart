import 'package:granite/spec/spec.dart' as spec;

/// Parses a value or a percentage given in [v]. Remaps the resulting value to a range of `[0; 1]`:
/// - If the value was a percentage, it's returned as is (in range 0-1).
/// - If the value was a number, it's divided by [max] and returned.
double _parseValueOrPercentage(String v, [double max = 1]) {
  if (v.endsWith('%')) {
    return double.parse(v.substring(0, v.length - 1)) / 100;
  } else {
    return double.parse(v) / max;
  }
}

/// Parses a given HTML-like hex color string [hex] and returns a [Color] object.
/// 
/// The hex string should start with a `#` character and can be in the following formats:
/// - `#RGB` (-> RRGGBB)
/// - `#RGBA` (-> RRGGBBAA)
/// - `#RRGGBB`
/// - `#RRGGBBAA`
spec.Color _parseHexColor(String hex) {
  assert(hex.startsWith('#'));

  final value = hex.substring(1);
  int r, g, b;
  int? a;

  if (value.length == 3) {
    r = int.parse('${value[0]}${value[0]}', radix: 16);
    g = int.parse('${value[1]}${value[1]}', radix: 16);
    b = int.parse('${value[2]}${value[2]}', radix: 16);
  } else if (value.length == 4) {
    r = int.parse('${value[0]}${value[0]}', radix: 16);
    g = int.parse('${value[1]}${value[1]}', radix: 16);
    b = int.parse('${value[2]}${value[2]}', radix: 16);
    a = int.parse('${value[3]}${value[3]}', radix: 16);
  } else if (value.length == 6) {
    r = int.parse(value.substring(0, 2), radix: 16);
    g = int.parse(value.substring(2, 4), radix: 16);
    b = int.parse(value.substring(4, 6), radix: 16);
  } else if (value.length == 8) {
    r = int.parse(value.substring(0, 2), radix: 16);
    g = int.parse(value.substring(2, 4), radix: 16);
    b = int.parse(value.substring(4, 6), radix: 16);
    a = int.parse(value.substring(6, 8), radix: 16);
  } else {
    throw ArgumentError.value(hex, 'hex', 'Invalid hex color format');
  }

  return spec.Color(r: r / 255, g: g / 255, b: b / 255, a: a != null ? a / 255 : 1.0);
}

/// Parses a given css-like color string. Supported formats are:
/// - hex color: `#RGB`, `#RGBA`, `#RRGGBB`, `#RRGGBBAA`
/// - rgb/rgba: `rgb(r, g, b)`, `rgba(r, g, b, a)` (both percentage and numbers are supported)
/// - hsl/hsla: `hsl(h, s, l)`, `hsla(h, s, l, a)` (both percentage and numbers are supported)
spec.Color parseCssColor(String css) {
  final _css = css.toLowerCase();

  // Hex color:
  // - #RGB (-> RRGGBB)
  // - #RGBA (-> RRGGBBAA)
  // - #RRGGBB
  // - #RRGGBBAA
  if (_css.startsWith('#')) {
    return _parseHexColor(_css);
  }
  // rgb or rgba
  else if (_css.startsWith('rgb')) {
    double r, g, b;
    double? a;

    final values = _css.split('(')[1].split(')')[0].split(',').map((v) => v.trim()).toList();
    if (values.length != 3 && values.length != 4) {
      throw ArgumentError.value(css, 'css', 'Invalid rgb/rgba color format');
    }

    r = _parseValueOrPercentage(values[0], 255.0);
    g = _parseValueOrPercentage(values[1], 255.0);
    b = _parseValueOrPercentage(values[2], 255.0);
    a = values.length == 4 ? _parseValueOrPercentage(values[3], 1.0) : null;

    return spec.Color(r: r, g: g, b: b, a: a ?? 1.0);
  }
  // hsl or hsla
  else if (_css.startsWith('hsl')) {
    double h, s, l;
    double? a;

    final values = _css.split('(')[1].split(')')[0].split(',').map((v) => v.trim()).toList();
    if (values.length != 3 && values.length != 4) {
      throw ArgumentError.value(css, 'css', 'Invalid hsl/hsla color format');
    }

    h = _parseValueOrPercentage(values[0], 360.0);
    s = _parseValueOrPercentage(values[1]);
    l = _parseValueOrPercentage(values[2]);
    a = values.length == 4 ? _parseValueOrPercentage(values[3], 1.0) : null;

    return spec.Color.fromHsl(h, s, l, a ?? 1.0);
  }
  // Named color
  else {
    if (_namedColorsMap.containsKey(_css)) {
      return _namedColorsMap[_css]!;
    } else {
      throw ArgumentError.value(css, 'css', 'Unknown named color');
    }
  }
}

final _namedColorsMap = {
  'aliceblue': _parseHexColor('#f0f8ff'),
  'antiquewhite': _parseHexColor('#faebd7'),
  'aqua': _parseHexColor('#00ffff'),
  'aquamarine': _parseHexColor('#7fffd4'),
  'azure': _parseHexColor('#f0ffff'),
  'beige': _parseHexColor('#f5f5dc'),
  'bisque': _parseHexColor('#ffe4c4'),
  'black': _parseHexColor('#000000'),
  'blanchedalmond': _parseHexColor('#ffebcd'),
  'blue': _parseHexColor('#0000ff'),
  'blueviolet': _parseHexColor('#8a2be2'),
  'brown': _parseHexColor('#a52a2a'),
  'burlywood': _parseHexColor('#deb887'),
  'cadetblue': _parseHexColor('#5f9ea0'),
  'chartreuse': _parseHexColor('#7fff00'),
  'chocolate': _parseHexColor('#d2691e'),
  'coral': _parseHexColor('#ff7f50'),
  'cornflowerblue': _parseHexColor('#6495ed'),
  'cornsilk': _parseHexColor('#fff8dc'),
  'crimson': _parseHexColor('#dc143c'),
  'cyan': _parseHexColor('#00ffff'),
  'darkblue': _parseHexColor('#00008b'),
  'darkcyan': _parseHexColor('#008b8b'),
  'darkgoldenrod': _parseHexColor('#b8860b'),
  'darkgray': _parseHexColor('#a9a9a9'),
  'darkgreen': _parseHexColor('#006400'),
  'darkkhaki': _parseHexColor('#bdb76b'),
  'darkmagenta': _parseHexColor('#8b008b'),
  'darkolivegreen': _parseHexColor('#556b2f'),
  'darkorange': _parseHexColor('#ff8c00'),
  'darkorchid': _parseHexColor('#9932cc'),
  'darkred': _parseHexColor('#8b0000'),
  'darksalmon': _parseHexColor('#e9967a'),
  'darkseagreen': _parseHexColor('#8fbc8f'),
  'darkslateblue': _parseHexColor('#483d8b'),
  'darkslategray': _parseHexColor('#2f4f4f'),
  'darkturquoise': _parseHexColor('#00ced1'),
  'darkviolet': _parseHexColor('#9400d3'),
  'deeppink': _parseHexColor('#ff1493'),
  'deepskyblue': _parseHexColor('#00bfff'),
  'dimgray': _parseHexColor('#696969'),
  'dodgerblue': _parseHexColor('#1e90ff'),
  'firebrick': _parseHexColor('#b22222'),
  'floralwhite': _parseHexColor('#fffaf0'),
  'forestgreen': _parseHexColor('#228b22'),
  'fuchsia': _parseHexColor('#ff00ff'),
  'gainsboro': _parseHexColor('#dcdcdc'),
  'ghostwhite': _parseHexColor('#f8f8ff'),
  'gold': _parseHexColor('#ffd700'),
  'goldenrod': _parseHexColor('#daa520'),
  'gray': _parseHexColor('#808080'),
  'green': _parseHexColor('#008000'),
  'greenyellow': _parseHexColor('#adff2f'),
  'honeydew': _parseHexColor('#f0fff0'),
  'hotpink': _parseHexColor('#ff69b4'),
  'indianred': _parseHexColor('#cd5c5c'),
  'indigo': _parseHexColor('#4b0082'),
  'ivory': _parseHexColor('#fffff0'),
  'khaki': _parseHexColor('#f0e68c'),
  'lavender': _parseHexColor('#e6e6fa'),
  'lavenderblush': _parseHexColor('#fff0f5'),
  'lawngreen': _parseHexColor('#7cfc00'),
  'lemonchiffon': _parseHexColor('#fffacd'),
  'lightblue': _parseHexColor('#add8e6'),
  'lightcoral': _parseHexColor('#f08080'),
  'lightcyan': _parseHexColor('#e0ffff'),
  'lightgoldenrodyellow': _parseHexColor('#fafad2'),
  'lightgray': _parseHexColor('#d3d3d3'),
  'lightgreen': _parseHexColor('#90ee90'),
  'lightpink': _parseHexColor('#ffb6c1'),
  'lightsalmon': _parseHexColor('#ffa07a'),
  'lightseagreen': _parseHexColor('#20b2aa'),
  'lightskyblue': _parseHexColor('#87cefa'),
  'lightslategray': _parseHexColor('#778899'),
  'lightsteelblue': _parseHexColor('#b0c4de'),
  'lightyellow': _parseHexColor('#ffffe0'),
  'lime': _parseHexColor('#00ff00'),
  'limegreen': _parseHexColor('#32cd32'),
  'linen': _parseHexColor('#faf0e6'),
  'magenta': _parseHexColor('#ff00ff'),
  'maroon': _parseHexColor('#800000'),
  'mediumaquamarine': _parseHexColor('#66cdaa'),
  'mediumblue': _parseHexColor('#0000cd'),
  'mediumorchid': _parseHexColor('#ba55d3'),
  'mediumpurple': _parseHexColor('#9370db'),
  'mediumseagreen': _parseHexColor('#3cb371'),
  'mediumslateblue': _parseHexColor('#7b68ee'),
  'mediumspringgreen': _parseHexColor('#00fa9a'),
  'mediumturquoise': _parseHexColor('#48d1cc'),
  'mediumvioletred': _parseHexColor('#c71585'),
  'midnightblue': _parseHexColor('#191970'),
  'mintcream': _parseHexColor('#f5fffa'),
  'mistyrose': _parseHexColor('#ffe4e1'),
  'moccasin': _parseHexColor('#ffe4b5'),
  'navajowhite': _parseHexColor('#ffdead'),
  'navy': _parseHexColor('#000080'),
  'oldlace': _parseHexColor('#fdf5e6'),
  'olive': _parseHexColor('#808000'),
  'olivedrab': _parseHexColor('#6b8e23'),
  'orange': _parseHexColor('#ffa500'),
  'orangered': _parseHexColor('#ff4500'),
  'orchid': _parseHexColor('#da70d6'),
  'palegoldenrod': _parseHexColor('#eee8aa'),
  'palegreen': _parseHexColor('#98fb98'),
  'paleturquoise': _parseHexColor('#afeeee'),
  'palevioletred': _parseHexColor('#db7093'),
  'papayawhip': _parseHexColor('#ffefd5'),
  'peachpuff': _parseHexColor('#ffdab9'),
  'peru': _parseHexColor('#cd853f'),
  'pink': _parseHexColor('#ffc0cb'),
  'plum': _parseHexColor('#dda0dd'),
  'powderblue': _parseHexColor('#b0e0e6'),
  'purple': _parseHexColor('#800080'),
  'rebeccapurple': _parseHexColor('#663399'),
  'red': _parseHexColor('#ff0000'),
  'rosybrown': _parseHexColor('#bc8f8f'),
  'royalblue': _parseHexColor('#4169e1'),
  'saddlebrown': _parseHexColor('#8b4513'),
  'salmon': _parseHexColor('#fa8072'),
  'sandybrown': _parseHexColor('#f4a460'),
  'seagreen': _parseHexColor('#2e8b57'),
  'seashell': _parseHexColor('#fff5ee'),
  'sienna': _parseHexColor('#a0522d'),
  'silver': _parseHexColor('#c0c0c0'),
  'skyblue': _parseHexColor('#87ceeb'),
  'slateblue': _parseHexColor('#6a5acd'),
  'slategray': _parseHexColor('#708090'),
  'snow': _parseHexColor('#fffafa'),
  'springgreen': _parseHexColor('#00ff7f'),
  'steelblue': _parseHexColor('#4682b4'),
  'tan': _parseHexColor('#d2b48c'),
  'teal': _parseHexColor('#008080'),
  'thistle': _parseHexColor('#d8bfd8'),
  'tomato': _parseHexColor('#ff6347'),
  'turquoise': _parseHexColor('#40e0d0'),
  'violet': _parseHexColor('#ee82ee'),
  'wheat': _parseHexColor('#f5deb3'),
  'white': _parseHexColor('#ffffff'),
  'whitesmoke': _parseHexColor('#f5f5f5'),
  'yellow': _parseHexColor('#ffff00'),
  'yellowgreen': _parseHexColor('#9acd32'),
};
