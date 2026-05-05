class ChatModel {
  String? name;
  String? currentMessage;
  String? imageIcon;
  String? time;
  bool? isGroup;
  String? status;
  String? id;
  String? otherUserId;
  bool? isSeen;

  ChatModel({
    this.name,
    this.id,
    this.otherUserId,
    this.currentMessage,
    this.imageIcon,
    this.isGroup,
    this.status,
    this.time,
    this.isSeen,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      name: json['name']?.toString(),
      id: json['_id']?.toString() ?? json['id']?.toString(),
      otherUserId: json['otherUserId']?.toString(),
      currentMessage: json['currentMessage']?.toString() ?? json['lastMessage']?['text']?.toString(),
      imageIcon: json['imageIcon']?.toString() ?? json['profile']?.toString() ?? json['profileImage']?.toString(),
      isGroup: json['isGroup'] as bool? ?? false,
      status: json['status']?.toString() ?? 'offline',
      time: json['time']?.toString() ?? json['updatedAt']?.toString(),
      isSeen: json['isSeen'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      '_id': id,
      'otherUserId': otherUserId,
      'currentMessage': currentMessage,
      'imageIcon': imageIcon,
      'isGroup': isGroup,
      'status': status,
      'time': time,
      'isSeen': isSeen,
    };
  }
}