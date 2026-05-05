class GetAllEventModel {
  int? statusCode;
  bool? success;
  String? message;
  EventListData? data;

  GetAllEventModel({this.statusCode, this.success, this.message, this.data});

  factory GetAllEventModel.fromJson(Map<String, dynamic> json) {
    return GetAllEventModel(
      statusCode: json['statusCode'],
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? EventListData.fromJson(json['data']) : null,
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

class EventListData {
  Meta? meta;
  List<EventData>? data;

  EventListData({this.meta, this.data});

  factory EventListData.fromJson(Map<String, dynamic> json) {
    return EventListData(
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
                .map((v) => EventData.fromJson(v as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (meta != null) map['meta'] = meta!.toJson();
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Meta {
  int? page;
  int? limit;
  int? total;
  int? totalPages;

  Meta({this.page, this.limit, this.total, this.totalPages});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    }..removeWhere((key, value) => value == null);
  }
}

class EventData {
  Location? location;
  String? id;
  String? title;
  String? description;
  String? category;
  List<String>? tags;
  List<String>? features;
  OrganizerId? organizerId;
  String? status;
  String? visibility;
  DateTime? startDate;
  String? startTime;
  String? locationType;
  String? address;
  int? capacity;
  List<String>? images;
  List<String>? gallery;
  int? views;
  int? favorites;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? iV;
  String? price;

  EventData({
    this.location,
    this.id,
    this.title,
    this.description,
    this.category,
    this.tags,
    this.features,
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
    this.price,
  });

  factory EventData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? locationJson =
        json['location'] is Map<String, dynamic>
        ? json['location'] as Map<String, dynamic>
        : null;

    return EventData(
      location: locationJson != null ? Location.fromJson(locationJson) : null,
      id: json['_id'] ?? json['id'],
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      category:
          json['category']?.toString() ??
          ((json['vibeTags'] is List && (json['vibeTags'] as List).isNotEmpty)
              ? json['vibeTags'][0].toString()
              : json['tags'] is List && (json['tags'] as List).isNotEmpty
              ? json['tags'][0].toString()
              : null),
      tags: json['tags'] is List ? List<String>.from(json['tags']) : null,
      features: json['features'] is List
          ? List<String>.from(json['features'])
          : null,
      organizerId: json['organizerId'] != null
          ? OrganizerId.fromJson(json['organizerId'])
          : null,
      status: json['status']?.toString(),
      visibility: json['visibility']?.toString(),
      startDate: _parseDate(json['startDate']),
      startTime: json['startTime']?.toString(),
      locationType: json['locationType']?.toString(),
      address:
          json['address']?.toString() ?? locationJson?['address']?.toString(),
      capacity: json['capacity'],
      images: _parseStringList(json['images']),
      gallery: _parseStringList(json['gallery']),
      views: json['views'],
      favorites: json['favorites'],
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      iV: json['__v'],
      price: json['price']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (location != null) map['location'] = location!.toJson();
    map['_id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['category'] = category;
    map['tags'] = tags;
    map['features'] = features;
    if (organizerId != null) map['organizerId'] = organizerId!.toJson();
    map['status'] = status;
    map['visibility'] = visibility;
    map['startDate'] = startDate?.toIso8601String();
    map['startTime'] = startTime;
    map['locationType'] = locationType;
    map['address'] = address;
    map['capacity'] = capacity;
    map['images'] = images;
    map['gallery'] = gallery;
    map['views'] = views;
    map['favorites'] = favorites;
    map['createdAt'] = createdAt?.toIso8601String();
    map['updatedAt'] = updatedAt?.toIso8601String();
    map['__v'] = iV;
    map['price'] = price;
    return map;
  }

  // Helper getters for easy access in map
  double get latitude => location?.latitude ?? 23.8103; // Default Dhaka
  double get longitude => location?.longitude ?? 90.4125;

  String get safeTitle => title ?? 'No Title';
  String get safeCategory => category ?? 'unknown';
}

// Helper functions
List<String> _parseStringList(dynamic value) {
  if (value is List) {
    return value
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return [];
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return null;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type']?.toString(),
      coordinates: json['coordinates'] is List
          ? (json['coordinates'] as List)
                .map((e) => (e as num?)?.toDouble() ?? 0.0)
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'type': type, 'coordinates': coordinates};

  // Google Maps friendly getters (coordinates [lng, lat] → lat, lng)
  double get latitude =>
      (coordinates != null && coordinates!.length >= 2) ? coordinates![1] : 0.0;
  double get longitude =>
      (coordinates != null && coordinates!.length >= 2) ? coordinates![0] : 0.0;
}

class OrganizerId {
  String? id;
  String? name;
  String? email;
  String? role;
  String? timezone;

  OrganizerId({this.id, this.name, this.email, this.role, this.timezone});

  factory OrganizerId.fromJson(Map<String, dynamic> json) {
    return OrganizerId(
      id: json['_id'] ?? json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      timezone: json['timezone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'role': role,
    'timezone': timezone,
  };
}
