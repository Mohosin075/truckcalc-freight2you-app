class MessageModel {
  String? sId;
  String? chatId;
  String? sender;
  String? text;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? iV;

  MessageModel(
      {this.sId,
      this.chatId,
      this.sender,
      this.text,
      this.image,
      this.createdAt,
      this.updatedAt,
      this.iV});

  MessageModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    chatId = json['chatId'];
    // Handle sender as object or string
    if (json['sender'] is Map) {
      sender = json['sender']['_id']?.toString() ?? json['sender']['id']?.toString();
    } else {
      sender = json['sender']?.toString();
    }
    text = json['text'];
    // Handle image/images field
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      image = json['images'][0]?.toString();
    } else if (json['images'] != null) {
      image = json['images'].toString();
    } else {
      image = json['image'];
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['chatId'] = chatId;
    data['sender'] = sender;
    data['text'] = text;
    data['image'] = image;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
