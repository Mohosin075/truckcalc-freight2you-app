class NotificationModel {
  int? statusCode;
  bool? success;
  String? message;
  Meta? meta;
  List<NotificationData>? data;

  NotificationModel(
      {this.statusCode, this.success, this.message, this.meta, this.data});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    message = json['message'];
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['data'] != null && json['data'] is List) {
      data = <NotificationData>[];
      json['data'].forEach((v) {
        data!.add(NotificationData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['success'] = success;
    data['message'] = message;
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SingleNotificationModel {
  int? statusCode;
  bool? success;
  String? message;
  NotificationData? data;

  SingleNotificationModel({this.statusCode, this.success, this.message, this.data});

  SingleNotificationModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? NotificationData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Meta {
  int? page;
  int? limit;
  int? total;
  int? totalPages;

  Meta({this.page, this.limit, this.total, this.totalPages});

  Meta.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['limit'] = limit;
    data['total'] = total;
    data['totalPages'] = totalPages;
    return data;
  }
}

class NotificationData {
  String? sId;
  UserId? userId;
  String? title;
  String? content;
  String? type;
  String? channel;
  String? status;
  String? priority;
  bool? isRead;
  bool? isArchived;
  String? createdAt;
  String? updatedAt;
  int? iV;
  Analytics? analytics;

  NotificationData(
      {this.sId,
      this.userId,
      this.title,
      this.content,
      this.type,
      this.channel,
      this.status,
      this.priority,
      this.isRead,
      this.isArchived,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.analytics});

  NotificationData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId =
        json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    title = json['title'];
    content = json['content'];
    type = json['type'];
    channel = json['channel'];
    status = json['status'];
    priority = json['priority'];
    isRead = json['isRead'];
    isArchived = json['isArchived'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    analytics = json['analytics'] != null
        ? Analytics.fromJson(json['analytics'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    data['title'] = title;
    data['content'] = content;
    data['type'] = type;
    data['channel'] = channel;
    data['status'] = status;
    data['priority'] = priority;
    data['isRead'] = isRead;
    data['isArchived'] = isArchived;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (analytics != null) {
      data['analytics'] = analytics!.toJson();
    }
    return data;
  }
}

class UserId {
  String? sId;
  String? name;
  String? email;

  UserId({this.sId, this.name, this.email});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    return data;
  }
}

class Analytics {
  int? openRate;
  int? engagement;

  Analytics({this.openRate, this.engagement});

  Analytics.fromJson(Map<String, dynamic> json) {
    openRate = json['openRate'];
    engagement = json['engagement'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['openRate'] = openRate;
    data['engagement'] = engagement;
    return data;
  }
}
