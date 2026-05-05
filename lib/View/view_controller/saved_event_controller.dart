import 'package:flutter/material.dart';
import 'package:gathering_app/Model/get_all_event_model.dart'; // EventData model এখানে আছে ধরে নিচ্ছি
import 'package:gathering_app/Service/Api%20service/network_caller.dart';
import 'package:gathering_app/Service/urls.dart';

class SavedEventController extends ChangeNotifier {
  final List<SavedEventData> _savedEvents = [];
  bool _inProgress = false;
  String? _errorMessage;

  List<SavedEventData> get savedEvents => _savedEvents;
  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  // চেক করা যে এই event টা saved কি না
  bool isSaved(EventData event) {
    return _savedEvents.any((e) => e.event.id == event.id);
  }

  // Save / Unsave toggle
  Future<bool?> toggleSave(EventData event) async {
    _inProgress = true;
    notifyListeners();

    bool? result;

    try {
      final existingSaved = _savedEvents.cast<SavedEventData?>().firstWhere(
        (e) => e?.event.id == event.id,
        orElse: () => null,
      );

      if (existingSaved != null) {
        final response = await NetworkCaller.deleteRequest(
          Urls.deleteSavedEvent(existingSaved.savedId),
          requireAuth: true,
        );

        debugPrint("Delete response: ${response.body}");

        if (response.isSuccess && response.body?['success'] == true) {
          _savedEvents.remove(existingSaved);
          result = false; // unsaved
        } else {
          _errorMessage = response.body?['message'] ?? "Failed to unsave";
          result = null;
        }
      } else {
        
        final response = await NetworkCaller.postRequest(
          url: Urls.addSaveEvent,
          body: {"event": event.id!},
          requireAuth: true,
        );

        debugPrint("Save response: ${response.body}");

        if (response.isSuccess &&
            response.body?['success'] == true &&
            response.body?['data'] != null) {
          final String newSavedId = response.body!['data']['_id'] as String;

          final newSaved = SavedEventData(
            savedId: newSavedId,
            event: event, // full event object directly
          );

          _savedEvents.add(newSaved);
          result = true;
        } else {
          _errorMessage = response.body?['message'] ?? "Failed to save";
          result = null;
        }
      }
    } catch (e) {
      debugPrint("Toggle save error: $e");
      _errorMessage = "Something went wrong";
      result = null;
    }

    _inProgress = false;
    notifyListeners();
    return result;
  }

  // আমার সব saved events লোড করো
  Future<void> loadMySavedEvents() async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.getMySaveEvents,
        requireAuth: true,
      );

      debugPrint("Load saved events raw response: ${response.body}");

      if (response.isSuccess && response.body != null) {
        final List<dynamic> list =
            response.body!['data']['data'] as List<dynamic>;

        _savedEvents.clear();

        for (var json in list) {
          try {
            final savedEvent = SavedEventData.fromJson(json);
            _savedEvents.add(savedEvent);
          } catch (e) {
            debugPrint("Error parsing saved event: $e, json: $json");
          }
        }

        debugPrint("Successfully loaded ${_savedEvents.length} saved events");
      } else {
        _errorMessage =
            response.body?['message'] ?? "Failed to load saved events";
      }
    } catch (e) {
      debugPrint("Load saved events error: $e");
      _errorMessage = "Network error";
    }

    _inProgress = false;
    notifyListeners();
  }
}

// SavedEvent এর জন্য আলাদা model (এটা রাখতেই হবে)
class SavedEventData {
  final String savedId; // savedEvent এর _id
  final EventData event; // full populated event

  SavedEventData({required this.savedId, required this.event});

  // এখন আর কোনো fallback নেই → backend populated data দিচ্ছে
  factory SavedEventData.fromJson(Map<String, dynamic> json) {
    return SavedEventData(
      savedId: json['_id'] as String,
      event: EventData.fromJson(json['event'] as Map<String, dynamic>),
    );
  }
}
