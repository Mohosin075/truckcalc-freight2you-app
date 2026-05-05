class LocationSuggestionModel {
  int? statusCode;
  bool? success;
  String? message;
  List<LocationSuggestion>? data;

  LocationSuggestionModel({
    this.statusCode,
    this.success,
    this.message,
    this.data,
  });

  factory LocationSuggestionModel.fromJson(Map<String, dynamic> json) {
    return LocationSuggestionModel(
      statusCode: json['statusCode'],
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
                .map(
                  (i) => LocationSuggestion.fromJson(i as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }
}

class LocationSuggestion {
  String? address;
  LocationData? location;

  LocationSuggestion({this.address, this.location});

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      address: json['address'],
      location: json['location'] != null
          ? LocationData.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LocationData {
  String? type;
  List<double>? coordinates;

  LocationData({this.type, this.coordinates});

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      type: json['type'],
      coordinates: json['coordinates'] != null
          ? (json['coordinates'] as List)
                .map((e) => (e as num).toDouble())
                .toList()
          : null,
    );
  }

  double get longitude =>
      (coordinates != null && coordinates!.isNotEmpty) ? coordinates![0] : 0.0;
  double get latitude =>
      (coordinates != null && coordinates!.length > 1) ? coordinates![1] : 0.0;
}
