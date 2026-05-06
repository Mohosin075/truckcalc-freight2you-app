import 'package:gathering_app/Service/Api%20service/network_caller.dart';
import 'package:gathering_app/Service/urls.dart';

class ChatService {
  static Future<NetworkResponse> createOrHandleChat(String otherUserId) async {
    return await NetworkCaller.postRequest(
      url: Urls.createChatUrl(otherUserId),
    );
  }

  static Future<NetworkResponse> getChatList() async {
    return await NetworkCaller.getRequest(url: Urls.getAllChatsUrl);
  }
}
