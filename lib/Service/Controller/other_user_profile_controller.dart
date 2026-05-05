
import 'package:flutter/material.dart';
import 'package:gathering_app/Model/userModel.dart';
import 'package:gathering_app/Service/Api%20service/network_caller.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:gathering_app/Service/Controller/auth_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OtherUserProfileController extends ChangeNotifier {
  UserProfileModel? _userProfile;
  bool _inProgress = false;
  bool _followInProgress = false;
  String? _errorMessage;

  UserProfileModel? get userProfile => _userProfile;
  bool get inProgress => _inProgress;
  bool get followInProgress => _followInProgress;
  String? get errorMessage => _errorMessage;

  Future<bool> fetchUserProfile(String userId) async {
    _inProgress = true;
    _errorMessage = null;
    _userProfile = null; // Clear previous data
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.getUserByIdUrl(userId),
        requireAuth: true,
      );

      if (response.isSuccess && response.body != null) {
        final userData = response.body!['data'] as Map<String, dynamic>;
        debugPrint("👤 User Profile API Response: $userData");
        _userProfile = UserProfileModel.fromJson(userData);
        _inProgress = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to load user profile";
        _inProgress = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Error: $e";
      _inProgress = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> toggleFollow(String userId) async {
    if (_userProfile == null || _followInProgress) return false;

    _followInProgress = true;
    _errorMessage = null;
    notifyListeners();

    final bool isCurrentlyFollowing = _userProfile!.isFollowing ?? false;
    final String url = isCurrentlyFollowing 
        ? Urls.unfollowUserUrl(userId) 
        : Urls.followUserUrl(userId);

    // Optimistic UI Update
    _userProfile!.isFollowing = !isCurrentlyFollowing;
    if (_userProfile!.stats != null) {
      final newFollowerCount = isCurrentlyFollowing 
          ? (_userProfile!.stats!.followers - 1) 
          : (_userProfile!.stats!.followers + 1);
      
      _userProfile!.stats = Stats(
        events: _userProfile!.stats!.events,
        followers: newFollowerCount < 0 ? 0 : newFollowerCount,
        following: _userProfile!.stats!.following,
      );
    }
    notifyListeners();

    debugPrint("🔄 Toggling follow for $userId. Currently following: $isCurrentlyFollowing");
    debugPrint("🔗 URL: $url");

    try {
      final response = isCurrentlyFollowing 
          ? await NetworkCaller.deleteRequest(url)
          : await NetworkCaller.postRequest(url: url, body: {});

      debugPrint("📡 Response Success: ${response.isSuccess}, Status: ${response.statusCode}");
      _followInProgress = false;

      if (response.isSuccess) {
        debugPrint("✅ Toggle follow successful");
        notifyListeners();
        return true;
      } else {
        debugPrint("❌ Toggle follow failed: ${response.errorMessage}");
        
        // Handle "Already following" or similar desync
        if (response.errorMessage?.contains("Already following") ?? false) {
           _userProfile!.isFollowing = true;
           _errorMessage = null; // Don't show as error, just sync
           notifyListeners();
           return true; 
        }

        // Rollback on failure
        _userProfile!.isFollowing = isCurrentlyFollowing;
        if (_userProfile!.stats != null) {
           final oldFollowerCount = isCurrentlyFollowing 
              ? (_userProfile!.stats!.followers + 1) 
              : (_userProfile!.stats!.followers - 1);

           _userProfile!.stats = Stats(
              events: _userProfile!.stats!.events,
              followers: oldFollowerCount < 0 ? 0 : oldFollowerCount,
              following: _userProfile!.stats!.following,
           );
        }
        _errorMessage = response.errorMessage ?? "Failed to update follow status";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _followInProgress = false;
      // Rollback on exception
      _userProfile!.isFollowing = isCurrentlyFollowing;
      _errorMessage = "Error: $e";
      notifyListeners();
      return false;
    }
  }
}
