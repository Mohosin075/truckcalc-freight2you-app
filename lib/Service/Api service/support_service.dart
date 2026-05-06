import 'dart:io';
import 'package:gathering_app/Service/Api%20service/network_caller.dart';
import 'package:gathering_app/Service/urls.dart';

class SupportService {
  static Future<NetworkResponse> createSupportTicket({
    required String message,
    required String contentType, // 'comment' | 'review'
    String? subject,
    List<File>? attachments,
    String? reason,
  }) async {
    return await NetworkCaller.multipartRequest(
      url: Urls.supportUrl,
      method: 'POST',
      fields: {
        'message': message,
        'contentType': contentType,
        if (subject != null) 'subject': subject,
        if (reason != null) 'reason': reason,
      },
      fileList: attachments,
      fileKey: 'attachments',
    );
  }

  static Future<NetworkResponse> getSupportTickets() async {
    return await NetworkCaller.getRequest(url: Urls.supportUrl);
  }
}
