import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gathering_app/Model/userModel.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gathering_app/Service/Api%20service/network_caller.dart';
import 'package:gathering_app/Service/Controller/auth_controller.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ProfileController extends ChangeNotifier {
  final GetStorage _storage = GetStorage();

  UserProfileModel? _currentUser;
  bool _inProgress = false;
  String? _errorMessage;

  UserProfileModel? get currentUser => _currentUser;
  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;
  bool get hasData => _currentUser != null;

  // App start-এ cached profile load

  Future<void> initialize() async {
    final cachedJson = _storage.read<Map<String, dynamic>>(
      'cached_user_profile',
    );
    if (cachedJson != null) {
      _currentUser = UserProfileModel.fromJson(cachedJson);
      notifyListeners();
    }
  }

  // Profile fetch
  Future<bool> fetchProfile({required bool forceRefresh}) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    // যদি forceRefresh না হয় এবং ক্যাশে থাকে, তাহলে ক্যাশ থেকে লোড করো
    if (!forceRefresh) {
      final cachedJson = _storage.read<Map<String, dynamic>>(
        'cached_user_profile',
      );
      if (cachedJson != null) {
        _currentUser = UserProfileModel.fromJson(cachedJson);
        notifyListeners();
        _inProgress = false;
        return true; // ক্যাশ থেকে লোড সাকসেস
      }
    }

    try {
      final String? userId = AuthController().userId;
      debugPrint("🆔 Current User ID for fetch: $userId");

      final response = await NetworkCaller.getRequest(
        url: (userId != null && userId.isNotEmpty)
            ? Urls.getUserByIdUrl(userId)
            : Urls.userProfileUrl,
        requireAuth: true,
      );

      if (response.isSuccess && response.body != null) {
        final userData = response.body!['data'] as Map<String, dynamic>;

        // Debug: Print API response
        debugPrint("👤 ProfileController API Response: $userData");
        debugPrint("📊 Stats field: ${userData['stats']}");
        debugPrint("📊 Events field: ${userData['events']}");
        debugPrint("📊 Followers field: ${userData['followers']}");
        debugPrint("📊 Following field: ${userData['following']}");

        _currentUser = UserProfileModel.fromJson(userData);

        // Debug: Print parsed stats
        debugPrint("✅ Parsed Stats - Events: ${_currentUser?.stats?.events}");
        debugPrint(
          "✅ Parsed Stats - Followers: ${_currentUser?.stats?.followers}",
        );
        debugPrint(
          "✅ Parsed Stats - Following: ${_currentUser?.stats?.following}",
        );

        await _storage.write('cached_user_profile', userData);

        _inProgress = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to load profile";
        _inProgress = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "No internet or server error: $e";
      _inProgress = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({String? name, String? description}) async {
    if (_currentUser == null) return false;

    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _inProgress = true;
      notifyListeners();
      Map<String, String> updateData = {};

      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
      }
      if (description != null && description.trim().isNotEmpty) {
        updateData['description'] = description.trim();
      }

      if (updateData.isEmpty) {
        _inProgress = false;
        notifyListeners();
        return true;
      }

      final response = await NetworkCaller.patchRequest(
        url: Urls.updateProfileUrl,
        body: updateData,
      );

      //  success check
      if (response.isSuccess) {
        if (name != null && name.trim().isNotEmpty) {
          _currentUser!.name = name.trim();
        }
        if (description != null && description.trim().isNotEmpty) {
          _currentUser!.description = description.trim();
        }

        // save storage
        await _storage.write('cached_user_profile', _currentUser!.toJson());
        _inProgress = false;
        notifyListeners();

        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Update failed";
        _inProgress = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Update error: $e";
      _inProgress = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Compress image to reduce size
      maxWidth: 600, // Resize image used for profile
    );

    if (image == null) return false;

    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // --- Fix Orientation using pure Dart 'image' package ---
      final Uint8List originalBytes = await image.readAsBytes();
      final img.Image? decoded = img.decodeImage(originalBytes);

      String finalPath = image.path;

      if (decoded != null) {
        // bakeOrientation reads EXIF and rotates pixels accordingly
        final img.Image oriented = img.bakeOrientation(decoded);
        final List<int> fixedBytes = img.encodeJpg(oriented, quality: 80);

        final tempDir = await getTemporaryDirectory();
        final targetPath = p.join(
          tempDir.path,
          "${DateTime.now().millisecondsSinceEpoch}_fixed.jpg",
        );
        final File fixedFile = File(targetPath);
        await fixedFile.writeAsBytes(fixedBytes);
        finalPath = targetPath;
      }

      final response = await NetworkCaller.multipartRequest(
        url: Urls.updateProfileUrl,
        method: 'PATCH',
        fileKey: 'images',
        filePath: finalPath,
        requireAuth: true,
      );

      if (response.isSuccess) {
        // Since response.body['data'] is a String message now, we must fetch the profile
        // to get the updated image URL.
        await fetchProfile(forceRefresh: true);
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to upload image";
        _inProgress = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Upload error: $e";
      _inProgress = false;
      notifyListeners();
      return false;
    }
  }

  // ================== SETTINGS FUCTIONS START ==================

  void updateSettingsLocally({
    bool? pushNotification,
    bool? emailNotification,
    bool? locationService,
    String? profileStatus,
  }) {
    if (_currentUser == null || _currentUser!.settings == null) return;

    final updatedSettings = Settings(
      pushNotification:
          pushNotification ?? _currentUser!.settings!.pushNotification,
      emailNotification:
          emailNotification ?? _currentUser!.settings!.emailNotification,
      locationService:
          locationService ?? _currentUser!.settings!.locationService,
      profileStatus: profileStatus ?? _currentUser!.settings!.profileStatus,
    );

    _currentUser = UserProfileModel(
      location: _currentUser!.location,
      settings: updatedSettings,
      id: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
      interest: _currentUser!.interest,
      status: _currentUser!.status,
      verified: _currentUser!.verified,
      subscribe: _currentUser!.subscribe,
      role: _currentUser!.role,
      timezone: _currentUser!.timezone,
      description: _currentUser!.description,
      isOnboardingComplete: _currentUser!.isOnboardingComplete,
      createdAt: _currentUser!.createdAt,
      updatedAt: _currentUser!.updatedAt,
      profile: _currentUser!.profile,
      stats: _currentUser!.stats,
      isFollowing: _currentUser!.isFollowing,
    );

    notifyListeners();
  }

  Future<bool> saveSettings() async {
    if (_currentUser == null || _currentUser!.settings == null) return false;

    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = {"settings": _currentUser!.settings!.toJson()};

      final response = await NetworkCaller.patchRequest(
        url: Urls.updateProfileUrl,
        body: body,
      );

      if (response.isSuccess) {
        await _storage.write('cached_user_profile', _currentUser!.toJson());
        _inProgress = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to update settings";
        _inProgress = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Settings update error: $e";
      _inProgress = false;
      notifyListeners();
      return false;
    }
  }

  // ================== SETTINGS FUNCTIONS END ==================

  void clear() {
    _currentUser = null;
    _storage.remove('cached_user_profile');
    notifyListeners();
  }
}
