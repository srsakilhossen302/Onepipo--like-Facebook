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
      print('--> GET $url');
      print('Headers: ${_getHeaders(headers)}');
      final response = await http.get(
        url,
        headers: _getHeaders(headers),
      ).timeout(const Duration(seconds: 30));
      print('<-- ${response.statusCode} $url');
      print('Response Body: ${response.body}');
      return response;
    } catch (e) {
      print('GET Error: $e');
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
      print('--> POST $url');
      print('Headers: ${_getHeaders(headers)}');
      print('Body: ${body is Map ? jsonEncode(body) : body}');
      final response = await http.post(
        url,
        body: body is Map ? jsonEncode(body) : body,
        headers: _getHeaders(headers),
      ).timeout(const Duration(seconds: 30));
      print('<-- ${response.statusCode} $url');
      print('Response Body: ${response.body}');
      return response;
    } catch (e) {
      print('POST Error: $e');
      throw Exception('Connection error: $e');
    }
  }

  // Multipart POST request
  Future<http.Response> postMultipart(
    String uri,
    String fileKey,
    String filePath, {
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${ApiUrl.baseUrl}$uri');
      print('--> POST MULTIPART $url');
      
      var request = http.MultipartRequest('POST', url);
      
      final Map<String, String> multipartHeaders = {
        AppConst.accept: AppConst.applicationJson,
      };
      final token = _sharedPrefHelper.getString(AppConst.token);
      if (token.isNotEmpty) {
        multipartHeaders[AppConst.authorization] = 'Bearer $token';
      }
      if (headers != null) {
        multipartHeaders.addAll(headers);
      }
      request.headers.addAll(multipartHeaders);
      
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      request.files.add(await http.MultipartFile.fromPath(fileKey, filePath));
      
      print('Multipart Request Headers: ${request.headers}');
      print('Multipart Request Fields: ${request.fields}');
      print('Multipart Request File: $fileKey -> $filePath');
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      final response = await http.Response.fromStream(streamedResponse);
      
      print('<-- ${response.statusCode} $url');
      print('Response Body: ${response.body}');
      return response;
    } catch (e) {
      print('Multipart POST Error: $e');
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
