import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:truckcalc/Model/calculation_model.dart';
import 'package:truckcalc/Model/exported_calculation.dart';
import 'package:truckcalc/Service/Api%20service/calculation_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CalculationController extends ChangeNotifier {
  bool _inProgress = false;
  List<CalculationModel> _calculations = [];
  Map<String, dynamic>? _stats;
  String? _errorMessage;

  bool get inProgress => _inProgress;
  List<CalculationModel> get calculations => _calculations;
  Map<String, dynamic>? get stats => _stats;
  String? get errorMessage => _errorMessage;

  bool get isPremium {
    if (_stats == null) return false;
    final planName = _stats!['planName'] ?? 'No Plan';
    final subscriptionStatus = _stats!['subscriptionStatus'] ?? 'none';
    return (planName == 'Pro' || planName == 'Annual') &&
        (subscriptionStatus == 'active' || subscriptionStatus == 'trialing');
  }

  bool get isTrialExpired {
    if (_stats == null) return false;
    if (isPremium) return false;
    final planName = _stats!['planName'] ?? '';
    final daysLeft = _stats!['planLeftDays'] ?? 0;
    return _stats!['isTrialExpired'] == true ||
        planName == 'Expired Trial' ||
        (planName == 'Free Trial' && daysLeft <= 0);
  }

  Future<bool> createCalculation(Map<String, dynamic> payload) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    final response = await CalculationService.createCalculation(payload);

    if (response.isSuccess) {
      await fetchCalculations();
      return true;
    } else {
      _inProgress = false;
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

      // ডাটা রিট্রিভ করার হেল্পার
      dynamic getValue(ExportedCalculation item, String key) {
        if (item.rawData.containsKey(key)) {
          return item.rawData[key];
        }
        if (item.rawData['loadData'] is Map && item.rawData['loadData'].containsKey(key)) {
          return item.rawData['loadData'][key];
        }
        if (item.rawData['costData'] is Map && item.rawData['costData'].containsKey(key)) {
          return item.rawData['costData'][key];
        }
        if (item.rawData['goalData'] is Map && item.rawData['goalData'].containsKey(key)) {
          return item.rawData['goalData'][key];
        }
        return null;
      }

      // সংখ্যা বা কারেন্সি ফরম্যাট করার হেল্পার
      String formatNum(dynamic val, {bool isCurrency = false, String suffix = ""}) {
        if (val == null || val == "") return "-";
        double? numVal = double.tryParse(val.toString());
        if (numVal == null) return val.toString();
        String formatted = numVal.toStringAsFixed(2);
        if (formatted.endsWith(".00")) {
          formatted = formatted.substring(0, formatted.length - 3);
        }
        return isCurrency ? "\$$formatted$suffix" : "$formatted$suffix";
      }

      // ৪টি প্রয়োজনীয় ফিল্ড নিখুঁতভাবে এক্সট্রাক্ট করার হেল্পার
      Map<String, double> extract4Fields(ExportedCalculation item) {
        // ১. Total (include DH and loaded miles)
        double loadedMiles = double.tryParse(getValue(item, 'loadedMiles')?.toString() ?? "0") ?? 0;
        double dhMiles = double.tryParse(getValue(item, 'dhMiles')?.toString() ?? "0") ?? 0;
        double totalMiles = double.tryParse(getValue(item, 'totalMiles')?.toString() ?? "0") ?? 0;
        if (totalMiles == 0 && (loadedMiles > 0 || dhMiles > 0)) {
          totalMiles = loadedMiles + dhMiles;
        }
        if (totalMiles == 0 && item.type == 'GOAL') {
          totalMiles = double.tryParse(getValue(item, 'loadedMilesNeeded')?.toString() ?? "0") ?? 0;
        }
        if (totalMiles == 0 && item.type == 'COST') {
          totalMiles = double.tryParse(getValue(item, 'milesPerWeek')?.toString() ?? "0") ?? 0;
        }

        // ২. Total Gross Revenue (Includes: Fuel Surcharge paid, Tolls paid, DH paid and bonuses paid)
        double baseRate = double.tryParse(getValue(item, 'baseRate')?.toString() ?? "0") ?? 0;
        double fuelSurcharge = double.tryParse(getValue(item, 'fuelSurcharge')?.toString() ?? "0") ?? 0;
        double dhRate = double.tryParse(getValue(item, 'dhRate')?.toString() ?? "0") ?? 0;
        double tolls = double.tryParse(getValue(item, 'tolls')?.toString() ?? "0") ?? 0;
        double bonus = double.tryParse(getValue(item, 'bonus')?.toString() ?? "0") ?? 0;
        double totalFSC = double.tryParse(getValue(item, 'totalFSC')?.toString() ?? "0") ?? (fuelSurcharge * loadedMiles);
        double totalDH = double.tryParse(getValue(item, 'totalDH')?.toString() ?? "0") ?? (dhRate * dhMiles);

        double totalRevenue = double.tryParse(getValue(item, 'totalRevenue')?.toString() ?? "0") ?? 0;
        if (totalRevenue == 0 && item.type == 'LOAD') {
          totalRevenue = (baseRate * loadedMiles) + totalFSC + totalDH + bonus + tolls;
        }

        // ৩. Total Costs
        double totalCost = double.tryParse(getValue(item, 'totalCost')?.toString() ?? "0") ?? 0;
        if (totalCost == 0 && item.type == 'LOAD') {
          double costPerMile = double.tryParse(getValue(item, 'costPerMile')?.toString() ?? "0") ?? 0;
          totalCost = totalMiles * costPerMile;
        }
        if (totalCost == 0 && item.type == 'COST') {
          totalCost = double.tryParse(getValue(item, 'totalWeeklyOperatingCost')?.toString() ?? "0") ?? 0;
        }

        // ৪. Total Net Profit
        double totalProfit = double.tryParse(getValue(item, 'totalProfit')?.toString() ?? "0") ?? 0;
        if (totalProfit == 0 && (totalRevenue != 0 || totalCost != 0)) {
          totalProfit = totalRevenue - totalCost;
        }
        if (totalProfit == 0 && item.type == 'GOAL') {
          totalProfit = double.tryParse(getValue(item, 'desiredWeeklyProfit')?.toString() ?? "0") ?? (totalRevenue - totalCost);
        }

        return {
          'totalMiles': totalMiles,
          'totalRevenue': totalRevenue,
          'totalCost': totalCost,
          'totalProfit': totalProfit,
        };
      }

      String getTitle(ExportedCalculation item) {
        if (item.type == 'LOAD') {
          final loadNum = getValue(item, 'loadNumber')?.toString().trim();
          return (loadNum != null && loadNum.isNotEmpty && loadNum != '-')
              ? "Load #$loadNum"
              : "Load Calculation";
        } else if (item.type == 'GOAL') {
          return "Weekly Goal";
        } else if (item.type == 'COST') {
          return "Operating Cost";
        }
        return "Calculation";
      }

      String getDate(ExportedCalculation item) {
        return "${item.createdAt.day.toString().padLeft(2, '0')}/${item.createdAt.month.toString().padLeft(2, '0')}/${item.createdAt.year}";
      }

      final targetList = list;

      List<List<dynamic>> csvRows = [];

      // Date এবং Calculation / Load # কলাম সহ হেডার
      csvRows.add([
        "Date",
        "Calculation #",
        "Total (include DH and loaded miles)",
        "Total Gross Revenue",
        "Total Costs",
        "Total Net Profit"
      ]);

      double sumMiles = 0;
      double sumRevenue = 0;
      double sumCosts = 0;
      double sumProfit = 0;

      for (var item in targetList) {
        final data = extract4Fields(item);
        sumMiles += data['totalMiles']!;
        sumRevenue += data['totalRevenue']!;
        sumCosts += data['totalCost']!;
        sumProfit += data['totalProfit']!;

        csvRows.add([
          getDate(item),
          getTitle(item),
          formatNum(data['totalMiles']),
          formatNum(data['totalRevenue']),
          formatNum(data['totalCost']),
          formatNum(data['totalProfit']),
        ]);
      }

      // একাধিক লোড থাকলে নিচে সামারি/টোটাল রো যোগ করা
      if (targetList.length > 1) {
        csvRows.add([
          "TOTAL",
          "-",
          formatNum(sumMiles),
          formatNum(sumRevenue),
          formatNum(sumCosts),
          formatNum(sumProfit),
        ]);
      }

      // ৫. List of lists-কে RFC 4180 কমপ্লায়েন্ট CSV স্ট্রিং-এ রূপান্তর করা
      String csvString = csvRows.map((row) {
        return row.map((field) {
          if (field == null) return '';
          String str = field.toString();
          if (str.contains(',') || str.contains('"') || str.contains('\n') || str.contains('\r')) {
            return '"${str.replaceAll('"', '""')}"';
          }
          return str;
        }).join(',');
      }).join('\r\n');

      // ৬. সাময়িকভাবে অ্যাপের টেম্পোরারি ডিরেক্টরিতে সিএসভি ফাইলটি তৈরি করা
      final directory = await getTemporaryDirectory();
      final pathOfTheFile = "${directory.path}/calculations_export_${DateTime.now().millisecondsSinceEpoch}.csv";
      final file = File(pathOfTheFile);
      await file.writeAsString(csvString);

      // ৭. নেটিভ সেভ ফাইল ডায়ালগ ওপেন করা
      final params = SaveFileDialogParams(sourceFilePath: pathOfTheFile);
      final filePath = await FlutterFileDialog.saveFile(params: params);

      _inProgress = false;
      notifyListeners();
      return filePath;
    } catch (e) {
      _errorMessage = "Failed to export CSV: $e";
      _inProgress = false;
      notifyListeners();
      return null;
    }
  }

  // calculations ডাটা নিয়ে একটি সুন্দর PDF টেবিল রিপোর্ট তৈরি এবং ডাউনলোড করা
  Future<String?> exportDataAsPDF() async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // ১. ব্যাকএন্ড থেকে হিসাবের তালিকা তুলে আনা
      final List<ExportedCalculation> list = await CalculationService.exportCalculationsFlat();

      if (list.isEmpty) {
        _errorMessage = "No calculations found to export";
        _inProgress = false;
        notifyListeners();
        return null;
      }

      // ডাটা রিট্রিভ করার হেল্পার (যা ফ্ল্যাট এবং নেস্টেড উভয় রেসপন্সই সফলভাবে হ্যান্ডেল করবে)
      dynamic getValue(ExportedCalculation item, String key) {
        if (item.rawData.containsKey(key)) {
          return item.rawData[key];
        }
        if (item.rawData['loadData'] is Map && item.rawData['loadData'].containsKey(key)) {
          return item.rawData['loadData'][key];
        }
        if (item.rawData['costData'] is Map && item.rawData['costData'].containsKey(key)) {
          return item.rawData['costData'][key];
        }
        if (item.rawData['goalData'] is Map && item.rawData['goalData'].containsKey(key)) {
          return item.rawData['goalData'][key];
        }
        return null;
      }

      // সংখ্যা বা কারেন্সি ফরম্যাট করার হেল্পার
      String formatNum(dynamic val, {bool isCurrency = false, String suffix = ""}) {
        if (val == null || val == "") return "-";
        double? numVal = double.tryParse(val.toString());
        if (numVal == null) return val.toString();
        String formatted = numVal.toStringAsFixed(2);
        if (formatted.endsWith(".00")) {
          formatted = formatted.substring(0, formatted.length - 3);
        }
        return isCurrency ? "\$$formatted$suffix" : "$formatted$suffix";
      }

      // ৪টি প্রয়োজনীয় ফিল্ড নিখুঁতভাবে এক্সট্রাক্ট করার হেল্পার
      Map<String, double> extract4Fields(ExportedCalculation item) {
        // ১. Total (include DH and loaded miles)
        double loadedMiles = double.tryParse(getValue(item, 'loadedMiles')?.toString() ?? "0") ?? 0;
        double dhMiles = double.tryParse(getValue(item, 'dhMiles')?.toString() ?? "0") ?? 0;
        double totalMiles = double.tryParse(getValue(item, 'totalMiles')?.toString() ?? "0") ?? 0;
        if (totalMiles == 0 && (loadedMiles > 0 || dhMiles > 0)) {
          totalMiles = loadedMiles + dhMiles;
        }
        if (totalMiles == 0 && item.type == 'GOAL') {
          totalMiles = double.tryParse(getValue(item, 'loadedMilesNeeded')?.toString() ?? "0") ?? 0;
        }
        if (totalMiles == 0 && item.type == 'COST') {
          totalMiles = double.tryParse(getValue(item, 'milesPerWeek')?.toString() ?? "0") ?? 0;
        }

        // ২. Total Gross Revenue (Includes: Fuel Surcharge paid, Tolls paid, DH paid and bonuses paid)
        double baseRate = double.tryParse(getValue(item, 'baseRate')?.toString() ?? "0") ?? 0;
        double fuelSurcharge = double.tryParse(getValue(item, 'fuelSurcharge')?.toString() ?? "0") ?? 0;
        double dhRate = double.tryParse(getValue(item, 'dhRate')?.toString() ?? "0") ?? 0;
        double tolls = double.tryParse(getValue(item, 'tolls')?.toString() ?? "0") ?? 0;
        double bonus = double.tryParse(getValue(item, 'bonus')?.toString() ?? "0") ?? 0;
        double totalFSC = double.tryParse(getValue(item, 'totalFSC')?.toString() ?? "0") ?? (fuelSurcharge * loadedMiles);
        double totalDH = double.tryParse(getValue(item, 'totalDH')?.toString() ?? "0") ?? (dhRate * dhMiles);

        double totalRevenue = double.tryParse(getValue(item, 'totalRevenue')?.toString() ?? "0") ?? 0;
        if (totalRevenue == 0 && item.type == 'LOAD') {
          totalRevenue = (baseRate * loadedMiles) + totalFSC + totalDH + bonus + tolls;
        }

        // ৩. Total Costs
        double totalCost = double.tryParse(getValue(item, 'totalCost')?.toString() ?? "0") ?? 0;
        if (totalCost == 0 && item.type == 'LOAD') {
          double costPerMile = double.tryParse(getValue(item, 'costPerMile')?.toString() ?? "0") ?? 0;
          totalCost = totalMiles * costPerMile;
        }
        if (totalCost == 0 && item.type == 'COST') {
          totalCost = double.tryParse(getValue(item, 'totalWeeklyOperatingCost')?.toString() ?? "0") ?? 0;
        }

        // ৪. Total Net Profit
        double totalProfit = double.tryParse(getValue(item, 'totalProfit')?.toString() ?? "0") ?? 0;
        if (totalProfit == 0 && (totalRevenue != 0 || totalCost != 0)) {
          totalProfit = totalRevenue - totalCost;
        }
        if (totalProfit == 0 && item.type == 'GOAL') {
          totalProfit = double.tryParse(getValue(item, 'desiredWeeklyProfit')?.toString() ?? "0") ?? (totalRevenue - totalCost);
        }

        return {
          'totalMiles': totalMiles,
          'totalRevenue': totalRevenue,
          'totalCost': totalCost,
          'totalProfit': totalProfit,
        };
      }

      String getTitle(ExportedCalculation item) {
        if (item.type == 'LOAD') {
          final loadNum = getValue(item, 'loadNumber')?.toString().trim();
          return (loadNum != null && loadNum.isNotEmpty && loadNum != '-')
              ? "Load #$loadNum"
              : "Load Calculation";
        } else if (item.type == 'GOAL') {
          return "Weekly Goal";
        } else if (item.type == 'COST') {
          return "Operating Cost";
        }
        return "Calculation";
      }

      String getDate(ExportedCalculation item) {
        return "${item.createdAt.day.toString().padLeft(2, '0')}/${item.createdAt.month.toString().padLeft(2, '0')}/${item.createdAt.year}";
      }

      final targetList = list;

      double sumMiles = 0;
      double sumRevenue = 0;
      double sumCosts = 0;
      double sumProfit = 0;

      final tableData = targetList.map((item) {
        final data = extract4Fields(item);
        sumMiles += data['totalMiles']!;
        sumRevenue += data['totalRevenue']!;
        sumCosts += data['totalCost']!;
        sumProfit += data['totalProfit']!;

        return [
          getDate(item),
          getTitle(item),
          formatNum(data['totalMiles']),
          formatNum(data['totalRevenue'], isCurrency: true),
          formatNum(data['totalCost'], isCurrency: true),
          formatNum(data['totalProfit'], isCurrency: true),
        ];
      }).toList();

      if (targetList.length > 1) {
        tableData.add([
          "TOTAL",
          "-",
          formatNum(sumMiles),
          formatNum(sumRevenue, isCurrency: true),
          formatNum(sumCosts, isCurrency: true),
          formatNum(sumProfit, isCurrency: true),
        ]);
      }

      // ২. PDF ডকুমেন্ট তৈরি করা
      final pdf = pw.Document();

      // ৩. PDF পেজ লেআউট ও টেবিল ডিজাইন করা (Date + Calculation / Load # + ৪টি কলাম)
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          build: (pw.Context context) {
            return [
              // কাস্টম হেডার ডিজাইন
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 12),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blueGrey700, width: 2)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Trucking Financial Report",
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          "Generated on: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)
                        ),
                      ]
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blueGrey100,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        "RECORDS: ${targetList.length}",
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)
                      ),
                    ),
                  ]
                )
              ),
              pw.SizedBox(height: 18),

              // ================= Date, Calculation / Load # ও ৪টি কলাম সম্বলিত টেবিল =================
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                cellStyle: const pw.TextStyle(fontSize: 7.5),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6.5),
                cellAlignment: pw.Alignment.center,
                headers: [
                  'Date',
                  'Calculation #',
                  'Total (include DH and loaded miles)',
                  'Total Gross Revenue',
                  'Total Costs',
                  'Total Net Profit'
                ],
                data: tableData,
              ),
            ];
          },
        ),
      );

      // ৫. সাময়িকভাবে অ্যাপের টেম্পোরারি ডিরেক্টরিতে পিডিএফ ফাইলটি তৈরি করা
      final directory = await getTemporaryDirectory();
      final pathOfTheFile = "${directory.path}/calculations_report_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File(pathOfTheFile);
      await file.writeAsBytes(await pdf.save());

      // 6. Open Native OS Save Dialog (direct download to Downloads or custom folder)
      final params = SaveFileDialogParams(sourceFilePath: pathOfTheFile);
      final filePath = await FlutterFileDialog.saveFile(params: params);
      _inProgress = false;
      notifyListeners();
      return filePath;
    } catch (e) {
      _errorMessage = "Failed to export PDF: $e";
      _inProgress = false;
      notifyListeners();
      return null;
    }
  }
}
