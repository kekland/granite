import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:granite_example/fixtures/maptiler-api-key.dart';
import 'package:collection/collection.dart';

void main() {
  return runApp(
    MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: TextShapingPlayground(),
    ),
  );
}

class TextShapingPlayground extends StatefulWidget {
  const TextShapingPlayground({super.key});

  @override
  State<TextShapingPlayground> createState() => TextShapingPlaygroundState();
}

class TextShapingPlaygroundState extends State<TextShapingPlayground> with TickerProviderStateMixin {
  final String fontName = 'Noto Sans';
  Image? image;

  @override
  void initState() {
    super.initState();
    _playground();
  }

  @override
  void reassemble() {
    super.reassemble();
    _playground();
  }

  Future<void> _playground() async {
    final glyphs = await loadGlyphs('Noto Sans Regular', 0, 255);
    final text = 'Hello, world!\nHow is it going?';
    final fontSize = 16.0;

    final pb = ParagraphBuilder(
      ParagraphStyle(
        textAlign: TextAlign.left,
        fontSize: fontSize,
        // height: 1.0, 
        textHeightBehavior: TextHeightBehavior(
          applyHeightToFirstAscent: true,
          applyHeightToLastDescent: true,
          leadingDistribution: TextLeadingDistribution.even,
        ),

        fontFamily: fontName,
      ),
    );

    pb.addText(text);
    final p = pb.build();
    p.layout(const ParagraphConstraints(width: double.infinity));

    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    canvas.translate(0.0, 100.0);
    canvas.drawColor(Colors.black, BlendMode.src);

    var i = 0;
    final stack = glyphs.stacks.first;
    final lineMetrics = p.getLineMetricsAt(0)!;

    while (true) {
      final g = p.getGlyphInfoAt(i);
      if (g == null) break;
      i = g.graphemeClusterCodeUnitRange.end;
      final rect = g.graphemeClusterLayoutBounds;
      var color = Colors.primaries[i % Colors.primaries.length];

      canvas.drawRect(rect, Paint()..color = color);

      final runes = g.graphemeClusterCodeUnitRange.textInside(text).runes;
      for (final rune in runes) {
        final glyph = stack.glyphs.firstWhereOrNull((g) => g.id == rune);
        if (glyph == null) continue;
        final scale = fontSize / 24.0;

        final glyphRect = Rect.fromLTRB(
          rect.left + glyph.left * scale,
          rect.top - glyph.top * scale,
          rect.left + (glyph.left + glyph.width) * scale,
          rect.top + (-glyph.top + glyph.height) * scale,
        );

        canvas.drawRect(glyphRect, Paint()..color = Colors.black.withOpacity(0.5));
      }
    }

    canvas.drawLine(
      Offset(0.0, lineMetrics.baseline),
      Offset(lineMetrics.width, lineMetrics.baseline),
      Paint()..color = Colors.white,
    );

    // print(stack.name);
    // var x = 0.0;
    // i = 0;
    // for (final rune in text.runes) {
    //   final glyph = stack.glyphs.firstWhere((g) => g.id == rune);
    //   final rect = Rect.fromLTRB(x, 100.0 - glyph.top, x + glyph.advance, 100.0 - glyph.top + glyph.height);

    //   x += glyph.advance;
    //   i++;

    //   var color = Colors.primaries[i % Colors.primaries.length];
    //   canvas.drawRect(rect, Paint()..color = color);
    // }

    // canvas.drawParagraph(p, Offset.zero);

    final picture = pictureRecorder.endRecording();
    image = await picture.toImage(300, 300);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Transform.scale(
          scale: 2.0,
          child: image == null ? const CircularProgressIndicator() : RawImage(image: image, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
