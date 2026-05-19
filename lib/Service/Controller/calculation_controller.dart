import 'package:flutter/material.dart';
import 'package:truckcalc/Model/calculation_model.dart';
import 'package:truckcalc/Service/Api%20service/calculation_service.dart';

class CalculationController extends ChangeNotifier {
  bool _inProgress = false;
  List<CalculationModel> _calculations = [];
  String? _errorMessage;

  bool get inProgress => _inProgress;
  List<CalculationModel> get calculations => _calculations;
  String? get errorMessage => _errorMessage;

  Future<bool> createCalculation(Map<String, dynamic> payload) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    final response = await CalculationService.createCalculation(payload);

    _inProgress = false;
    if (response.isSuccess) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.errorMessage ?? "Failed to create calculation";
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchCalculations() async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _calculations = await CalculationService.getMyCalculations();
    } catch (e) {
      _errorMessage = "Failed to load calculations";
    } finally {
      _inProgress = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCalculation(String id) async {
    _inProgress = true;
    notifyListeners();

    final response = await CalculationService.deleteCalculation(id);

    _inProgress = false;
    if (response.isSuccess) {
      _calculations.removeWhere((element) => element.id == id);
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.errorMessage ?? "Failed to delete calculation";
      notifyListeners();
      return false;
    }
  }

  Future<String?> exportData() async {
    _inProgress = true;
    notifyListeners();

    final response = await CalculationService.exportData();

    _inProgress = false;
    notifyListeners();

    if (response.isSuccess && response.body != null) {
      return response.body!['data']['url'];
    } else {
      _errorMessage = response.errorMessage ?? "Failed to export data";
      return null;
    }
  }
}
