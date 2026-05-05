import 'package:flutter/material.dart';
import 'package:gathering_app/Model/get_all_review_model_by_event_id.dart';
import 'package:gathering_app/Service/Api%20service/network_caller.dart';
import 'package:gathering_app/Service/urls.dart';

class ReivewController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;
  bool _showAllReviews = false;

  List<AllReviewModelByEventId> _review = [];

  int _totalReview = 0;

  //getters
  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;
  List<AllReviewModelByEventId> get review => _review;
  int get totalReview => _totalReview;
  bool get showAllReviews => _showAllReviews;

  void toggleShowAll() {
    _showAllReviews = !_showAllReviews;
    notifyListeners();
  }

  void resetShowAll() {
    _showAllReviews = false;
    notifyListeners();
  }

  //Review Create
  Future<bool> submitReview({
    required String eventId,
    required String reviewText,
    required double rating,
  }) async {
    if (reviewText.trim().isEmpty) {
      _errorMessage = "Please write a review";
      notifyListeners();
      return false;
    }

    if (rating < 1 || rating > 5) {
      _errorMessage = "Rating must be between 1 and 5";
      notifyListeners();
      return false;
    }

    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    final Map<String, dynamic> requestBody = {
      "eventId": eventId.trim(),
      "review": reviewText.trim(),
      "rating": rating,
    };

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.reviewUrl,
        body: requestBody,
        requireAuth: true,
      );

      if (response.isSuccess) {
        _inProgress = false;
        notifyListeners();
        return true;
      } else {
        String msg = "Failed to submit review";
        if (response.body is Map) {
          final map = response.body as Map;
          if (map['errorMessages'] is List &&
              (map['errorMessages'] as List).isNotEmpty) {
            msg = map['errorMessages'][0]['message'];
          } else if (map['message'] is String) {
            msg = map['message'];
          }
        }
        _errorMessage = msg;
        _inProgress = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "No internet connection or server error";
      _inProgress = false;
      notifyListeners();
      return false;
    }
  }

  //get all review by event id
  Future<bool> getAllReviewsByEventId({required String eventId}) async {
    _inProgress = true;
    _errorMessage = null;
    _review.clear();
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.getReviewByEventIdUrl(eventId),
        requireAuth: true,
      );

      if (response.isSuccess && response.body != null) {
        final Map<String, dynamic> body = response.body!;

        List<dynamic> reviewList = [];

        // বিভিন্ন API structure সাপোর্ট
        if (body['data'] is List) {
          reviewList = body['data'];
        } else if (body['data']?['data'] is List) {
          reviewList = body['data']['data'];
        } else if (body['reviews'] is List) {
          reviewList = body['reviews'];
        }

        _review = reviewList
            .map(
              (e) =>
                  AllReviewModelByEventId.fromJson(e as Map<String, dynamic>),
            )
            .toList();

        // Update total review count based on list length
        _totalReview = _review.length;

        _inProgress = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to load reviews";
        _inProgress = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "No internet or server error";
      _inProgress = false;
      notifyListeners();
      return false;
    }
  }

  void addReviewLocally(AllReviewModelByEventId newReview) {
    _review.insert(0, newReview);
    _totalReview += 1;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
