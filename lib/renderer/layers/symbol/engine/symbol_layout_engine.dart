import 'dart:developer';
import 'dart:ui' as ui;

import 'package:granite/renderer/core/atlas/glyph_atlas.dart';
import 'package:granite/renderer/renderer.dart';
import 'package:granite/spec/spec.dart' as spec;
import 'package:granite/vector_tile/vector_tile.dart' as vt;
import 'package:vector_math/vector_math_64.dart' as vm;

class SymbolLayoutEngine {
  static Future<List<SymbolPlacement>> performLayout({
    required RendererNode renderer,
    required spec.EvaluationContext evalContext,
    required spec.LayoutSymbol layout,
    required vt.Feature feature,
  }) async {
    final text = layout.textField.evaluate(evalContext);
    final transformedText = _transformText(evalContext, layout, text);
    final glyphs = await renderer.getGlyphsForFormatted(
      layout.textFont.evaluate(evalContext).join(','),
      transformedText,
    );

    final placement = layout.symbolPlacement.evaluate(evalContext);
    final multiline = placement == spec.LayoutSymbol$SymbolPlacement.point;
    final singlePlacement = _layoutSinglePlacement(
      evalContext,
      layout,
      feature,
      glyphs,
      transformedText,
      multiline: multiline,
    );

    final result = <SymbolPlacement>[];
    for (final point in (feature as vt.PointFeature).points) {
      result.add(singlePlacement.copyWith(anchor: point));
    }

    return result;
  }
}

class SymbolPlacement {
  SymbolPlacement({
    required this.width,
    required this.height,
    required this.anchor,
    required this.glyphs,
  });

  final double width;
  final double height;
  final vm.Vector2 anchor;
  final List<GlyphPlacement> glyphs;

  SymbolPlacement copyWith({
    double? width,
    double? height,
    vm.Vector2? anchor,
    List<GlyphPlacement>? glyphs,
  }) {
    return SymbolPlacement(
      width: width ?? this.width,
      height: height ?? this.height,
      anchor: anchor ?? this.anchor,
      glyphs: glyphs ?? this.glyphs,
    );
  }
}

class GlyphPlacement {
  GlyphPlacement({
    required this.rune,
    required this.position,
    required this.width,
    required this.height,
    required this.uv,
  });

  final int rune;
  final vm.Vector2 position;
  final double width;
  final double height;
  final (vm.Vector2, vm.Vector2) uv;
}

spec.Formatted _transformText(
  spec.EvaluationContext eval,
  spec.LayoutSymbol layout,
  spec.Formatted text,
) {
  final transform = layout.textTransform.evaluate(eval);
  final transformedSections = <spec.FormattedSection>[];
  final operation = switch (transform) {
    spec.LayoutSymbol$TextTransform.uppercase => (String text) => text.toUpperCase(),
    spec.LayoutSymbol$TextTransform.lowercase => (String text) => text.toLowerCase(),
    spec.LayoutSymbol$TextTransform.none => (String text) => text,
  };

  for (final section in text.sections) {
    late final spec.FormattedSection transformedSection;

    if (section.text != null) {
      transformedSection = spec.FormattedSection.text(
        text: operation(section.text!),
        scale: section.scale,
        fontStack: section.fontStack,
        textColor: section.textColor,
      );
    } else {
      transformedSection = section;
    }

    transformedSections.add(transformedSection);
  }

  return spec.Formatted(sections: transformedSections);
}

SymbolPlacement _layoutSinglePlacement(
  spec.EvaluationContext evalContext,
  spec.LayoutSymbol layout,
  vt.Feature feature,
  List<GlyphData?> loadedGlyphs,
  spec.Formatted text, {
  bool multiline = false,
}) {
  final font = layout.textFont.evaluate(evalContext);
  final anchor = layout.textAnchor.evaluate(evalContext);
  final size = layout.textSize.evaluate(evalContext);
  final maxWidthEm = layout.textMaxWidth.evaluate(evalContext);
  final lineHeightEm = layout.textLineHeight.evaluate(evalContext);
  final letterSpacingEm = layout.textLetterSpacing.evaluate(evalContext);
  final justify = layout.textJustify.evaluate(evalContext);
  final maxAngle = layout.textMaxAngle.evaluate(evalContext);
  final writingMode = layout.textWritingMode?.evaluate(evalContext);
  final rotate = layout.textRotate.evaluate(evalContext);
  final padding = layout.textPadding.evaluate(evalContext);
  final keepUpright = layout.textKeepUpright.evaluate(evalContext);
  final offset = layout.textOffset.evaluate(evalContext);

  final builder = ui.ParagraphBuilder(
    ui.ParagraphStyle(
      fontFamily: 'Noto Sans',
      fontSize: size.toDouble(),
      height: lineHeightEm.toDouble(),
      textAlign: ui.TextAlign.left,
    ),
  );

  for (final section in text.sections) {
    if (section.text == null) continue;
    builder.addText(section.text!);
  }

  final _multiline = multiline && _hasBreakablePoints(text);

  final paragraph = builder.build();
  paragraph.layout(ui.ParagraphConstraints(width: _multiline ? maxWidthEm.toDouble() * size : double.infinity));
  final glyphPlacements = <GlyphPlacement>[];
  final paragraphWidth = paragraph.minIntrinsicWidth;

  final anchorOffset = switch (anchor) {
    spec.LayoutSymbol$TextAnchor.topLeft => vm.Vector2(0, 0),
    spec.LayoutSymbol$TextAnchor.top => vm.Vector2(-paragraphWidth / 2, 0),
    spec.LayoutSymbol$TextAnchor.topRight => vm.Vector2(-paragraphWidth, 0),
    spec.LayoutSymbol$TextAnchor.left => vm.Vector2(0, -paragraph.height / 2),
    spec.LayoutSymbol$TextAnchor.center => vm.Vector2(-paragraphWidth / 2, -paragraph.height / 2),
    spec.LayoutSymbol$TextAnchor.right => vm.Vector2(-paragraphWidth, -paragraph.height / 2),
    spec.LayoutSymbol$TextAnchor.bottomLeft => vm.Vector2(0, -paragraph.height),
    spec.LayoutSymbol$TextAnchor.bottom => vm.Vector2(-paragraphWidth / 2, -paragraph.height),
    spec.LayoutSymbol$TextAnchor.bottomRight => vm.Vector2(-paragraphWidth, -paragraph.height),
  };

  var i = 0;
  while (true) {
    final glyphInfo = paragraph.getGlyphInfoAt(i);
    if (glyphInfo == null) break;
    i = glyphInfo.graphemeClusterCodeUnitRange.end;

    for (var j = glyphInfo.graphemeClusterCodeUnitRange.start; j < glyphInfo.graphemeClusterCodeUnitRange.end; j++) {
      final glyph = loadedGlyphs[j];
      if (glyph == null) continue;

      glyphPlacements.add(
        GlyphPlacement(
          rune: glyph.raw.id,
          position:
              anchorOffset +
              vm.Vector2(
                glyphInfo.graphemeClusterLayoutBounds.left + (glyph.raw.left - kSdfPadding) * (size / 24.0),
                glyphInfo.graphemeClusterLayoutBounds.top + (-glyph.raw.top - kSdfPadding) * (size / 24.0),
              ),
          width: (glyph.raw.width.toDouble() + kSdfPadding * 2) * (size / 24.0),
          height: (glyph.raw.height.toDouble() + kSdfPadding * 2) * (size / 24.0),
          uv: glyph.uv,
        ),
      );
    }
  }

  return SymbolPlacement(
    anchor: vm.Vector2.zero(),
    glyphs: glyphPlacements,
    width: paragraphWidth,
    height: paragraph.height,
  );
}

const _breakableCharacters = ['\u0020'];

bool _hasBreakablePoints(spec.Formatted text) {
  for (final section in text.sections) {
    if (section.text == null) continue;
    if (_breakableCharacters.any((v) => section.text!.contains(v))) {
      return true;
    }
  }

  return false;
}
