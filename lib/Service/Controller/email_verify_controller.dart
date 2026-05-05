import 'package:flutter/material.dart';
import 'package:gathering_app/Service/Api%20Service/network_caller.dart';
import 'package:gathering_app/Service/urls.dart';

class EmailVerifyController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String _email = '';           
  String? _otpToken;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get email => _email;
  bool get isEmailSaved => _email.isNotEmpty;

  // Step 1: SignUp এর পর এটা কল হবে → email সেভ + OTP পাঠাবে
  Future<bool> initializeAndSendOtp(String userEmail) async {
    _email = userEmail.trim();
    debugPrint("Email saved in controller: $_email"); 

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.registrationUrl, // এটা ভুল ছিল তোমার কোডে!!!
        // তুমি verifyOtpUrl দিয়েছিলে — ওটা ভুল
        body: {"email": _email},
      );

      if (response.isSuccess) {
        debugPrint("OTP sent successfully to $_email");
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to send OTP";
        return false;
      }
    } catch (e) {
      _errorMessage = "No internet connection";
      debugPrint("OTP send error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Step 2: User OTP টাইপ করে Submit করলে এটা কল হবে
  Future<bool> verifyOtp(String otpCode) async {
    if (_email.isEmpty) {
      _errorMessage = "Email not found! Please register again.";
      notifyListeners();
      return false;
    }

    debugPrint("Verifying OTP for: $_email");

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.verifyOtpUrl, 
        body: {
          "email": _email,
          "oneTimeCode": otpCode.trim(),
        },
      );

      if (response.isSuccess) {
        _otpToken = response.body?['data']?['token']?.toString();
        debugPrint("OTP Verified Successfully!");
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Wrong OTP";
        return false;
      }
    } catch (e) {
      _errorMessage = "Verification failed";
      debugPrint("Verify error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _email = '';
    _otpToken = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}