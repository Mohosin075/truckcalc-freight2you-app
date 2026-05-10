import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/Service/Controller/auth_controller.dart';
import 'package:truckcalc/Service/Controller/chat_controller.dart';
import 'package:truckcalc/Service/Controller/profile_page_controller.dart';
import 'package:truckcalc/View/Screen/BottomNavBarScreen/user_chat_screen.dart';
import 'package:truckcalc/Service/urls.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:provider/provider.dart';

import '../../Widgets/serch_textfield.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = AuthController();
      if (auth.userId == null) {
        context
            .read<ProfileController>()
            .fetchProfile(forceRefresh: false)
            .then((_) {
              context.read<ChatController>().getChats();
              context.read<ChatController>().initChatListSocket();
            });
      } else {
        context.read<ChatController>().getChats();
        context.read<ChatController>().initChatListSocket();
      }
    });
  }

  @override
  void dispose() {
    context.read<ChatController>().disposeChatListSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        title: Text("Messages", style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: AppBackground(
        child: Column(
          children: [
            SearchTextField(hintText: 'Search Conversation...'),
            Expanded(
              child: Consumer<ChatController>(
                builder: (context, controller, child) {
                  if (controller.inProgress && controller.chatList.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF00D193)));
                  }
                  if (controller.chatList.isEmpty) {
                    return Center(child: Text(controller.errorMessage ?? "No conversations yet", style: const TextStyle(color: Colors.white60)));
                  }
                  return RefreshIndicator(
                    onRefresh: () async => await context.read<ChatController>().getChats(),
                    child: ListView.builder(
                      itemCount: controller.chatList.length,
                      itemBuilder: (context, index) {
                        final userChat = controller.chatList[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 26.r,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            backgroundImage: (userChat.imageIcon != null && userChat.imageIcon!.isNotEmpty)
                                ? NetworkImage(userChat.imageIcon!.startsWith('http') ? userChat.imageIcon! : '${Urls.baseUrl}/${userChat.imageIcon!}')
                                : null,
                            child: (userChat.imageIcon == null || userChat.imageIcon!.isEmpty)
                                ? Text(userChat.name?[0].toUpperCase() ?? "?", style: const TextStyle(color: Colors.white))
                                : null,
                          ),
                          title: Text(
                            userChat.name ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: userChat.isSeen == false ? FontWeight.bold : FontWeight.w600,
                              fontSize: 15.sp,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            userChat.currentMessage ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: userChat.isSeen == false ? Colors.white : Colors.white60),
                          ),
                          trailing: Text(_formatTime(userChat.time), style: TextStyle(color: Colors.white38, fontSize: 11.sp)),
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => UserChatScreen(chat: userChat)));
                            if (userChat.id != null) controller.markChatAsSeenLocally(userChat.id!);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(timeStr).toLocal();
      final difference = DateTime.now().difference(date);
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      return '${difference.inDays}d ago';
    } catch (e) { return ''; }
  }
}
