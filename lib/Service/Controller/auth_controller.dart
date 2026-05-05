import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gathering_app/Service/Api%20service/network_caller.dart';
import 'package:gathering_app/Service/Controller/profile_page_controller.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:gathering_app/Service/Socket/socket_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

class AuthController extends ChangeNotifier {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
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

    // Use a timeout to prevent hanging on some Android devices during KeyStore operations
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
  //ki je kori 


  // অ্যাপ স্টার্টে সব লোড করা
  Future<void> initialize() async {
    try {
      // Add a timeout to prevent hanging on older Android devices (KeyStore issues)
      await Future.any([
        Future.wait([
          _storage.read(key: _accessTokenKey).then((v) => _accessToken = v),
          _storage.read(key: _refreshTokenKey).then((v) => _refreshToken = v),
          _storage.read(key: _userIdKey).then((v) => _userId = v),
          _storage.read(key: _userNameKey).then((v) => _userName = v),
        ]),
        Future.delayed(const Duration(seconds: 3)).then((_) => throw Exception("Storage timeout")),
      ]);

      _isLoggedIn = _accessToken != null && _accessToken!.trim().isNotEmpty;
      debugPrint("🔄 Auth initialized - Logged in: $_isLoggedIn, User: $_userName");
      
      if (_isLoggedIn && _accessToken != null && _userId != null) {
        SocketService().connect(_accessToken!, _userId!);
      }
    } catch (e) {
      debugPrint("⚠️ Auth initialization failure/timeout: $e");
      // Fallback: assume not logged in instead of hanging
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
    if (_isLoggedIn) return true;

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.loginUrl,
        body: {
          'email': email.trim(),
          'password': password,
        },
        requireAuth: false,
      );

      if (response.isSuccess && response.body != null) {
        final Map<String, dynamic> data = response.body!['data'] ?? response.body!;

        //  API response structure 
        final String accessToken = data['accessToken'] ?? data['token'] ?? '';
        final String refreshToken = data['refreshToken'] ?? '';

        // ইউজারের ডেটা এক্সট্র্যাক্ট করো
        final Map<String, dynamic> userData = data['user'] ?? data['profile'] ?? {};
        final String userId = userData['id']?.toString() ?? userData['_id']?.toString() ?? '';
        final String userName = userData['name'] ?? 
                                userData['fullName'] ?? 
                                userData['username'] ?? 
                                userData['email']?.split('@')[0] ?? 
                                'User';

        if (accessToken.isEmpty || userId.isEmpty) {
          debugPrint("❌ Missing accessToken or userId");
          return false;
        }

        // সব সেভ করো
        await saveUserData(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: userId,
          userName: userName,
        );

        final profileController = Provider.of<ProfileController>(context, listen: false);
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

  // লগআউট আপডেট করা
  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _userName = null;
    _isLoggedIn = false;

    await _storage.deleteAll(); // সব ক্লিয়ার করো (সহজ উপায়)
    await GetStorage().erase(); // Clear cached profile and other session data

    // প্রোফাইল ক্লিয়ার
    // Provider.of<ProfileController>(context, listen: false).clear(); // context না থাকলে অন্যভাবে করো

    // Disconnect socket on logout
    SocketService().disconnect();

    debugPrint("🚪 User logged out completely");
    notifyListeners();
  }
}