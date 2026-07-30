import 'dart:convert';
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
    if (profileImage != null) {
      final Map<String, dynamic> multipartFields = {};
      if (fields != null) {
        multipartFields['data'] = jsonEncode(fields);
      }
      return await NetworkCaller.multipartRequest(
        url: Urls.userProfileUrl,
        method: 'PATCH',
        fields: multipartFields,
        files: {'images': profileImage},
      );
    } else {
      return await NetworkCaller.patchRequest(
        url: Urls.userProfileUrl,
        body: fields,
      );
    }
  }

  static Future<NetworkResponse> deleteProfile() async {
    return await NetworkCaller.deleteRequest(url: Urls.userProfileUrl);
  }

  static Future<NetworkResponse> getUserById(String userId) async {
    return await NetworkCaller.getRequest(url: Urls.getUserByIdUrl(userId));
  }

  static Future<NetworkResponse> saveDraft(Map<String, dynamic> draftData) async {
    return await NetworkCaller.patchRequest(
      url: Urls.userDraftUrl,
      body: draftData,
    );
  }

  static Future<NetworkResponse> getDraft() async {
    return await NetworkCaller.getRequest(url: Urls.userDraftUrl);
  }
}
