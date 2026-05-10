import 'dart:io';
import 'package:truckcalc/Service/Api%20service/network_caller.dart';
import 'package:truckcalc/Service/urls.dart';

class UserService {
  static Future<NetworkResponse> getProfile() async {
    return await NetworkCaller.getRequest(url: Urls.userProfileUrl);
  }

  static Future<NetworkResponse> updateProfile({
    Map<String, dynamic>? fields,
    File? profileImage,
  }) async {
    return await NetworkCaller.multipartRequest(
      url: Urls.userProfileUrl,
      method: 'PATCH',
      fields: fields,
      files: profileImage != null ? {'profile': profileImage} : null,
    );
  }

  static Future<NetworkResponse> deleteProfile() async {
    return await NetworkCaller.deleteRequest(url: Urls.userProfileUrl);
  }

  static Future<NetworkResponse> getUserById(String userId) async {
    return await NetworkCaller.getRequest(url: Urls.getUserByIdUrl(userId));
  }
}
