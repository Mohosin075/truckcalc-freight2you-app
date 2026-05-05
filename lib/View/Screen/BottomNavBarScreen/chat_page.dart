import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Model/ChatModel.dart';
import 'package:gathering_app/Service/Controller/auth_controller.dart';
import 'package:gathering_app/Service/Controller/chat_controller.dart';
import 'package:gathering_app/Service/Controller/profile_page_controller.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/user_chat_screen.dart';
import 'package:gathering_app/Service/urls.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,

      // AppBar (Messages + Search)
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Messages", style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),

      // Body
      body: Column(
        children: [
          // Search Bar
          SearchTextField(hintText: 'Search Conversation...'),

          // Chat List
          Expanded(
            child: Consumer<ChatController>(
              builder: (context, controller, child) {
                debugPrint(
                  "🔄 ChatPage rebuild - inProgress: ${controller.inProgress}, chatCount: ${controller.chatList.length}",
                );

                if (controller.inProgress && controller.chatList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.chatList.isEmpty) {
                  if (controller.errorMessage != null) {
                    return Center(
                      child: Text("Error: ${controller.errorMessage!}"),
                    );
                  }
                  return const Center(child: Text("No conversations yet"));
                }

                // Show the actual data for debugging
                debugPrint(
                  "📱 Displaying ${controller.chatList.length} chats:",
                );
                for (var chat in controller.chatList) {
                  debugPrint("  - ${chat.name}: ${chat.currentMessage}");
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await context.read<ChatController>().getChats();
                  },
                  child: ListView.builder(
                    itemCount: controller.chatList.length,
                    itemBuilder: (context, index) {
                      final userChat = controller.chatList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 26.r,
                          backgroundColor: Colors
                              .primaries[userChat.name.hashCode %
                                  Colors.primaries.length]
                              .withOpacity(0.2),
                          backgroundImage:
                              (userChat.imageIcon != null &&
                                  userChat.imageIcon!.isNotEmpty)
                              ? NetworkImage(
                                  userChat.imageIcon!.startsWith('http')
                                      ? userChat.imageIcon!
                                      : '${Urls.baseUrl}${userChat.imageIcon!.startsWith('/') ? '' : '/'}${userChat.imageIcon!}',
                                )
                              : null,
                          child:
                              (userChat.imageIcon == null ||
                                  userChat.imageIcon!.isEmpty)
                              ? Text(
                                  (userChat.name != null &&
                                          userChat.name!.isNotEmpty)
                                      ? userChat.name![0].toUpperCase()
                                      : "?",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Colors.primaries[userChat
                                                .name
                                                .hashCode %
                                            Colors.primaries.length],
                                  ),
                                )
                              : null,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                userChat.name ?? 'Unknown',
                                style: TextStyle(
                                  fontWeight: userChat.isSeen == false
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  fontSize: 14.sp,
                                  color: userChat.isSeen == false
                                      ? Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.color
                                      : Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.color
                                            ?.withOpacity(0.8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          userChat.currentMessage ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: userChat.isSeen == false
                                ? Theme.of(context).textTheme.bodyMedium?.color
                                : Theme.of(context).textTheme.bodyMedium?.color
                                      ?.withOpacity(0.6),
                            fontWeight: userChat.isSeen == false
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: Text(
                          _formatTime(userChat.time),
                          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserChatScreen(chat: userChat),
                            ),
                          );
                          // When returning, if we have a chat ID, mark it as seen locally for immediate feedback
                          if (userChat.id != null) {
                            controller.markChatAsSeenLocally(userChat.id!);
                          }
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
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(timeStr).toLocal();
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return '';
    }
  }
}
