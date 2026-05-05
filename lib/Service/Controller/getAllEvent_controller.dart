import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gathering_app/Model/get_all_event_model.dart';
import 'package:gathering_app/Service/Api service/network_caller.dart';
import 'package:gathering_app/Service/urls.dart';

class GetAllEventController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;

  List<EventData> _allEvents = [];
  List<EventData> _filteredEvents = [];
  String _searchQuery = "";

  List<String> _categories = ["All"];
  String _selectedCategory = "All";

  // =========================
  //  Getters
  // =========================
  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  /// Filtered events (based on category)
  List<EventData> get events => _filteredEvents;

  //getting search query
  String get searchQuery => _searchQuery;

  //coocing search query function for user search experience;

  void updateSearchQuery(String query) {
    _searchQuery = query.trim();
    _applySearchAndFilter();
    notifyListeners();
  }

  //clear search field
  void clearSearch() {
    _searchQuery = "";
    _applySearchAndFilter();
    notifyListeners();
  }

  //coocing search query function for user search experience;
  void _applySearchAndFilter() {
    List<EventData> temp = List.from(_allEvents);

    // firs category filter
    if (_selectedCategory != "All") {
      temp = temp
          .where(
            (e) =>
                e.category?.toLowerCase().trim() ==
                _selectedCategory.toLowerCase().trim(),
          )
          .toList();
    }

    //second search category filter
    if (_searchQuery.isNotEmpty) {
      temp = temp.where((event) {
        final query = _searchQuery.toLowerCase();
        return (event.title?.toLowerCase().contains(query) ?? false) ||
            (event.address?.toLowerCase().contains(query) ?? false) ||
            (event.category?.toLowerCase().contains(query) ?? false) ||
            (event.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    _filteredEvents = temp;
  }

  /// First 1 event → Featured Section
  List<EventData> get topEvent {
    return _filteredEvents.take(_filteredEvents.isNotEmpty ? 1 : 0).toList();
  }

  /// Events for the horizontal scroll section (skip top 1, take next 5)
  List<EventData> get horizontalEvents {
    if (_filteredEvents.length <= 1) return [];
    return _filteredEvents
        .skip(1)
        .take(_filteredEvents.length >= 6 ? 5 : _filteredEvents.length - 1)
        .toList();
  }

  /// Remaining events after featured and horizontal sections → GridView
  List<EventData> get remainingEvents {
    if (_filteredEvents.length <= 6) return [];
    return _filteredEvents.skip(6).toList();
  }

  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;

  // =========================
  // 🔥 Fetch All Events
  // =========================
  Future<bool> getAllEvents() async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    // final token =
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdXRoSWQiOiI2OTNiM2VlMjAxNDcwOTJlZWUyMTY5OWUiLCJyb2xlIjoidXNlciIsIm5hbWUiOiJraGFsdCIsImVtYWlsIjoib2p6N3pia3dpNEBtcm90emlzLmNvbSIsImlhdCI6MTc2NTU2NjE3MSwiZXhwIjoxNzY2NDMwMTcxfQ.QEJQZfSlcgKLcQT_BZ46pBmRqwz0mHTceV7bDCCXHko';

    try {
      final response = await NetworkCaller.getRequest(url: Urls.getAllEvent);

      if (response.statusCode == 200) {
        // Safe body handling
        Map<String, dynamic> body;
        if (response.body is String) {
          body = jsonDecode(response.body as String);
        } else {
          body = response.body as Map<String, dynamic>;
        }

        final List rawEvents = body["data"]["data"];

        // JSON → Model
        _allEvents = rawEvents.map((e) => EventData.fromJson(e)).toList();

        // =========================
        // Extract categories
        // =========================
        // Limit categories to: All, Bars, Clubs, Lounges
        const allowedCategories = {"Bars", "Clubs", "Lounges"};
        _categories = ["All"];
        for (final e in _allEvents) {
          if (e.category != null && e.category!.trim().isNotEmpty) {
            String cat = e.category!.trim().capitalize();
            if (allowedCategories.contains(cat)) {
              _categories.add(cat);
            }
          }
        }
        _categories = _categories.toSet().toList()..sort();

        // Default filter
        applyCategoryFilter("All");

        _inProgress = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Failed to fetch events";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _inProgress = false;
    notifyListeners();
    return false;
  }

  // =========================
  // Category Filter
  // =========================
  void applyCategoryFilter(String category) {
    _selectedCategory = category;

    if (category == "All") {
      _filteredEvents = List.from(_allEvents);
    } else {
      _filteredEvents = _allEvents
          .where(
            (e) =>
                e.category?.toLowerCase().trim() ==
                category.toLowerCase().trim(),
          )
          .toList();
    }
    _applySearchAndFilter();
    notifyListeners();
  }
}

// =========================
// String Extension
// =========================
extension StringExt on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
