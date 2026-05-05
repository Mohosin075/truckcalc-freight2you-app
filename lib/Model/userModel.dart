class UserProfileModel {
  Location? location;
  Settings? settings;
  String? id;
  String? name;
  String? email;
  List<String>? interest;
  String? status;
  bool? verified;
  bool? subscribe;
  String? role;
  String? timezone;
  String? description;
  bool? isOnboardingComplete;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? profile;
  Stats? stats;
  bool? isFollowing;

  UserProfileModel({
    this.location,
    this.settings,
    this.id,
    this.name,
    this.email,
    this.interest,
    this.status,
    this.verified,
    this.subscribe,
    this.role,
    this.timezone,
    this.description,
    this.isOnboardingComplete,
    this.createdAt,
    this.updatedAt,
    this.profile,
    this.stats,
    this.isFollowing,
  });

  // API response থেকে model বানানো
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      settings: json['settings'] != null
          ? Settings.fromJson(json['settings'])
          : null,
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      email: json['email'] ?? '',
      interest: List<String>.from(json['interest'] ?? []),
      status: json['status'] ?? '',
      verified: json['verified'] ?? false,
      subscribe: json['subscribe'] ?? false,
      role: json['role'] ?? '',
      timezone: json['timezone'] ?? '',
      isOnboardingComplete: json['isOnboardingComplete'] ?? false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      profile: json['profile'] ?? '',
      stats: json['stats'] != null
          ? Stats.fromJson(json['stats'])
          : Stats(
              events: int.tryParse((json['events'] ?? json['eventCount'] ?? json['totalEvents'] ?? '0').toString()) ?? 0,
              followers: int.tryParse((json['followers'] ?? json['followerCount'] ?? json['totalFollowers'] ?? '0').toString()) ?? 0,
              following: int.tryParse((json['following'] ?? json['followingCount'] ?? json['totalFollowing'] ?? '0').toString()) ?? 0,
            ),
      isFollowing: json['isFollowing'] ?? json['isFollowed'] ?? false,
    );
  }
Map<String, dynamic> toJson() {
  return {
    "location": location?.toJson(),           
    "settings": settings?.toJson(),        
    "id": id,
    "name": name,
    "email": email,
    "interest": interest,
    "status": status,
    "verified": verified,
    "subscribe": subscribe,
    "role": role,
    "timezone": timezone,
    "description": description,
    "isOnboardingComplete": isOnboardingComplete,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "profile": profile,
    "stats": stats?.toJson(),
    "isFollowing": isFollowing,
  };
}
}


class Location {
  final String type;
  final List<double> coordinates;

  Location({required this.type, required this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    var coords = json['coordinates'] ?? [0.0, 0.0];
    List<double> coordinates;
    if (coords is List) {
      coordinates = coords.map((e) => (e as num).toDouble()).toList();
    } else {
      coordinates = [0.0, 0.0];
    }

    return Location(
      type: json['type']?.toString() ?? 'Point',
      coordinates: coordinates,
    );
  }

  Map<String, dynamic> toJson() {
    return {"type": type, "coordinates": coordinates};
  }
}

DateTime _parseDate(String? dateStr) {
  if (dateStr == null) return DateTime.now();
  try {
    return DateTime.parse(dateStr);
  } catch (e) {
    return DateTime.now();
  }
}

class Settings {
  bool pushNotification;
  bool emailNotification;
  bool locationService;
  String profileStatus;

  Settings({
    required this.pushNotification,
    required this.emailNotification,
    required this.locationService,
    required this.profileStatus,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      pushNotification: json['pushNotification'] ?? true,
      emailNotification: json['emailNotification'] ?? true,
      locationService: json['locationService'] ?? true,
      profileStatus: json['profileStatus'] ?? 'public',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "pushNotification": pushNotification,
      "emailNotification": emailNotification,
      "locationService": locationService,
      "profileStatus": profileStatus,
    };
  }
}

class Stats {
  final int events;
  final int followers;
  final int following;

  Stats({required this.events, required this.followers, required this.following});

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      events: int.tryParse((json['events'] ?? json['eventCount'] ?? json['totalEvents'] ?? '0').toString()) ?? 0,
      followers: int.tryParse((json['followers'] ?? json['followerCount'] ?? json['totalFollowers'] ?? '0').toString()) ?? 0,
      following: int.tryParse((json['following'] ?? json['followingCount'] ?? json['totalFollowing'] ?? '0').toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'events': events,
        'followers': followers,
        'following': following,
      };
}