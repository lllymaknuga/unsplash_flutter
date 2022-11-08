import 'package:unsplash_flutter/repositories/types.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class APIRepository {
  static const String _authority = 'api.unsplash.com';

  const APIRepository();

  Future<dynamic> get(String path, {QueryParams? queryParams}) async {
    final Uri uri = Uri.https(
      _authority,
      path,
      queryParams,
    );
    final http.Response response = await http.get(uri);
    return _decode(response);
  }

  Future<List<dynamic>> page(String path, {QueryParams? queryParams}) async {
    final jsonResponse = await get(
      path,
      queryParams: queryParams,
    );
    return jsonResponse ?? [];
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 400) {
      final utf8Body = convert.utf8.decode(response.bodyBytes);
      if (utf8Body.isEmpty) {
        return <String, dynamic>{};
      }
      return convert.jsonDecode(utf8Body);
    }
  }
}
