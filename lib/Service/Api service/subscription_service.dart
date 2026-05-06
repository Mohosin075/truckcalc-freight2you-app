import 'package:gathering_app/Service/Api%20service/network_caller.dart';
import 'package:gathering_app/Service/urls.dart';

class SubscriptionService {
  static Future<NetworkResponse> getPlans({String? userType}) async {
    return await NetworkCaller.getRequest(
      url: Urls.subscriptionPlansUrl,
      queryParameters: userType != null ? {'userType': userType} : null,
      requireAuth: false,
    );
  }

  static Future<NetworkResponse> getPlanDetails(String planId) async {
    return await NetworkCaller.getRequest(
      url: Urls.getPlanDetailsUrl(planId),
      requireAuth: false,
    );
  }

  static Future<NetworkResponse> createSubscription({
    required String planId,
    String? paymentMethodId,
    String? couponId,
  }) async {
    return await NetworkCaller.postRequest(
      url: Urls.createSubscriptionUrl,
      body: {
        'planId': planId,
        if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
        if (couponId != null) 'couponId': couponId,
      },
    );
  }

  static Future<NetworkResponse> getMySubscription() async {
    return await NetworkCaller.getRequest(url: Urls.mySubscriptionUrl);
  }

  static Future<NetworkResponse> getSubscriptionStatus() async {
    return await NetworkCaller.getRequest(url: Urls.subscriptionStatusUrl);
  }

  static Future<NetworkResponse> createCheckoutSession({
    required String planId,
    String successUrl = "https://success.com",
    String cancelUrl = "https://cancel.com",
  }) async {
    return await NetworkCaller.postRequest(
      url: Urls.createCheckoutSessionUrl,
      body: {
        "planId": planId,
        "successUrl": successUrl,
        "cancelUrl": cancelUrl,
      },
    );
  }

  static Future<NetworkResponse> getBillingPortal(String returnUrl) async {
    return await NetworkCaller.postRequest(
      url: Urls.billingPortalUrl,
      body: {"returnUrl": returnUrl},
    );
  }
}
