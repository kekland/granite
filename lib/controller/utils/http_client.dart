import 'package:http/http.dart' as http;

// TODOS:
// - Use zoned http clients.

final _client = http.Client();

Future<http.Response> httpGet(Uri uri) async {
  final response = await _client.get(uri);

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception('Failed to fetch: ${response.statusCode}');
  }

  return response;
}
