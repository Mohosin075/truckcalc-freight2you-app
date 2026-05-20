import 'package:flutter/material.dart';
import 'package:truckcalc/Service/Api%20service/iap_service.dart';
import 'package:truckcalc/Service/Api%20service/network_caller.dart';

class IapController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;
  bool _isSuccess = false;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  /// Android বা iOS থেকে সফল ইন-অ্যাপ পারচেস রিসিট ব্যাকএন্ডে ভেরিফাই করা
  Future<bool> verifyPurchaseReceipt({
    required String planId,
    required String platform,
    required String productId,
    required String transactionId,
    String? purchaseToken,
    String? receiptData,
    bool isSandbox = false,
  }) async {
    _inProgress = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    final response = await IapService.verifyReceipt(
      planId: planId,
      platform: platform,
      productId: productId,
      transactionId: transactionId,
      purchaseToken: purchaseToken,
      receiptData: receiptData,
      isSandbox: isSandbox,
    );

    _inProgress = false;
    if (response.isSuccess) {
      _isSuccess = true;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.errorMessage ?? "Failed to verify in-app purchase";
      notifyListeners();
      return false;
    }
  }
}
