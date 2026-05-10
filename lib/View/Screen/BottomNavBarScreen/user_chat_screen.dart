import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Model/ChatModel.dart';
import 'package:gathering_app/Service/Controller/auth_controller.dart';
import 'package:gathering_app/Service/Controller/chat_controller.dart';
import 'package:gathering_app/Service/Controller/profile_page_controller.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserChatScreen extends StatefulWidget {
  ChatModel? chat;
  UserChatScreen({super.key, this.chat});
  static const String name = '/user-chat-screen';
  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.chat?.id != null) {
        context.read<ChatController>().getMessages(widget.chat!.id!);
        context.read<ChatController>().initSocket(widget.chat!.id!);
      }
    });
  }

  @override
  void dispose() {
    if (widget.chat?.id != null) context.read<ChatController>().disposeSocket(widget.chat!.id!);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)),
        title: Text(widget.chat?.name ?? 'Chat', style: TextStyle(color: Colors.white, fontSize: 18.sp)),
      ),
      body: AppBackground(
        child: Column(
          children: [
            Expanded(
              child: Consumer2<ChatController, ProfileController>(
                builder: (context, chatController, profileController, child) {
                  if (chatController.inProgress && chatController.messageList.isEmpty) return const Center(child: CircularProgressIndicator(color: Color(0xFF00D193)));
                  final messages = chatController.messageList;
                  final myId = AuthController().userId ?? profileController.currentUser?.id;
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.sender?.toString() == myId?.toString();
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF004D40) : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(message.text ?? '', style: const TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.r), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: () async {
                if (_textController.text.trim().isEmpty) return;
                final success = await context.read<ChatController>().sendMessage(widget.chat!.id!, _textController.text.trim());
                if (success) {
                  _textController.clear();
                  _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                }
              },
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: const BoxDecoration(color: Color(0xFF00D193), shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
