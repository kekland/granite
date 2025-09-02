import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:granite/glyphs/glyphs.dart' as glyphs;
import 'package:vector_math/vector_math_64.dart' as vm;

const kSdfPadding = 3;

class GlyphAtlas {
  GlyphAtlas({required this.width, required this.height}) {
    data = GlyphAtlasData(width: width, height: height);
    _textureData = ByteData(width * height);
    texture = gpu.gpuContext.createTexture(
      gpu.StorageMode.hostVisible,
      width,
      height,
      format: gpu.PixelFormat.r8UNormInt,
    );
  }

  final int width;
  final int height;
  late final GlyphAtlasData data;
  late final gpu.Texture texture;
  late final ByteData _textureData;

  void put(String fontStack, glyphs.Glyph glyph, {bool flush = true}) {
    final position = data.put(fontStack, glyph);
    final paddedWidth = glyph.width + kSdfPadding * 2;

    for (var i = 0; i < glyph.bitmap.length; i++) {
      final x = position.x + i % paddedWidth;
      final y = position.y + i ~/ paddedWidth;

      final index = x + y * width;
      _textureData.setUint8(index, glyph.bitmap[i]);
    }

    if (flush) _flushTexture();
  }

  void _flushTexture() {
    texture.overwrite(_textureData);
  }

  void putGlyphs(glyphs.Glyphs glyphs) {
    print('put glyphs: ${glyphs.stacks.length} stacks');
    for (final fontStack in glyphs.stacks) {
      for (final glyph in fontStack.glyphs) {
        put(fontStack.name, glyph, flush: false);
      }
    }

    _flushTexture();
  }

  AtlasPosition? get(String fontStack, int codeUnit) => data.get(fontStack, codeUnit);
  bool contains(String fontStack, int codeUnit) => data.contains(fontStack, codeUnit);

  (vm.Vector2, vm.Vector2)? getUv(String fontStack, int codeUnit) {
    final position = get(fontStack, codeUnit);
    if (position == null) return null;

    return (
      vm.Vector2(
        (position.x) / width,
        (position.y) / height,
      ),
      vm.Vector2(
        (position.x + position.width + kSdfPadding * 2) / width,
        (position.y + position.height + kSdfPadding * 2) / height,
      ),
    );
  }

  GlyphData? getGlyphData(String fontStack, int codeUnit) {
    if (!contains(fontStack, codeUnit)) return null;

    return GlyphData(
      position: get(fontStack, codeUnit)!,
      uv: getUv(fontStack, codeUnit)!,
    );
  }
}

class GlyphData {
  GlyphData({required this.position, required this.uv});

  glyphs.Glyph get raw => position.raw;
  final AtlasPosition position;
  final (vm.Vector2, vm.Vector2) uv;
}

class AtlasPosition {
  AtlasPosition({
    required this.x,
    required this.y,
    required this.raw,
  });

  final int x;
  final int y;

  final glyphs.Glyph raw;

  int get width => raw.width;
  int get height => raw.height;
}

class GlyphAtlasData {
  GlyphAtlasData({required this.width, required this.height});

  final int width;
  final int height;
  final _data = <(String, int), AtlasPosition>{};

  var _cursorX = 0;
  var _cursorY = 0;
  var _cursorMaxHeight = 0;
  AtlasPosition put(String fontStack, glyphs.Glyph glyph) {
    final paddedWidth = glyph.width + kSdfPadding * 2;
    final paddedHeight = glyph.height + kSdfPadding * 2;

    // If we ran out of space, move to the next line
    if (_cursorX + paddedWidth > width) {
      _cursorX = 0;
      _cursorY += _cursorMaxHeight;
      _cursorMaxHeight = 0;
    }

    final position = AtlasPosition(
      x: _cursorX,
      y: _cursorY,
      raw: glyph,
    );

    _cursorX += paddedWidth;
    _cursorMaxHeight = max(_cursorMaxHeight, paddedHeight);
    _data[(fontStack, glyph.id)] = position;
    return position;
  }

  AtlasPosition? get(String fontStack, int codeUnit) => _data[(fontStack, codeUnit)];
  bool contains(String fontStack, int codeUnit) => _data.containsKey((fontStack, codeUnit));
}
