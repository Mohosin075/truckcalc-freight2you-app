class SavedEventModel {
  int? statusCode;
  bool? success;
  String? message;
  SavedEventData? data;

  SavedEventModel({this.statusCode, this.success, this.message, this.data});

  factory SavedEventModel.fromJson(Map<String, dynamic> json) {
    return SavedEventModel(
      statusCode: json['statusCode'],
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? SavedEventData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['statusCode'] = statusCode;
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class SavedEventData {
  String? id;
  String? user;
  String? event;
  bool? notifyBefore;
  bool? notifyReminder;
  String? savedAt;
  String? createdAt;
  String? updatedAt;
  int? v;

  SavedEventData({
    this.id,
    this.user,
    this.event,
    this.notifyBefore,
    this.notifyReminder,
    this.savedAt,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory SavedEventData.fromJson(Map<String, dynamic> json) {
    return SavedEventData(
      id: json['_id'],
      user: json['user'],
      event: json['event'],
      notifyBefore: json['notifyBefore'],
      notifyReminder: json['notifyReminder'],
      savedAt: json['savedAt'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'event': event,
      'notifyBefore': notifyBefore,
      'notifyReminder': notifyReminder,
      'savedAt': savedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
