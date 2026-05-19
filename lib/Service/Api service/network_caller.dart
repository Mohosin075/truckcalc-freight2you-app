import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:truckcalc/Service/Controller/auth_controller.dart';
import 'package:truckcalc/Service/urls.dart';

class NetworkResponse {
  final String? errorMessage;
  final bool isSuccess;
  final int statusCode;
  final dynamic body;

  NetworkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.body,
    this.errorMessage,
  });
}

class NetworkCaller {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: Urls.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static bool _isRefreshing = false;
  static List<Map<String, dynamic>> _failedRequestsQueue = [];

  static void init() {
    _dio.interceptors.clear(); // Clear existing to avoid duplicates on hot restart
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        debugPrint('🌐 DIO REQUEST [${options.method}] => PATH: ${options.path}');
        
        // If requireAuth header is not explicitly false, add token
        if (options.headers['requireAuth'] != false) {
          final token = await _storage.read(key: 'access_token');
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('🔑 Token added to header');
          } else {
            debugPrint('⚠️ No token found in storage for path: ${options.path}');
          }
        }
        
        // Remove the internal flag before sending
        options.headers.remove('requireAuth');

        if (kDebugMode) {
          print('==== REQUEST DETAILS ====');
          print('URL: ${options.uri}');
          print('HEADERS: ${options.headers}');
          if (options.data != null) print('BODY: ${options.data}');
          print('=========================');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ DIO RESPONSE [${response.statusCode}] => PATH: ${response.requestOptions.path}');
        if (kDebugMode) {
          print('BODY: ${response.data}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        debugPrint('❌ DIO ERROR [${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        debugPrint('ERROR MESSAGE: ${e.message}');

        // Handle 401 Unauthorized - Attempt Token Refresh
        if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('auth/login')) {
          if (!_isRefreshing) {
            _isRefreshing = true;
            final success = await _refreshToken();
            _isRefreshing = false;

            if (success) {
              try {
                final options = e.requestOptions;
                final token = await _storage.read(key: 'access_token');
                if (token != null) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
                
                final response = await _dio.request(
                  options.path,
                  options: Options(
                    method: options.method,
                    headers: options.headers,
                  ),
                  data: options.data,
                  queryParameters: options.queryParameters,
                );

                // Resolve queued requests
                for (var request in _failedRequestsQueue) {
                  final reqOptions = request['options'] as RequestOptions;
                  if (token != null) reqOptions.headers['Authorization'] = 'Bearer $token';
                  final reqResponse = await _dio.request(
                    reqOptions.path,
                    options: Options(
                      method: reqOptions.method,
                      headers: reqOptions.headers,
                    ),
                    data: reqOptions.data,
                    queryParameters: reqOptions.queryParameters,
                  );
                  request['handler'].resolve(reqResponse);
                }
                _failedRequestsQueue.clear();

                return handler.resolve(response);
              } catch (retryError) {
                return handler.next(e);
              }
            } else {
              _failedRequestsQueue.clear();
              AuthController().logout();
            }
          } else {
            _failedRequestsQueue.add({
              'options': e.requestOptions,
              'handler': handler,
            });
            return;
          }
        }
        return handler.next(e);
      },
    ));
  }

  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');

      if (refreshToken == null) return false;

      final response = await Dio().post(
        Urls.refreshTokenUrl,
        options: Options(
          headers: {
            'Cookie': 'refreshToken=$refreshToken',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newAccessToken = response.data['data']['accessToken'];
        await _storage.write(key: 'access_token', value: newAccessToken);
        AuthController().saveTokens(
          accessToken: newAccessToken,
          refreshToken: refreshToken,
        );
        return true;
      }
    } catch (e) {
      debugPrint('Token Refresh Error: $e');
    }
    return false;
  }

  // GET Request
  static Future<NetworkResponse> getRequest({
    required String url,
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true,
    String? token,
  }) async {
    try {
      debugPrint('🌐 Initiating GET: $url');
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: {
          'requireAuth': requireAuth,
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: e.toString());
    }
  }

  // POST Request
  static Future<NetworkResponse> postRequest({
    required String url,
    dynamic body,
    bool requireAuth = true,
    String? token,
  }) async {
    try {
      debugPrint('🌐 Initiating POST: $url');
      final response = await _dio.post(
        url,
        data: body,
        options: Options(headers: {
          'requireAuth': requireAuth,
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: e.toString());
    }
  }

  // PATCH Request
  static Future<NetworkResponse> patchRequest({
    required String url,
    dynamic body,
    bool requireAuth = true,
    String? token,
  }) async {
    try {
      debugPrint('🌐 Initiating PATCH: $url');
      final response = await _dio.patch(
        url,
        data: body,
        options: Options(headers: {
          'requireAuth': requireAuth,
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: e.toString());
    }
  }

  // DELETE Request
  static Future<NetworkResponse> deleteRequest({
    required String url,
    dynamic body,
    bool requireAuth = true,
    String? token,
  }) async {
    try {
      debugPrint('🌐 Initiating DELETE: $url');
      final response = await _dio.delete(
        url,
        data: body,
        options: Options(headers: {
          'requireAuth': requireAuth,
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: e.toString());
    }
  }

  // MULTIPART Request
  static Future<NetworkResponse> multipartRequest({
    required String url,
    required String method,
    Map<String, dynamic>? fields,
    Map<String, File>? files,
    List<File>? fileList,
    String? fileKey,
    bool requireAuth = true,
    String? token,
  }) async {
    try {
      debugPrint('🌐 Initiating MULTIPART [$method]: $url');
      final formData = FormData();
      
      if (fields != null) {
        fields.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      if (files != null) {
        for (var entry in files.entries) {
          formData.files.add(MapEntry(
            entry.key,
            await MultipartFile.fromFile(entry.value.path),
          ));
        }
      }

      if (fileList != null && fileKey != null) {
        for (var file in fileList) {
          formData.files.add(MapEntry(
            fileKey,
            await MultipartFile.fromFile(file.path),
          ));
        }
      }

      final response = await _dio.request(
        url,
        data: formData,
        options: Options(
          method: method,
          headers: {
            'requireAuth': requireAuth,
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: e.toString());
    }
  }

  static NetworkResponse _handleResponse(Response response) {
    final body = response.data;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return NetworkResponse(
        isSuccess: true,
        statusCode: response.statusCode!,
        body: body,
      );
    } else {
      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode ?? -1,
        errorMessage: (body is Map) ? (body['message'] ?? 'Something went wrong') : 'Something went wrong',
        body: body,
      );
    }
  }

  static NetworkResponse _handleError(DioException e) {
    String? errorMessage = 'Something went wrong';
    
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Connection timed out. Check your server connection.';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'No internet connection or server unreachable.';
    } else if (e.response != null) {
      final data = e.response?.data;
      if (data is Map) {
        errorMessage = data['message'] ?? data['errorMessages']?[0]['message'] ?? 'Server error';
      }
    }
    
    return NetworkResponse(
      isSuccess: false,
      statusCode: e.response?.statusCode ?? -1,
      errorMessage: errorMessage,
      body: e.response?.data is Map<String, dynamic> ? e.response?.data : null,
    );
  }
}
