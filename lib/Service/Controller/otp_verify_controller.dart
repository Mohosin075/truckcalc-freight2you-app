import 'package:flutter/material.dart';
import 'package:gathering_app/Service/Api%20Service/network_caller.dart';
import 'package:gathering_app/Service/Controller/auth_controller.dart';
import 'package:gathering_app/Service/urls.dart';

class OtpVerifyController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  Future<bool> verifyOtp({required String email, required String otp}) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();
    final body = {"email": email, "oneTimeCode": otp};
    debugPrint('User email: $email, OTP: $otp');

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.verifyOtpUrl,
        body: body,
        requireAuth: false,
      );

      _inProgress = false;
      notifyListeners();

      if (response.isSuccess) {
        final Map<String, dynamic> data = response.body!['data'];

        final String accessToken = data['accessToken'];
        final String refreshToken = data['refreshToken'] ?? '';

        await AuthController().saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          );

        debugPrint("✅TOKEN SAVED FROM OTP VERIFY:$accessToken");
        return true;
      } else {
        String msg = "Invalid or expired OTP";
        if (response.body is Map) {
          final map = response.body as Map;
          msg = map['message'] ?? msg;
        }
        _errorMessage = msg;
        return false;
      }
    } catch (e) {
      _inProgress = false;
      _errorMessage = "Network error. Please try again.";
      notifyListeners();
      return false;
    }
  }
}
