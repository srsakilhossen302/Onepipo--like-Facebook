import 'package:dio/dio.dart';
import 'package:get/get.dart' as get_x;
import '../helper/shared_prefe/shared_prefe.dart';
import '../Utils/AppConst/app_const.dart';
import 'api_url.dart';

class ApiClient {
  late final Dio _dio;
  final _sharedPrefHelper = get_x.Get.find<SharedPreferenceHelper>();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiUrl.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          AppConst.accept: AppConst.applicationJson,
          AppConst.contentType: AppConst.applicationJson,
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _sharedPrefHelper.getString(AppConst.token);
          if (token.isNotEmpty) {
            options.headers[AppConst.authorization] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  // GET request
  Future<Response> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    String message = "Something went wrong";
    if (error.type == DioExceptionType.connectionTimeout) {
      message = "Connection timeout";
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = "Receive timeout";
    } else if (error.type == DioExceptionType.badResponse) {
      final respData = error.response?.data;
      if (respData is Map && respData.containsKey('message')) {
        message = respData['message'];
      } else {
        message = "Bad response status: ${error.response?.statusCode}";
      }
    }
    return Exception(message);
  }
}
