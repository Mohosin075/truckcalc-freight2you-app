class SingleEventDataModel {
  int? statusCode;
  bool? success;
  String? message;
  Data? data;

  SingleEventDataModel({
    this.statusCode,
    this.success,
    this.message,
    this.data,
  });

  SingleEventDataModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Location? location;
  String? sId;
  String? title;
  String? description;
  String? category;
  List<String>? tags;
  OrganizerId? organizerId;
  String? status;
  String? visibility;
  String? startDate;
  String? startTime;
  String? locationType;
  String? address;
  int? capacity;
  List<String>? images;
  List<String>? gallery;
  int? views;
  int? favorites;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? id;
  String? price;

  Data({
    this.location,
    this.sId,
    this.title,
    this.description,
    this.category,
    this.tags,
    this.organizerId,
    this.status,
    this.visibility,
    this.startDate,
    this.startTime,
    this.locationType,
    this.address,
    this.capacity,
    this.images,
    this.gallery,
    this.views,
    this.favorites,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.id,
    this.price,
  });

  Data.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? Location.fromJson(json['location'] as Map<String, dynamic>)
        : null;

    Map<String, dynamic>? locationJson =
        json['location'] is Map<String, dynamic>
        ? json['location'] as Map<String, dynamic>
        : null;

    sId = json['_id'] ?? json['id'];
    title = json['title']?.toString();
    description = json['description']?.toString();
    category =
        json['category']?.toString() ??
        ((json['vibeTags'] is List && (json['vibeTags'] as List).isNotEmpty)
            ? json['vibeTags'][0].toString()
            : json['tags'] is List && (json['tags'] as List).isNotEmpty
            ? json['tags'][0].toString()
            : null);
    tags = json['tags'] != null ? List<String>.from(json['tags']) : [];
    organizerId = json['organizerId'] != null
        ? OrganizerId.fromJson(json['organizerId'])
        : null;
    status = json['status']?.toString();
    visibility = json['visibility']?.toString();
    startDate = json['startDate']?.toString();
    startTime = json['startTime']?.toString();
    locationType = json['locationType']?.toString();
    address =
        json['address']?.toString() ?? locationJson?['address']?.toString();
    capacity = json['capacity'];
    images = json['images'] != null ? List<String>.from(json['images']) : [];
    gallery = json['gallery'] != null ? List<String>.from(json['gallery']) : [];
    views = json['views'];
    favorites = json['favorites'];
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    iV = json['__v'];
    id = json['id'] ?? json['_id'];
    price = json['price']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['category'] = this.category;
    data['tags'] = this.tags;
    if (this.organizerId != null) {
      data['organizerId'] = this.organizerId!.toJson();
    }
    data['status'] = this.status;
    data['visibility'] = this.visibility;
    data['startDate'] = this.startDate;
    data['startTime'] = this.startTime;
    data['locationType'] = this.locationType;
    data['address'] = this.address;
    data['capacity'] = this.capacity;
    data['images'] = this.images;
    data['gallery'] = this.gallery ?? [];
    data['views'] = this.views;
    data['favorites'] = this.favorites;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['id'] = this.id;
    data['price'] = this.price;
    return data;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}

class OrganizerId {
  String? sId;
  String? name;
  String? email;
  String? role;
  String? timezone;

  OrganizerId({this.sId, this.name, this.email, this.role, this.timezone});

  OrganizerId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    role = json['role'];
    timezone = json['timezone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['role'] = this.role;
    data['timezone'] = this.timezone;
    return data;
  }
}
