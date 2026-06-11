import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart' as get_x;
import '../helper/shared_prefe/shared_prefe.dart';
import '../Utils/AppConst/app_const.dart';
import 'api_url.dart';

class ApiClient {
  final _sharedPrefHelper = get_x.Get.find<SharedPreferenceHelper>();

  // Base Headers builder
  Map<String, String> _getHeaders(Map<String, String>? customHeaders) {
    final Map<String, String> headers = {
      AppConst.accept: AppConst.applicationJson,
      AppConst.contentType: AppConst.applicationJson,
    };

    final token = _sharedPrefHelper.getString(AppConst.token);
    if (token.isNotEmpty) {
      headers[AppConst.authorization] = 'Bearer $token';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  // GET request
  Future<http.Response> get(
    String uri, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${ApiUrl.baseUrl}$uri');
      final response = await http.get(
        url,
        headers: _getHeaders(headers),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // POST request
  Future<http.Response> post(
    String uri, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${ApiUrl.baseUrl}$uri');
      final response = await http.post(
        url,
        body: body is Map ? jsonEncode(body) : body,
        headers: _getHeaders(headers),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // PUT request
  Future<http.Response> put(
    String uri, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${ApiUrl.baseUrl}$uri');
      final response = await http.put(
        url,
        body: body is Map ? jsonEncode(body) : body,
        headers: _getHeaders(headers),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // DELETE request
  Future<http.Response> delete(
    String uri, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${ApiUrl.baseUrl}$uri');
      final response = await http.delete(
        url,
        body: body is Map ? jsonEncode(body) : body,
        headers: _getHeaders(headers),
      ).timeout(const Duration(seconds: 30));
      return response;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}
