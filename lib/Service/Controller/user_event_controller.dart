import 'package:flutter/material.dart';
import 'package:gathering_app/Model/get_all_event_model.dart';
import 'package:gathering_app/Service/Api%20service/network_caller.dart';
import 'package:gathering_app/Service/urls.dart';

class UserEventController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;
  List<EventData> _userEvents = [];

  List<EventData> _allUserEvents = [];
  List<EventData> _filteredUserEvents = [];
  String _searchQuery = "";

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;
  List<EventData> get userEvents => _filteredUserEvents;

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredUserEvents = List.from(_allUserEvents);
    } else {
      _filteredUserEvents = _allUserEvents.where((event) {
        return (event.title?.toLowerCase().contains(_searchQuery) ?? false) ||
            (event.address?.toLowerCase().contains(_searchQuery) ?? false) ||
            (event.category?.toLowerCase().contains(_searchQuery) ?? false) ||
            (event.description?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }
  }

  Future<bool> fetchUserEvents() async {
    _inProgress = true;
    notifyListeners();

    final response = await NetworkCaller.getRequest(url: Urls.getUserEventsUrl);

    if (response.isSuccess) {
      try {
        final GetAllEventModel model = GetAllEventModel.fromJson(
          response.body!,
        );
        if (model.data?.data != null) {
          _allUserEvents = model.data!.data!;
          _applySearch();
        } else {
          _allUserEvents = [];
          _filteredUserEvents = [];
        }
        _inProgress = false;
        notifyListeners();
        return true;
      } catch (e) {
        _errorMessage = e.toString();
        _inProgress = false;
        notifyListeners();
        return false;
      }
    } else {
      _errorMessage = response.errorMessage;
      _inProgress = false;
      notifyListeners();
      return false;
    }
  }
}
