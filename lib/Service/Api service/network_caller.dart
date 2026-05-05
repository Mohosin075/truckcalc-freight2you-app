import 'dart:convert';
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gathering_app/Service/Controller/auth_controller.dart'; // এটা ইম্পোর্ট করো
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NetworkResponse {
  final String? errorMessage;
  final bool isSuccess;
  final int statusCode;
  final Map<String, dynamic>? body;

  NetworkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.body,
    this.errorMessage,
  });
}

class NetworkCaller {
  static const String _unAuthorizeMessage = 'Unauthorized access';

  // Resolve token from AuthController or secure storage
  static Future<String?> _getToken() async {
    final storage = const FlutterSecureStorage();
    final tokenFromController = AuthController().accessToken;
    if (tokenFromController != null && tokenFromController.isNotEmpty)
      return tokenFromController;
    return await storage.read(key: 'access_token');
  }

  // GET Request
  static Future<NetworkResponse> getRequest({
    required String url,
    bool requireAuth = true,
    String? token,
  }) async {
    try {
      final Uri uri = Uri.parse(url);

      final Map<String, String> headers = {'Accept': 'application/json'};

      // অটো টোকেন যোগ করো (যদি requireAuth true হয়)
      if (requireAuth) {
        final String? resolvedToken = await _getToken();
        if (resolvedToken != null && resolvedToken.isNotEmpty) {
          if (resolvedToken.contains('.')) {
            headers['Authorization'] = 'Bearer $resolvedToken';
          } else {
            headers['Authorization'] = resolvedToken;
            headers['token'] = resolvedToken;
          }
        }
      }

      _logRequest('GET', url, null, headers);

      final http.Response response = await http.get(uri, headers: headers);

      _logResponse('GET', url, response);

      return _parseResponse(response);
    } catch (e) {
      debugPrint('Network Error (GET): $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: 'No internet connection or server error',
      );
    }
  }

  // POST Request
  static Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    bool requireAuth = true,
    String? token,
  }) async {
    try {
      final Uri uri = Uri.parse(url);

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Handle Authentication
      if (token != null && token.isNotEmpty) {
        if (token.contains('.')) {
          headers['Authorization'] = 'Bearer $token';
          debugPrint("JWT TOKEN ADDED: Bearer $token");
        } else {
          headers['Authorization'] = token;
          headers['token'] = token;
          debugPrint("RAW TOKEN ADDED: $token");
        }
      } else if (requireAuth) {
        final String? resolvedToken = await _getToken();
        if (resolvedToken != null && resolvedToken.isNotEmpty) {
          if (resolvedToken.contains('.')) {
            headers['Authorization'] = 'Bearer $resolvedToken';
          } else {
            headers['Authorization'] = resolvedToken;
            headers['token'] = resolvedToken;
          }
          debugPrint("TOKEN ADDED TO HEADER");
        } else {
          debugPrint("NO TOKEN FOUND");
        }
      }

      final String? encodedBody = body != null ? jsonEncode(body) : null;

      _logRequest('POST', url, body, headers);

      final http.Response response = await http.post(
        uri,
        headers: headers,
        body: encodedBody,
      );

      _logResponse('POST', url, response);

      return _parseResponse(response);
    } catch (e) {
      debugPrint('Network Error (POST): $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: 'No internet or server error',
      );
    }
  }

  // PATCH Request (Profile update-এর জন্য)
  static Future<NetworkResponse> patchRequest({
    required String url,
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final Uri uri = Uri.parse(url);

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (requireAuth) {
        final String? resolvedToken = await _getToken();
        if (resolvedToken != null && resolvedToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $resolvedToken';
          debugPrint("TOKEN ADDED TO PATCH HEADER: Bearer $resolvedToken");
        } else {
          debugPrint("NO TOKEN FOUND (AuthController or storage) for PATCH");
        }
      }

      final String? encodedBody = body != null ? jsonEncode(body) : null;

      _logRequest('PATCH', url, body, headers);

      final http.Response response = await http.patch(
        uri,
        headers: headers,
        body: encodedBody,
      );

      _logResponse('PATCH', url, response);

      return _parseResponse(response);
    } catch (e) {
      debugPrint('Network Error (PATCH): $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: 'No internet connection or server error',
      );
    }
  }

  // Multi-part Request for file uploads
  static Future<NetworkResponse> multipartRequest({
    required String url,
    required String method,
    Map<String, String>? fields,
    String? fileKey,
    String? filePath,
    List<String>? filePaths, // Added support for multiple files
    bool requireAuth = true,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      final request = http.MultipartRequest(method, uri);

      // Add headers
      final Map<String, String> headers = {'Accept': 'application/json'};

      if (requireAuth) {
        final String? resolvedToken = await _getToken();
        if (resolvedToken != null && resolvedToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $resolvedToken';
        }
      }
      request.headers.addAll(headers);

      // Add text fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add single file
      if (fileKey != null && filePath != null) {
        MediaType? mediaType;
        if (filePath.toLowerCase().endsWith('.png')) {
          mediaType = MediaType('image', 'png');
        } else if (filePath.toLowerCase().endsWith('.jpg') ||
            filePath.toLowerCase().endsWith('.jpeg')) {
          mediaType = MediaType('image', 'jpeg');
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            fileKey,
            filePath,
            contentType: mediaType,
          ),
        );
      }

      // Add multiple files
      if (fileKey != null && filePaths != null) {
        for (var path in filePaths) {
          MediaType? mediaType;
          if (path.toLowerCase().endsWith('.png')) {
            mediaType = MediaType('image', 'png');
          } else if (path.toLowerCase().endsWith('.jpg') ||
              path.toLowerCase().endsWith('.jpeg')) {
            mediaType = MediaType('image', 'jpeg');
          }

          request.files.add(
            await http.MultipartFile.fromPath(
              fileKey,
              path,
              contentType: mediaType,
            ),
          );
        }
      }

      debugPrint(
        '==== MULTIPART $method REQUEST ====\n'
        'URL: $url\n'
        'HEADERS: $headers\n'
        'FIELDS: $fields\n'
        'FILE: $filePath\n'
        'FILE_KEY: $fileKey\n'
        '========================',
      );

      final http.StreamedResponse response = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final http.Response httpResponse = await http.Response.fromStream(
        response,
      );

      _logResponse(method, url, httpResponse);

      return _parseResponse(httpResponse);
    } on TimeoutException {
      debugPrint('Network Error (MULTIPART): Request Timed out (60s)');
      return NetworkResponse(
        isSuccess: false,
        statusCode: 408,
        errorMessage: 'Request timed out (60s limit)',
      );
    } catch (e) {
      debugPrint('Network Error (MULTIPART): $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: 'Connection failed: $e',
      );
    }
  }

  static Future<NetworkResponse> deleteRequest(
    String url, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (requireAuth) {
        final String? resolvedToken = await _getToken();
        if (resolvedToken != null && resolvedToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $resolvedToken';
        }
      }

      final uri = Uri.parse(url);

      _logRequest('DELETE', url, body, headers);

      http.Response response;
      if (body != null) {
        response = await http.delete(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
      } else {
        response = await http.delete(uri, headers: headers);
      }

      _logResponse('DELETE', url, response);

      return _parseResponse(response);
    } catch (e) {
      debugPrint('Network Error (DELETE): $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: 'No internet or server error: $e',
      );
    }
  }

  // Common response parser
  static NetworkResponse _parseResponse(http.Response response) {
    try {
      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decoded is Map<String, dynamic> ? decoded : null,
        );
      } else if (response.statusCode == 401) {
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: _unAuthorizeMessage,
          body: decoded is Map<String, dynamic> ? decoded : null,
        );
      } else {
        final String message = decoded is Map
            ? (decoded['message'] ??
                  decoded['errorMessages']?[0]['message'] ??
                  'Unknown error')
            : response.body;
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: message,
          body: decoded is Map<String, dynamic> ? decoded : null,
        );
      }
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMessage: 'Invalid response format',
        body: {'raw': response.body},
      );
    }
  }

  static void _logRequest(
    String method,
    String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) {
    Map<String, dynamic>? safeBody;

    if (body != null) {
      safeBody = Map.from(body);

      // যদি 'password' ফিল্ড থাকে তাহলে '***'
      if (safeBody.containsKey('password')) {
        safeBody['password'] = '***';
      }
    }

    debugPrint(
      '==== $method REQUEST ====\n'
      'URL: $url\n'
      'HEADERS: $headers\n'
      'BODY: $safeBody\n'
      '========================',
    );
  }

  static void _logResponse(String method, String url, http.Response response) {
    debugPrint(
      '==== $method RESPONSE ====\n'
      'URL: $url\n'
      'STATUS: ${response.statusCode}\n'
      'BODY: ${response.body}\n'
      '==========================',
    );
  }
}

// (token helper moved into NetworkCaller class)
