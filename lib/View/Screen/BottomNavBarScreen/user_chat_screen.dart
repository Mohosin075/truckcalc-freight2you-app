import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gathering_app/Model/ChatModel.dart';
import 'package:gathering_app/Service/Controller/auth_controller.dart';
import 'package:gathering_app/Service/Controller/chat_controller.dart';
import 'package:gathering_app/Service/Controller/profile_page_controller.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/other_user_profile_screen.dart';
import 'package:gathering_app/Service/urls.dart';
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Robust argument extraction fallback
      if (widget.chat == null) {
        final args = ModalRoute.of(context)?.settings.arguments;
        debugPrint("📱 UserChatScreen - Extracting args: $args");
        if (args is ChatModel) {
          setState(() {
            widget.chat = args;
          });
        }
      }

      debugPrint(
        "📱 UserChatScreen Init - Chat Object: ${widget.chat?.toJson()}",
      );

      final authController = AuthController();
      if (widget.chat?.id != null) {
        context.read<ChatController>().getMessages(widget.chat!.id!);
        context.read<ChatController>().initSocket(widget.chat!.id!);
      }

      // If userId is missing, try to fetch profile to get it
      if (authController.userId == null) {
        context.read<ProfileController>().fetchProfile(forceRefresh: false);
      }
    });
  }

  @override
  void dispose() {
    if (widget.chat?.id != null) {
      context.read<ChatController>().disposeSocket(widget.chat!.id!);
    }
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          titleSpacing: 0,
          title: Row(
            children: [
              // Back Button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),

              // Profile Picture + Name (Clickable)
              Expanded(
                child: InkWell(
                  onTap: () {
                    final chatController = context.read<ChatController>();
                    final profileController = context.read<ProfileController>();
                    final myId =
                        AuthController().userId ??
                        profileController.currentUser?.id;

                    debugPrint(
                      "👆 Header Tap - MyID: $myId, OtherID in Chat: ${widget.chat?.otherUserId}",
                    );

                    // Try to get ID from widget.chat, or fallback to finding it in messages
                    String? targetId = widget.chat?.otherUserId;

                    if (targetId == null &&
                        chatController.messageList.isNotEmpty) {
                      // Find first message not sent by me
                      for (var msg in chatController.messageList) {
                        if (msg.sender != null &&
                            msg.sender.toString() != myId.toString()) {
                          targetId = msg.sender.toString();
                          break;
                        }
                      }
                    }

                    if (targetId != null) {
                      Navigator.pushNamed(
                        context,
                        OtherUserProfileScreen.name,
                        arguments: targetId,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "ID ERROR - MyID: $myId\nOtherID: ${widget.chat?.otherUserId}\nChatID: ${widget.chat?.id}",
                          ),
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      // Profile Picture + Online Dot
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 24.r,
                            backgroundColor: Colors
                                .primaries[(widget.chat?.name ?? "").hashCode %
                                    Colors.primaries.length]
                                .withOpacity(0.2),
                            child: ClipOval(
                              child:
                                  (widget.chat?.imageIcon != null &&
                                      widget.chat!.imageIcon!.isNotEmpty)
                                  ? Image.network(
                                      widget.chat!.imageIcon!.startsWith('http')
                                          ? widget.chat!.imageIcon!
                                          : '${Urls.baseUrl}${widget.chat!.imageIcon!.startsWith('/') ? '' : '/'}${widget.chat!.imageIcon!}',
                                      width: 48.r,
                                      height: 48.r,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.person),
                                    )
                                  : Text(
                                      (widget.chat?.name != null &&
                                              widget.chat!.name!.isNotEmpty)
                                          ? widget.chat!.name![0].toUpperCase()
                                          : "?",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Colors.primaries[(widget
                                                            .chat
                                                            ?.name ??
                                                        "")
                                                    .hashCode %
                                                Colors.primaries.length],
                                      ),
                                    ),
                            ),
                          ),
                          // Online Dot
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              height: 12.h,
                              width: 12.w,
                              decoration: BoxDecoration(
                                color: widget.chat?.status == 'online'
                                    ? Colors.green
                                    : Colors.grey,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 12.w),
                      // Name + Status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${widget.chat?.name ?? 'Chat'}",
                              style: TextStyle(
                                fontSize: 14.sp.clamp(14, 16),
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.chat?.status == 'online'
                                  ? 'online'
                                  : 'offline',
                              style: TextStyle(
                                fontSize: 12.sp.clamp(12, 14),
                                color: widget.chat?.status == 'online'
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          actions: [
            IconButton(
              onPressed: () {
                // TODO: Implement voice call functionality
              },
              icon: const Icon(Icons.call_outlined),
            ),
            IconButton(
              onPressed: () {
                // TODO: Implement video call functionality
              },
              icon: const Icon(Icons.videocam_outlined),
            ),
            IconButton(
              onPressed: () {
                // TODO: Show more options menu
              },
              icon: const Icon(Icons.more_vert),
            ),
            SizedBox(width: 8.w),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer2<ChatController, ProfileController>(
              builder: (context, chatController, profileController, child) {
                if (chatController.inProgress &&
                    chatController.messageList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (chatController.messageList.isEmpty) {
                  return const Center(child: Text("Say Hello! 👋"));
                }

                final messages = chatController.messageList;
                final myId =
                    AuthController().userId ??
                    profileController.currentUser?.id;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe =
                        message.sender != null &&
                        myId != null &&
                        message.sender!.toString().trim() ==
                            myId.toString().trim();

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFF2B004E)
                              : Colors.grey[900],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                            bottomLeft: isMe
                                ? Radius.circular(16.r)
                                : Radius.zero,
                            bottomRight: isMe
                                ? Radius.zero
                                : Radius.circular(16.r),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.image != null &&
                                message.image!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.network(
                                    message.image!.startsWith('http')
                                        ? message.image!
                                        : '${Urls.baseUrl}${message.image!.startsWith('/') ? '' : '/'}${message.image!}',
                                    height: 150.h,
                                    width: 200.w,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                            ),
                                  ),
                                ),
                              ),
                            Text(
                              message.text ?? '',
                              style: TextStyle(
                                color: Colors
                                    .white, // Always white for dark bubbles
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedImage != null)
                  Container(
                    padding: EdgeInsets.all(8.r),
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(
                            File(_selectedImage!.path),
                            height: 100.h,
                            width: 100.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 16.r,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _pickImage,
                        icon: Icon(Icons.image_outlined),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            // color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: TextFormField(
                            controller: _textController,
                            maxLines: 5,
                            minLines: 1,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 15.w,
                                vertical: 10.h,
                              ),
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final text = _textController.text.trim();
                          final imagePath = _selectedImage?.path;

                          if (text.isEmpty && imagePath == null) return;

                          if (widget.chat?.id == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Cannot send message: Chat ID missing",
                                ),
                              ),
                            );
                            return;
                          }

                          // Store original text in case of failure
                          final originalText = _textController.text;

                          _textController.clear();
                          setState(() {
                            _selectedImage = null;
                          });

                          bool success = await context
                              .read<ChatController>()
                              .sendMessage(
                                widget.chat!.id!,
                                text.isEmpty ? null : text,
                                imagePath: imagePath,
                              );

                          if (success) {
                            if (_scrollController.hasClients) {
                              _scrollController.animateTo(
                                0.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          } else {
                            // Restore text on failure
                            _textController.text = originalText;
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to send message"),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 5, left: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFB026FF), Color(0xFFFF006E)],
                            ),
                          ),
                          height: 44.r,
                          width: 44.r,
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
