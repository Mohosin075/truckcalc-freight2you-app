import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:truckcalc/Model/calculation_model.dart';
import 'package:truckcalc/Model/exported_calculation.dart';
import 'package:truckcalc/Service/Api%20service/calculation_service.dart';

class CalculationController extends ChangeNotifier {
  bool _inProgress = false;
  List<CalculationModel> _calculations = [];
  Map<String, dynamic>? _stats;
  String? _errorMessage;

  bool get inProgress => _inProgress;
  List<CalculationModel> get calculations => _calculations;
  Map<String, dynamic>? get stats => _stats;
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
      await fetchStats(); // Fetch stats as well
    } catch (e) {
      _errorMessage = "Failed to load calculations";
    } finally {
      _inProgress = false;
      notifyListeners();
    }
  }

  Future<void> fetchStats() async {
    final response = await CalculationService.getStats();
    if (response.isSuccess && response.body != null) {
      _stats = response.body!['data'];
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
    _errorMessage = null;
    notifyListeners();

    try {
      final List<ExportedCalculation> list = await CalculationService.exportCalculationsFlat();
      
      if (list.isEmpty) {
        _errorMessage = "No calculations found to export";
        _inProgress = false;
        notifyListeners();
        return null;
      }

      List<List<dynamic>> rows = [];
      
      // 1. Define headers
      List<String> headers = [
        "ID", "Type", "Created At", 
        "Base Rate (\$)", "Loaded Miles", "Fuel Surcharge (\$/mi)", "Tolls (\$)", "DH Miles", "DH Rate (\$/mi)", "Bonus (\$)", 
        "Cost Per Mile (\$)", "Driver Percentage (%)", "Total FSC (\$)", "Total DH (\$)", "Total Revenue (\$)", "Total Miles", 
        "Compensation Per Mile (\$/mi)", "Total Cost (\$)", "Profit Per Mile (\$/mi)", "Total Profit (\$)", "Driver Pay (\$)", "Owner Pay (\$)",
        "Desired Weekly Profit (\$)", "Days Per Week", "Max Miles Per Day", "Deadhead Pay Per Mile (\$/mi)", "Loaded Miles Needed", 
        "Min Target Rate (\$/mi)", "Max DH Per Day", "Max DH Per Week", "Miles Per Week", "Insurance (\$)", "Truck Payment (\$)", 
        "Escrow (\$)", "Repair Savings (\$)", "Driver Pay Fixed (\$)", "Permits (\$)", "Other Fixed (\$)", "Fuel Price (\$/gal)", 
        "Avg MPG", "Oil Changes Per Year", "Cost Per Oil Change (\$)", "Tire Cost Per Year (\$)", "Maintenance Cost Per Year (\$)", 
        "Total Weekly Fixed (\$)", "Weekly Fuel Cost (\$)", "Weekly Oil Change Cost (\$)", "Weekly Tire Cost (\$)", "Weekly Maintenance Cost (\$)", 
        "Total Weekly Variable (\$)", "Total Weekly Operating Cost (\$)", "True CPM (\$/mi)"
      ];
      rows.add(headers);

      // 2. Map header column text to rawData JSON keys
      Map<String, String> fieldKeys = {
        "Base Rate (\$)": "baseRate",
        "Loaded Miles": "loadedMiles",
        "Fuel Surcharge (\$/mi)": "fuelSurcharge",
        "Tolls (\$)": "tolls",
        "DH Miles": "dhMiles",
        "DH Rate (\$/mi)": "dhRate",
        "Bonus (\$)": "bonus",
        "Cost Per Mile (\$)": "costPerMile",
        "Driver Percentage (%)": "driverPercentage",
        "Total FSC (\$)": "totalFSC",
        "Total DH (\$)": "totalDH",
        "Total Revenue (\$)": "totalRevenue",
        "Total Miles": "totalMiles",
        "Compensation Per Mile (\$/mi)": "compensationPerMile",
        "Total Cost (\$)": "totalCost",
        "Profit Per Mile (\$/mi)": "profitPerMile",
        "Total Profit (\$)": "totalProfit",
        "Driver Pay (\$)": "driverPay",
        "Owner Pay (\$)": "ownerPay",
        "Desired Weekly Profit (\$)": "desiredWeeklyProfit",
        "Days Per Week": "daysPerWeek",
        "Max Miles Per Day": "maxMilesPerDay",
        "Deadhead Pay Per Mile (\$/mi)": "deadheadPayPerMile",
        "Loaded Miles Needed": "loadedMilesNeeded",
        "Min Target Rate (\$/mi)": "minTargetRate",
        "Max DH Per Day": "maxDHPerDay",
        "Max DH Per Week": "maxDHPerWeek",
        "Miles Per Week": "milesPerWeek",
        "Insurance (\$)": "insurance",
        "Truck Payment (\$)": "truckPayment",
        "Escrow (\$)": "escrow",
        "Repair Savings (\$)": "repairSavings",
        "Driver Pay Fixed (\$)": "driverPayFixed",
        "Permits (\$)": "permits",
        "Other Fixed (\$)": "otherFixed",
        "Fuel Price (\$/gal)": "fuelPrice",
        "Avg MPG": "avgMPG",
        "Oil Changes Per Year": "oilChangesPerYear",
        "Cost Per Oil Change (\$)": "costPerOilChange",
        "Tire Cost Per Year (\$)": "tireCostPerYear",
        "Maintenance Cost Per Year (\$)": "maintenanceCostPerYear",
        "Total Weekly Fixed (\$)": "totalWeeklyFixed",
        "Weekly Fuel Cost (\$)": "weeklyFuelCost",
        "Weekly Oil Change Cost (\$)": "weeklyOilChangeCost",
        "Weekly Tire Cost (\$)": "weeklyTireCost",
        "Weekly Maintenance Cost (\$)": "weeklyMaintenanceCost",
        "Total Weekly Variable (\$)": "totalWeeklyVariable",
        "Total Weekly Operating Cost (\$)": "totalWeeklyOperatingCost",
        "True CPM (\$/mi)": "trueCPM"
      };

      // 3. Populate rows
      for (var item in list) {
        List<dynamic> row = [
          item.id,
          item.type,
          item.createdAt.toIso8601String(),
        ];
        for (String header in headers.skip(3)) {
          String? key = fieldKeys[header];
          row.add(item.rawData[key] ?? "");
        }
        rows.add(row);
      }

      // 4. Convert list of lists to CSV String using RFC 4180 pure Dart converter
      String csvString = rows.map((row) {
        return row.map((field) {
          if (field == null) return '';
          String str = field.toString();
          if (str.contains(',') || str.contains('"') || str.contains('\n') || str.contains('\r')) {
            return '"${str.replaceAll('"', '""')}"';
          }
          return str;
        }).join(',');
      }).join('\r\n');

      // 5. Save to local application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final pathOfTheFile = "${directory.path}/calculations_export_${DateTime.now().millisecondsSinceEpoch}.csv";
      final file = File(pathOfTheFile);
      await file.writeAsString(csvString);

      // 6. Share the file via native share sheet using share_plus
      await Share.shareXFiles(
        [XFile(pathOfTheFile, mimeType: 'text/csv')],
        text: 'My Calculations Export CSV',
      );

      _inProgress = false;
      notifyListeners();
      return pathOfTheFile;
    } catch (e) {
      _errorMessage = "Failed to export data: $e";
      _inProgress = false;
      notifyListeners();
      return null;
    }
  }
}
