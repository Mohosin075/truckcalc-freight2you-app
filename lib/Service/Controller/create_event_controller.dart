import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gathering_app/Service/Api%20service/network_caller.dart';
import 'package:gathering_app/Service/Api%20service/google_places_service.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:gathering_app/Model/location_suggestion_model.dart';

class CreateEventController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;
  List<LocationSuggestion> _locationSuggestions = [];

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;
  List<LocationSuggestion> get locationSuggestions => _locationSuggestions;

  Future<void> searchLocation(String address) async {
    if (address.isEmpty) {
      _locationSuggestions = [];
      notifyListeners();
      return;
    }

    _inProgress = true;
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.searchLocation(address),
      );

      if (response.isSuccess) {
        final model = LocationSuggestionModel.fromJson(response.body ?? {});
        _locationSuggestions = model.data ?? [];
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to fetch locations';
        _locationSuggestions = [];
      }
    } catch (e) {
      _errorMessage = e.toString();
      _locationSuggestions = [];
    } finally {
      _inProgress = false;
      notifyListeners();
    }
  }

  Future<bool> createEvent(
    Map<String, dynamic> eventBody,
    List<File> images,
  ) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String dataJson = jsonEncode(eventBody);
      List<String> imagePaths = images.map((file) => file.path).toList();

      debugPrint("🚀 Creating Event...");
      debugPrint("📦 Data: $dataJson");
      debugPrint("📸 Images: ${imagePaths.length}");

      final response = await NetworkCaller.multipartRequest(
        url: Urls.createUserEvent,
        method: 'POST',
        fields: {"data": dataJson},
        fileKey: "images",
        filePaths: imagePaths,
      );

      _inProgress = false;

      if (response.isSuccess) {
        debugPrint("✅ Event Created Successfully!");
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to create event';
        debugPrint("❌ Event Creation Failed: $_errorMessage");
        notifyListeners();
        return false;
      }
    } catch (e) {
      _inProgress = false;
      _errorMessage = e.toString();
      debugPrint("🚨 Exception in createEvent: $e");
      notifyListeners();
      return false;
    }
  }
}
