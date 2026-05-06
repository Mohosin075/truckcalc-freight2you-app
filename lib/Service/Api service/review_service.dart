import 'package:gathering_app/Service/Api%20service/network_caller.dart';
import 'package:gathering_app/Service/urls.dart';

class ReviewService {
  static Future<NetworkResponse> getAllReviews() async {
    return await NetworkCaller.getRequest(url: Urls.reviewUrl);
  }

  static Future<NetworkResponse> createReview({
    String? reviewee,
    required double rating,
    required String review,
  }) async {
    return await NetworkCaller.postRequest(
      url: Urls.reviewUrl,
      body: {
        if (reviewee != null) 'reviewee': reviewee,
        'rating': rating,
        'review': review,
      },
    );
  }

  static Future<NetworkResponse> getReviewById(String id) async {
    return await NetworkCaller.getRequest(url: Urls.getSingleReviewUrl(id));
  }

  static Future<NetworkResponse> updateReview(String id, Map<String, dynamic> body) async {
    return await NetworkCaller.patchRequest(
      url: Urls.updateReviewUrl(id),
      body: body,
    );
  }

  static Future<NetworkResponse> deleteReview(String id) async {
    return await NetworkCaller.deleteRequest(url: Urls.deleteReviewUrl(id));
  }
}
