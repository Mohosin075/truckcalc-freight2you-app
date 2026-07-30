import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:truckcalc/Service/Api%20service/auth_service.dart';
import 'package:truckcalc/Service/Api%20service/user_service.dart';
import 'package:truckcalc/Service/Controller/profile_page_controller.dart';
import 'package:truckcalc/Service/Socket/socket_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:truckcalc/Utils/device_util.dart';

class AuthController extends ChangeNotifier {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true, // auto-clear corrupted data on decryption failure
    ),
  );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';

  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  String? _userName;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get userId => _userId;
  String? get userName => _userName;
  bool get isLoggedIn => _isLoggedIn;

  bool _isLoggedIn = false;

  // টোকেন + ইউজার ডেটা সেভ করা
  Future<void> saveUserData({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String userName,
  }) async {
    _accessToken = accessToken.trim();
    _refreshToken = refreshToken.trim();
    _userId = userId.trim();
    _userName = userName.trim();

    _isLoggedIn = _accessToken!.isNotEmpty;

    await Future.wait([
      _storage.write(key: _accessTokenKey, value: _accessToken),
      _storage.write(key: _refreshTokenKey, value: _refreshToken),
      _storage.write(key: _userIdKey, value: _userId),
      _storage.write(key: _userNameKey, value: _userName),
    ]).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint("⚠️ Auth: Storage write timed out");
        return [];
      },
    );

    debugPrint("✅ Tokens & User data saved successfully");

    // Connect socket after saving data
    SocketService().connect(_accessToken!, _userId!);

    notifyListeners();
  }

  // অ্যাপ স্টার্টে সব লোড করা
  Future<void> initialize() async {
    try {
      await Future.any([
        Future.wait([
          _storage.read(key: _accessTokenKey).then((v) => _accessToken = v),
          _storage.read(key: _refreshTokenKey).then((v) => _refreshToken = v),
          _storage.read(key: _userIdKey).then((v) => _userId = v),
          _storage.read(key: _userNameKey).then((v) => _userName = v),
        ]),
        Future.delayed(const Duration(seconds: 3))
            .then((_) => throw Exception("Storage timeout")),
      ]);

      _isLoggedIn = _accessToken != null && _accessToken!.trim().isNotEmpty;
      debugPrint(
          "🔄 Auth initialized - Logged in: $_isLoggedIn, User: $_userName");

      if (_isLoggedIn && _accessToken != null && _userId != null) {
        SocketService().connect(_accessToken!, _userId!);
      }
    } catch (e) {
      debugPrint("⚠️ Auth initialization failure/timeout: $e");
      _isLoggedIn = false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {

    try {
      final String? deviceId = await DeviceUtil.getDeviceId();
      final response = await AuthService.login(
        emailOrPhone: email,
        password: password,
        deviceId: deviceId,
      );

      if (response.isSuccess && response.body != null) {
        final Map<String, dynamic> data =
            response.body!['data'] ?? response.body!;

        final String accessToken = data['accessToken'] ?? data['token'] ?? '';
        final String refreshToken = data['refreshToken'] ?? '';

        // Extract user data from response or decode from JWT
        final Map<String, dynamic> userData =
            data['user'] ?? data['profile'] ?? _decodeToken(accessToken);
        
        final String userId = userData['id']?.toString() ??
            userData['_id']?.toString() ??
            userData['authId']?.toString() ??
            '';
            
        final String userName = userData['name'] ??
            userData['fullName'] ??
            userData['username'] ??
            userData['email']?.split('@')[0] ??
            'User';

        if (accessToken.isEmpty || userId.isEmpty) {
          debugPrint("❌ Missing accessToken or userId");
          return false;
        }

        await saveUserData(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: userId,
          userName: userName,
        );

        // Fetch draft from backend and save to GetStorage
        try {
          final box = GetStorage();
          
          // 1. Restore user-specific local backup if exists, to prevent blank inputs while fetching
          final localLoad = box.read('load_inputs_$userId');
          final localCost = box.read('cost_inputs_$userId');
          final localRate = box.read('rate_inputs_$userId');
          
          if (localLoad != null) box.write('load_inputs', localLoad);
          if (localCost != null) box.write('cost_inputs', localCost);
          if (localRate != null) box.write('rate_inputs', localRate);

          // 2. Fetch latest draft from backend to override and sync
          final draftResponse = await UserService.getDraft();
          debugPrint("🔄 Get Draft API response: Status: ${draftResponse.statusCode}, Success: ${draftResponse.isSuccess}, Body: ${draftResponse.body}");
          
          if (draftResponse.isSuccess && draftResponse.body != null) {
            final draftMap = draftResponse.body!['data'] ?? {};
            if (draftMap['loadCalculator'] != null) {
              final Map<String, dynamic> loadData = Map<String, dynamic>.from(draftMap['loadCalculator']);
              box.write('load_inputs', loadData);
              box.write('load_inputs_$userId', loadData);
            }
            if (draftMap['costsCalculator'] != null) {
              final Map<String, dynamic> costData = Map<String, dynamic>.from(draftMap['costsCalculator']);
              box.write('cost_inputs', costData);
              box.write('cost_inputs_$userId', costData);
            }
            if (draftMap['ratePlanner'] != null) {
              final Map<String, dynamic> rateData = Map<String, dynamic>.from(draftMap['ratePlanner']);
              box.write('rate_inputs', rateData);
              box.write('rate_inputs_$userId', rateData);
            }
            debugPrint("✅ Draft retrieved and saved to GetStorage on login");
          } else {
            debugPrint("❌ Get Draft API failed: ${draftResponse.errorMessage}");
          }
        } catch (e) {
          debugPrint("⚠️ Failed to load draft on login: $e");
        }

        final profileController =
            Provider.of<ProfileController>(context, listen: false);
        await profileController.fetchProfile(forceRefresh: true);

        debugPrint("✅ Login successful - User: $userName (ID: $userId)");
        return true;
      } else {
        debugPrint("❌ Login failed: ${response.errorMessage}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Login exception: $e");
      return false;
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken.trim();
    _refreshToken = refreshToken.trim();
    _isLoggedIn = _accessToken!.isNotEmpty;

    await _storage.write(key: _accessTokenKey, value: _accessToken);
    await _storage.write(key: _refreshTokenKey, value: _refreshToken);

    debugPrint("✅ Tokens saved successfully");
    notifyListeners();
  }

  Map<String, dynamic> _decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final payload = parts[1];

      // Normalize base64 string
      String normalized = payload;
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }
      normalized = normalized.replaceAll('-', '+').replaceAll('_', '/');

      final resp = utf8.decode(base64.decode(normalized));
      return jsonDecode(resp);
    } catch (e) {
      debugPrint("❌ JWT Decode Error: $e");
      return {};
    }
  }

  // লগআউট আপডেট করা
  Future<void> logout() async {
    final currentUserId = _userId;
    
    // Save user-specific local copy before logging out
    try {
      final box = GetStorage();
      final Map<String, dynamic> loadInputs = Map<String, dynamic>.from(box.read('load_inputs') ?? {});
      final Map<String, dynamic> costInputs = Map<String, dynamic>.from(box.read('cost_inputs') ?? {});
      final Map<String, dynamic> rateInputs = Map<String, dynamic>.from(box.read('rate_inputs') ?? {});

      if (currentUserId != null && currentUserId.isNotEmpty) {
        box.write('load_inputs_$currentUserId', loadInputs);
        box.write('cost_inputs_$currentUserId', costInputs);
        box.write('rate_inputs_$currentUserId', rateInputs);
        debugPrint("💾 User-specific backups saved locally before logout");
      }
    } catch (e) {
      debugPrint("⚠️ Failed to save local backup before logout: $e");
    }

    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _userName = null;
    _isLoggedIn = false;

    // SecureStorage migration may fail (BadPaddingException) — handle gracefully
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint("⚠️ SecureStorage deleteAll failed (ignored): $e");
    }

    // Clean up default keys, but do NOT erase() the whole GetStorage (keeps user-specific backups)
    try {
      final box = GetStorage();
      await box.remove('load_inputs');
      await box.remove('cost_inputs');
      await box.remove('rate_inputs');
      debugPrint("🧹 Default calculator inputs removed from GetStorage");
    } catch (e) {
      debugPrint("⚠️ GetStorage key removal failed (ignored): $e");
    }

    try {
      SocketService().disconnect();
    } catch (e) {
      debugPrint("⚠️ Socket disconnect failed (ignored): $e");
    }

    debugPrint("🚪 User logged out completely");
    notifyListeners();
  }
}
