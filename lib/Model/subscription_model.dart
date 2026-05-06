class SubscriptionResponse {
  bool? success;
  SubscriptionData? data;

  SubscriptionResponse({this.success, this.data});

  SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? SubscriptionData.fromJson(json['data']) : null;
  }
}

class SubscriptionData {
  String? url;

  SubscriptionData({this.url});

  SubscriptionData.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }
}
