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

      // ক্যালকুলেশন টাইপ অনুযায়ী গ্রুপ করা
      final loadCalcs = list.where((e) => e.type == 'LOAD').toList();
      final goalCalcs = list.where((e) => e.type == 'GOAL').toList();
      final costCalcs = list.where((e) => e.type == 'COST').toList();

      List<List<dynamic>> csvRows = [];

      // ১. মেইন হেডার
      csvRows.add(["Trucking Financial Report"]);
      csvRows.add(["Generated on:", "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}"]);
      csvRows.add(["Total Calculations:", list.length.toString()]);
      csvRows.add([]); // ফাকা সারি

      // ২. LOAD Calculations Section
      if (loadCalcs.isNotEmpty) {
        csvRows.add(["1. Load Profit & Surcharge Calculations"]);
        csvRows.add([
          'Date', 'Load #', 'Base Rate', 'Loaded Miles', 'Fuel Surcharge', 'Deadhead Miles', 'Tolls & Bonus', 
          'Total Revenue', 'Total Cost', 'Driver Pay', 'Owner Pay', 'Net Profit'
        ]);
        
        for (var item in loadCalcs) {
          final date = "${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}";
          double tolls = double.tryParse(getValue(item, 'tolls')?.toString() ?? "0") ?? 0;
          double bonus = double.tryParse(getValue(item, 'bonus')?.toString() ?? "0") ?? 0;
          
          csvRows.add([
            date,
            getValue(item, 'loadNumber')?.toString() ?? "-",
            formatNum(getValue(item, 'baseRate'), isCurrency: true, suffix: "/mi"),
            formatNum(getValue(item, 'loadedMiles')),
            formatNum(getValue(item, 'fuelSurcharge'), isCurrency: true, suffix: "/mi"),
            formatNum(getValue(item, 'dhMiles')),
            formatNum(tolls + bonus, isCurrency: true),
            formatNum(getValue(item, 'totalRevenue'), isCurrency: true),
            formatNum(getValue(item, 'totalCost'), isCurrency: true),
            formatNum(getValue(item, 'driverPay'), isCurrency: true),
            formatNum(getValue(item, 'ownerPay'), isCurrency: true),
            formatNum(getValue(item, 'totalProfit'), isCurrency: true),
          ]);
        }
        csvRows.add([]); // ফাকা সারি
      }

      // ৩. GOAL Calculations Section
      if (goalCalcs.isNotEmpty) {
        csvRows.add(["2. Rate Planner & Weekly Goal Target Calculations"]);
        csvRows.add([
          'Date', 'Desired Profit', 'Miles Needed', 'Min Target Rate', 
          'Max DH/Week', 'Est. Revenue', 'Est. Cost', 'Driver Share', 'Owner Share'
        ]);
        
        for (var item in goalCalcs) {
          final date = "${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}";
          csvRows.add([
            date,
            formatNum(getValue(item, 'desiredWeeklyProfit'), isCurrency: true),
            formatNum(getValue(item, 'loadedMilesNeeded')),
            formatNum(getValue(item, 'minTargetRate'), isCurrency: true, suffix: "/mi"),
            formatNum(getValue(item, 'maxDHPerWeek')),
            formatNum(getValue(item, 'totalRevenue'), isCurrency: true),
            formatNum(getValue(item, 'totalCost'), isCurrency: true),
            formatNum(getValue(item, 'driverPay'), isCurrency: true),
            formatNum(getValue(item, 'ownerPay'), isCurrency: true),
          ]);
        }
        csvRows.add([]); // ফাকা সারি
      }

      // ৪. COST Calculations Section
      if (costCalcs.isNotEmpty) {
        csvRows.add(["3. CPM (Cost Per Mile) & Operating Cost Breakdown"]);
        csvRows.add([
          'Date', 'Miles/Week', 'Fixed Costs/Wk', 'Fuel Cost/Wk', 'Oil Change/Wk', 
          'Tire Cost/Wk', 'Maint Cost/Wk', 'Total Variable/Wk', 'Operating Cost/Wk', 'True CPM'
        ]);
        
        for (var item in costCalcs) {
          final date = "${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}";
          csvRows.add([
            date,
            formatNum(getValue(item, 'milesPerWeek')),
            formatNum(getValue(item, 'totalWeeklyFixed'), isCurrency: true),
            formatNum(getValue(item, 'weeklyFuelCost'), isCurrency: true),
            formatNum(getValue(item, 'weeklyOilChangeCost'), isCurrency: true),
            formatNum(getValue(item, 'weeklyTireCost'), isCurrency: true),
            formatNum(getValue(item, 'weeklyMaintenanceCost'), isCurrency: true),
            formatNum(getValue(item, 'totalWeeklyVariable'), isCurrency: true),
            formatNum(getValue(item, 'totalWeeklyOperatingCost'), isCurrency: true),
            formatNum(getValue(item, 'trueCPM'), isCurrency: true, suffix: "/mi"),
          ]);
        }
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

      // ক্যালকুলেশন টাইপ অনুযায়ী গ্রুপ করা
      final loadCalcs = list.where((e) => e.type == 'LOAD').toList();
      final goalCalcs = list.where((e) => e.type == 'GOAL').toList();
      final costCalcs = list.where((e) => e.type == 'COST').toList();

      // ২. PDF ডকুমেন্ট তৈরি করা
      final pdf = pw.Document();

      // ৩. PDF পেজ লেআউট ও টেবিল ডিজাইন করা
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          build: (pw.Context context) {
            return [
              // কাস্টম হেডার ডিজাইন
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 10),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 2)),
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
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue100,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        "TOTAL CALCS: ${list.length}", 
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)
                      ),
                    ),
                  ]
                )
              ),
              pw.SizedBox(height: 15),

              // ================= SECTION 1: LOAD CALCULATIONS =================
              if (loadCalcs.isNotEmpty) ...[
                pw.Container(
                  margin: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Text(
                    "1. Load Profit & Surcharge Calculations",
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
                  ),
                ),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                  cellStyle: const pw.TextStyle(fontSize: 6.5),
                  cellPadding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                  cellAlignment: pw.Alignment.center,
                  headers: [
                    'Date', 'Load #', 'Base Rate', 'Loaded Mi', 'Fuel Sur', 'DH Miles', 'Tolls/Bon', 
                    'Revenue', 'Cost', 'Driver Pay', 'Owner Pay', 'Net Profit'
                  ],
                  data: loadCalcs.map((item) {
                    final date = "${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}";
                    return [
                      date,
                      getValue(item, 'loadNumber')?.toString() ?? "-",
                      formatNum(getValue(item, 'baseRate'), isCurrency: true, suffix: "/mi"),
                      formatNum(getValue(item, 'loadedMiles')),
                      formatNum(getValue(item, 'fuelSurcharge'), isCurrency: true, suffix: "/mi"),
                      formatNum(getValue(item, 'dhMiles')),
                      formatNum((double.tryParse(getValue(item, 'tolls')?.toString() ?? "0") ?? 0) + (double.tryParse(getValue(item, 'bonus')?.toString() ?? "0") ?? 0), isCurrency: true),
                      formatNum(getValue(item, 'totalRevenue'), isCurrency: true),
                      formatNum(getValue(item, 'totalCost'), isCurrency: true),
                      formatNum(getValue(item, 'driverPay'), isCurrency: true),
                      formatNum(getValue(item, 'ownerPay'), isCurrency: true),
                      formatNum(getValue(item, 'totalProfit'), isCurrency: true),
                    ];
                  }).toList(),
                ),
                pw.SizedBox(height: 15),
              ],

              // ================= SECTION 2: RATE & GOAL PLANNER =================
              if (goalCalcs.isNotEmpty) ...[
                pw.Container(
                  margin: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Text(
                    "2. Rate Planner & Weekly Goal Target Calculations",
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
                  ),
                ),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7.5, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
                  cellStyle: const pw.TextStyle(fontSize: 7),
                  cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  cellAlignment: pw.Alignment.center,
                  headers: [
                    'Date', 'Desired Profit', 'Miles Needed', 'Min Target Rate', 
                    'Max DH/Wk', 'Est. Revenue', 'Est. Cost', 'Driver Share', 'Owner Share'
                  ],
                  data: goalCalcs.map((item) {
                    final date = "${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}";
                    return [
                      date,
                      formatNum(getValue(item, 'desiredWeeklyProfit'), isCurrency: true),
                      formatNum(getValue(item, 'loadedMilesNeeded')),
                      formatNum(getValue(item, 'minTargetRate'), isCurrency: true, suffix: "/mi"),
                      formatNum(getValue(item, 'maxDHPerWeek')),
                      formatNum(getValue(item, 'totalRevenue'), isCurrency: true),
                      formatNum(getValue(item, 'totalCost'), isCurrency: true),
                      formatNum(getValue(item, 'driverPay'), isCurrency: true),
                      formatNum(getValue(item, 'ownerPay'), isCurrency: true),
                    ];
                  }).toList(),
                ),
                pw.SizedBox(height: 15),
              ],

              // ================= SECTION 3: CPM (COST PER MILE) =================
              if (costCalcs.isNotEmpty) ...[
                pw.Container(
                  margin: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Text(
                    "3. CPM (Cost Per Mile) & Operating Cost Breakdown",
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
                  ),
                ),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.brown800),
                  cellStyle: const pw.TextStyle(fontSize: 6.5),
                  cellPadding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3.5),
                  cellAlignment: pw.Alignment.center,
                  headers: [
                    'Date', 'Miles/Wk', 'Fixed/Wk', 'Fuel/Wk', 'Oil/Wk', 
                    'Tires/Wk', 'Maint/Wk', 'Variable/Wk', 'Operating Cost/Wk', 'True CPM'
                  ],
                  data: costCalcs.map((item) {
                    final date = "${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}";
                    return [
                      date,
                      formatNum(getValue(item, 'milesPerWeek')),
                      formatNum(getValue(item, 'totalWeeklyFixed'), isCurrency: true),
                      formatNum(getValue(item, 'weeklyFuelCost'), isCurrency: true),
                      formatNum(getValue(item, 'weeklyOilChangeCost'), isCurrency: true),
                      formatNum(getValue(item, 'weeklyTireCost'), isCurrency: true),
                      formatNum(getValue(item, 'weeklyMaintenanceCost'), isCurrency: true),
                      formatNum(getValue(item, 'totalWeeklyVariable'), isCurrency: true),
                      formatNum(getValue(item, 'totalWeeklyOperatingCost'), isCurrency: true),
                      formatNum(getValue(item, 'trueCPM'), isCurrency: true, suffix: "/mi"),
                    ];
                  }).toList(),
                ),
              ],
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
