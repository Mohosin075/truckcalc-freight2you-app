import 'dart:convert';

// Main response model
class UserResponse {
  final int statusCode;
  final bool success;
  final String message;
  final UserData data;

  UserResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      statusCode: json['statusCode'],
      success: json['success'],
      message: json['message'],
      data: UserData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'success': success,
        'message': message,
        'data': data.toJson(),
      };
}

// User data
class UserData {
  final String id;
  final String name;
  final String email;
  final String? description;
  final Location location;
  final Settings settings;
  final List<String> interest;
  final String status;
  final bool verified;
  final bool subscribe;
  final String role;
  final String timezone;
  final bool isOnboardingComplete;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profile;
  final Stats stats;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.description,
    required this.location,
    required this.settings,
    required this.interest,
    required this.status,
    required this.verified,
    required this.subscribe,
    required this.role,
    required this.timezone,
    required this.isOnboardingComplete,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
    required this.stats,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      description: json['description'],
      location: Location.fromJson(json['location']),
      settings: Settings.fromJson(json['settings']),
      interest: List<String>.from(json['interest']),
      status: json['status'],
      verified: json['verified'],
      subscribe: json['subscribe'],
      role: json['role'],
      timezone: json['timezone'],
      isOnboardingComplete: json['isOnboardingComplete'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      profile: json['profile'],
      stats: Stats.fromJson(json['stats']),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'description': description,
        'location': location.toJson(),
        'settings': settings.toJson(),
        'interest': interest,
        'status': status,
        'verified': verified,
        'subscribe': subscribe,
        'role': role,
        'timezone': timezone,
        'isOnboardingComplete': isOnboardingComplete,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'profile': profile,
        'stats': stats.toJson(),
      };
}

// Location model
class Location {
  final String type;
  final List<double> coordinates;

  Location({required this.type, required this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates'].map((x) => x.toDouble())),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'coordinates': coordinates,
      };
}

// Settings model
class Settings {
  final bool pushNotification;
  final bool emailNotification;
  final bool locationService;
  final String profileStatus;

  Settings({
    required this.pushNotification,
    required this.emailNotification,
    required this.locationService,
    required this.profileStatus,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      pushNotification: json['pushNotification'],
      emailNotification: json['emailNotification'],
      locationService: json['locationService'],
      profileStatus: json['profileStatus'],
    );
  }

  Map<String, dynamic> toJson() => {
        'pushNotification': pushNotification,
        'emailNotification': emailNotification,
        'locationService': locationService,
        'profileStatus': profileStatus,
      };
}

// Stats model
class Stats {
  final int events;
  final int followers;
  final int following;

  Stats({required this.events, required this.followers, required this.following});

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      events: json['events'],
      followers: json['followers'],
      following: json['following'],
    );
  }

  Map<String, dynamic> toJson() => {
        'events': events,
        'followers': followers,
        'following': following,
      };
}
