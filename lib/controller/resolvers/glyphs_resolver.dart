import 'package:granite/controller/utils/http_client.dart';
import 'package:granite/glyphs/glyphs.dart' as glyphs;

typedef GlyphsResolverFn = Future<glyphs.Glyphs> Function(String glyphsUrl, String fontstack, int rangeFrom);

Future<glyphs.Glyphs> defaultGlyphsResolver(String glyphsUrl, String fontStack, int rangeFrom) async {
  assert(rangeFrom % 256 == 0, 'rangeFrom must be a multiple of 256');
  final rangeTo = rangeFrom + 255;

  final url = glyphsUrl.replaceFirst('{fontstack}', fontStack).replaceFirst('{range}', '$rangeFrom-$rangeTo');
  final response = await httpGet(Uri.parse(url));
  return glyphs.Glyphs.fromBuffer(response.bodyBytes);
}
