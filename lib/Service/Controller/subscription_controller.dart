import 'package:flutter/material.dart';
import 'package:gathering_app/Service/Api%20service/subscription_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  Future<void> createCheckoutSession(String planId) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    final response = await SubscriptionService.createCheckoutSession(planId: planId);

    _inProgress = false;
    if (response.isSuccess && response.body != null) {
      final String? checkoutUrl = response.body!['data']?['url'];
      if (checkoutUrl != null) {
        final Uri url = Uri.parse(checkoutUrl);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          _errorMessage = "Could not launch checkout URL";
        }
      } else {
        _errorMessage = "Invalid response from server";
      }
    } else {
      _errorMessage = response.errorMessage ?? "Failed to initiate subscription";
    }
    notifyListeners();
  }
}
