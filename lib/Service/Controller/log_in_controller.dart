import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gathering_app/Service/Api%20Service/network_caller.dart';
import 'package:gathering_app/Service/Controller/auth_controller.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:provider/provider.dart';
import 'profile_page_controller.dart';

class LogInController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;


  Future<bool> login(String email, String password) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    bool isSuccess = false;

    final Map<String, String> requestBody = {
      "email": email,
      "password": password,
    };

    try {
      final NetworkResponse response = await NetworkCaller.postRequest(
        url: Urls.loginUrl,
        body:requestBody, 
        requireAuth: false,
      );
      
      if (response.isSuccess) {
        final Map<String, dynamic> data = response.body?['data'] ?? response.body ?? {};
        
        final String accessToken = data['accessToken'] ?? data['token'] ?? '';
        final String refreshToken = data['refreshToken'] ?? '';
        
        // Extract user data from response or decode from JWT
        final Map<String, dynamic> userData = data['user'] ?? data['profile'] ?? _decodeToken(accessToken);
        
        final String userId = userData['id']?.toString() ?? 
                             userData['_id']?.toString() ?? 
                             userData['authId']?.toString() ?? '';
                             
        final String userName = userData['name'] ?? 
                                userData['fullName'] ?? 
                                userData['username'] ?? 
                                userData['email']?.split('@')[0] ?? 
                                'User';

        if (accessToken.isNotEmpty && userId.isNotEmpty) {
          final authController = AuthController(); 
          await authController.saveUserData(
            accessToken: accessToken,
            refreshToken: refreshToken,
            userId: userId,
            userName: userName,
          );

          debugPrint("✅ Tokens & User data saved successfully");
          isSuccess = true;
        } else {
          _errorMessage = "Invalid response from server";
          debugPrint("❌ Login Data Missing: accessToken exists: ${accessToken.isNotEmpty}, userId: $userId");
        }
      } else {
        _errorMessage = response.errorMessage ?? "Login failed";
      }
    } catch (e) {
      debugPrint("❌ Login Exception: $e");
      _errorMessage = "Something went wrong! Please try again.";
    } finally {
      _inProgress = false;
      notifyListeners();
    }

    return isSuccess;
  }

  Map<String, dynamic> _decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final payload = parts[1];
      
      // Normalize base64 string
      String normalized = payload;
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }
      normalized = normalized.replaceAll('-', '+').replaceAll('_', '/');
      
      final resp = utf8.decode(base64.decode(normalized));
      return jsonDecode(resp);
    } catch (e) {
      debugPrint("❌ JWT Decode Error: $e");
      return {};
    }
  }
}