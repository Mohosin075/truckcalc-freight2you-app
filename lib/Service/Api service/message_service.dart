import 'dart:io';
import 'package:gathering_app/Service/Api%20service/network_caller.dart';
import 'package:gathering_app/Service/urls.dart';

class MessageService {
  static Future<NetworkResponse> getMessages(String chatId) async {
    return await NetworkCaller.getRequest(url: Urls.getMessagesUrl(chatId));
  }

  static Future<NetworkResponse> sendMessage({
    required String chatId,
    String? text,
    List<File>? images,
  }) async {
    return await NetworkCaller.multipartRequest(
      url: Urls.sendMessageUrl,
      method: 'POST',
      fields: {
        'chatId': chatId,
        if (text != null) 'message': text,
      },
      fileList: images,
      fileKey: 'images',
    );
  }
}
