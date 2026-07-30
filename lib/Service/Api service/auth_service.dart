import 'package:truckcalc/Service/Api%20service/network_caller.dart';
import 'package:truckcalc/Service/urls.dart';

class AuthService {
  static Future<NetworkResponse> signup({
    required String email,
    required String password,
    String? name,
    String? phone,
    String? address,
    String? deviceId,
  }) async {
    return await NetworkCaller.postRequest(
      url: Urls.registrationUrl,
      body: {
        'email': email,
        'password': password,
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (deviceId != null) 'deviceId': deviceId,
      },
      requireAuth: false,
    );
  }

  static Future<NetworkResponse> login({
    required String emailOrPhone,
    required String password,
    String? deviceToken,
    bool? rememberMe,
    String? deviceId,
  }) async {
    return await NetworkCaller.postRequest(
      url: Urls.loginUrl,
      body: {
        'email': emailOrPhone, // Backend expects 'email' but can be phone according to doc
        'password': password,
        if (deviceToken != null) 'deviceToken': deviceToken,
        if (rememberMe != null) 'rememberMe': rememberMe,
        if (deviceId != null) 'deviceId': deviceId,
      },
      requireAuth: false,
    );
  }

  static Future<NetworkResponse> verifyAccount({
    required String email,
    required String oneTimeCode,
  }) async {
    return await NetworkCaller.postRequest(
      url: Urls.verifyOtpUrl,
      body: {
        'email': email,
        'oneTimeCode': oneTimeCode,
      },
      requireAuth: false,
    );
  }

  static Future<NetworkResponse> forgetPassword(String emailOrPhone) async {
    return await NetworkCaller.postRequest(
      url: Urls.forgotpassUrl,
      body: {
        'email': emailOrPhone,
      },
      requireAuth: false,
    );
  }

  static Future<NetworkResponse> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await NetworkCaller.postRequest(
      url: Urls.resetPassUrl,
      body: {
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
      // Note: Doc says token might be needed in Authorization header or as string
      // NetworkCaller adds 'Bearer' by default if we pass it via storage.
      // If reset token is different, we might need a custom header.
    );
  }

  static Future<NetworkResponse> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await NetworkCaller.postRequest(
      url: Urls.changePasswordUrl,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  static Future<NetworkResponse> deleteAccount(String password) async {
    return await NetworkCaller.deleteRequest(
      url: Urls.deleteAccountUrl,
      body: {'password': password},
    );
  }

  static Future<NetworkResponse> logout() async {
    return await NetworkCaller.postRequest(url: Urls.logoutUrl);
  }
}
