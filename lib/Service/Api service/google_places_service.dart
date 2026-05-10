import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:truckcalc/Model/location_suggestion_model.dart';
import 'package:truckcalc/Service/urls.dart';
import 'package:flutter/foundation.dart';

class GooglePlacesService {
  static const String _apiKey = Urls.googleMapsApiKey;

  static Future<List<LocationSuggestion>> searchAddress(String query) async {
    if (query.isEmpty) return [];

    final String url = 'https://places.googleapis.com/v1/places:autocomplete';

    debugPrint("🌐 Google Places (New) Request: $url");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
        },
        body: json.encode({'input': query}),
      );

      debugPrint("🌐 Google Places (New) Response Status: ${response.statusCode}");
      debugPrint("🌐 Google Places (New) Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final suggestionsData = data['suggestions'] as List?;

        if (suggestionsData == null) return [];

        List<LocationSuggestion> suggestions = [];

        for (var item in suggestionsData) {
          final prediction = item['placePrediction'];
          if (prediction == null) continue;

          final String description = prediction['text']['text'];
          final String placeId = prediction['placeId'];

          suggestions.add(
            LocationSuggestion(
              address: description,
              location: LocationData(type: placeId, coordinates: [0, 0]),
            ),
          );
        }
        return suggestions;
      }
    } catch (e) {
      debugPrint("Google Places Error: $e");
    }
    return [];
  }

  static Future<Map<String, double>?> getPlaceDetails(String placeId) async {
    final String url = 'https://places.googleapis.com/v1/places/$placeId';

    debugPrint("🌐 Google Place Details (New) Request: $url");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': 'location',
        },
      );

      debugPrint("🌐 Google Place Details Status: ${response.statusCode}");
      debugPrint("🌐 Google Place Details Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['location'];
        return {
          'lat': (location['latitude'] as num).toDouble(),
          'lng': (location['longitude'] as num).toDouble(),
        };
      }
    } catch (e) {
      debugPrint("Google Place Details Error: $e");
    }
    return null;
  }
}
