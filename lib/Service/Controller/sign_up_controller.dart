import 'package:flutter/material.dart';
import 'package:gathering_app/Service/Api%20Service/network_caller.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:gathering_app/View/Screen/authentication_screen/verify_account.dart';
import 'package:gathering_app/View/Widgets/customSnacBar.dart';

class SignUpController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  Future<bool> signUp({
    required String email,
    required String name,
    required String password,
  }) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    final body = {
      "name": name,
      "email": email,
      "password": password,
    };

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.registrationUrl, // /api/v1/auth/signup
        body: body,
        requireAuth: false,
      );

      _inProgress = false;
      notifyListeners();

      if (response.isSuccess) {
        return true;
      } else {
        // এরর হ্যান্ডেল
        String errorMsg = "Registration failed";
        if (response.body != null && response.body is Map) {
          final Map bodyMap = response.body as Map;
          if (bodyMap['errorMessages'] is List && (bodyMap['errorMessages'] as List).isNotEmpty) {
            errorMsg = bodyMap['errorMessages'][0]['message'];
          } else if (bodyMap['message'] is String) {
            errorMsg = bodyMap['message'];
          }
        }

        _errorMessage = errorMsg;
        return false;
      }
    } catch (e) {
      _inProgress = false;
      _errorMessage = "Something went wrong";
      notifyListeners();
      return false;
    }
  }
}