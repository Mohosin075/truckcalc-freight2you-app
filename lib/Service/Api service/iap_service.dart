import 'package:truckcalc/Service/Api%20service/network_caller.dart';
import 'package:truckcalc/Service/urls.dart';

class IapService {
  /// Android বা iOS স্টোর থেকে কেনা রিসিট বা পারচেস টোকেন ব্যাকএন্ডে ভেরিফাই করা
  static Future<NetworkResponse> verifyReceipt({
    required String planId,
    required String platform,
    required String productId,
    required String transactionId,
    String? purchaseToken,
    String? receiptData,
    bool isSandbox = false,
  }) async {
    return await NetworkCaller.postRequest(
      url: Urls.verifyIapReceiptUrl,
      body: {
        'planId': planId,
        'platform': platform,
        'productId': productId,
        'transactionId': transactionId,
        if (purchaseToken != null) 'purchaseToken': purchaseToken,
        if (receiptData != null) 'receiptData': receiptData,
        'isSandbox': isSandbox,
      },
    );
  }

  /// ইউজারের অ্যাক্টিভ ইন-অ্যাপ পারচেস সাবস্ক্রিপশন চেক করা
  static Future<NetworkResponse> getMyIap() async {
    return await NetworkCaller.getRequest(
      url: Urls.getMyIapUrl,
    );
  }
}
