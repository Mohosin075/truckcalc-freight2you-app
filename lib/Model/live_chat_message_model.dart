class LiveChatMessageModel {
  String? id;
  String? userId;
  LiveChatSender? userProfile;
  String? message;
  String? messageType;
  String? formattedTime;
  int? likes;
  bool? hasLiked;
  DateTime? createdAt;

  LiveChatMessageModel({
    this.id,
    this.userId,
    this.userProfile,
    this.message,
    this.messageType,
    this.formattedTime,
    this.likes,
    this.hasLiked,
    this.createdAt,
  });

  factory LiveChatMessageModel.fromJson(Map<String, dynamic> json) {
    return LiveChatMessageModel(
      id: json['id'] ?? json['_id'],
      userId: json['userId'],
      userProfile: json['userProfile'] != null
          ? LiveChatSender.fromJson(json['userProfile'])
          : (json['user'] != null
                ? LiveChatSender.fromJson(json['user'])
                : null),
      message: json['message'] ?? '',
      messageType: json['messageType'],
      formattedTime: json['formattedTime'],
      likes: json['likes'] ?? 0,
      hasLiked: json['hasLiked'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}

class LiveChatSender {
  String? id;
  String? name;
  String? avatar;

  LiveChatSender({this.id, this.name, this.avatar});

  factory LiveChatSender.fromJson(Map<String, dynamic> json) {
    return LiveChatSender(
      id: json['id'] ?? json['_id'],
      name: json['name'] ?? 'Guest',
      avatar:
          json['avatar'] ??
          json['profile'] ??
          json['profileImageUrl'] ??
          json['profileImage'],
    );
  }
}
