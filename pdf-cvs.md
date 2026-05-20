# Calculations PDF & CSV Export Integration Guide (Flutter)

আপনার ক্যালকুলেশন পিডিএফ এবং সিএসভি ফাইলে সমস্ত ডাটা সঠিকভাবে প্রদর্শন না করার সমস্যাটি সমাধান করা হয়েছে! 

## ১. সমস্যাটির কারণ এবং সমাধান (The Root Cause & Fix)

1. **Mongoose nested object gotcha (Backend Fix):**
   ব্যাকএন্ডে `getExportDataFromDB` মেথডটি Mongoose-এর মাধ্যমে হিসাবগুলো তুলে আনার সময় `.lean()` ব্যবহার করছিল না। এর ফলে, MongoDB সাব-ডকুমেন্টসমূহ (যেমন `loadData`, `goalData`, `costData`) স্প্রেড করার সময় তাদের অভ্যন্তরীণ ভ্যালুগুলো সিএসভি এবং পিডিএফে আসছিল না (শুধুমাত্র ID এবং Type শো করছিল)। 
   * **আমরা ব্যাকএন্ড সার্ভিসটি সংশোধন করে দিয়েছি** যাতে এটি ডিরেক্ট ফ্ল্যাট অবজেক্ট রিটার্ন করে এবং সমস্ত ডাটা ফ্রন্টএন্ডে পাঠায়।

2. **Robust Multi-level Data Retrieval (Flutter Controller Fix):**
   কন্ট্রোলারে ডাটা রিট্রিভ করার জন্য আমরা একটি চমৎকার `getValue` হেল্পার যুক্ত করেছি যা ফ্লাটার ক্লায়েন্ট-সাইডে ফ্ল্যাট ডাটা বা নেস্টেড ডাটা (যেকোনো ফরম্যাট) ব্যাকএন্ড থেকে আসলে তা শতভাগ নির্ভুলভাবে খুঁজে বের করবে।

3. **Premium Grouped PDF Report:**
   সব হিসাবের ডাটা একই টেবিলে দেখালে তা অনেক অগোছালো লাগছিল। এখন আমরা পিডিএফ-কে ৩টি ভিন্ন সেকশনে (Load Surcharge, Goal Target, এবং CPM operating costs) বিভক্ত করেছি। এতে **প্রতিটি হিসাবের সমস্ত ডাটা (যেমন tolls, fuel cost, true CPM, driver percentage ইত্যাদি) পৃথক এবং অত্যন্ত রিডেবল কলামে প্রদর্শিত হবে**।

---

## ২. সংশোধিত `CalculationController.dart` কোড

আপনার `lib/Service/Controller/calculation_controller.dart` ফাইলে পিডিএফ এক্সপোর্টের মেথডটি সম্পূর্ণ নিখুঁতভাবে আপডেট করে দেওয়া হয়েছে। নিচে পূর্ণাঙ্গ কোডটি রেফারেন্সের জন্য দেওয়া হলো:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:truckcalc/Model/exported_calculation.dart';
import 'package:truckcalc/Service/Api%20service/calculation_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ... (বাকি মেথডগুলো পূর্বের ন্যায় অপরিবর্তিত থাকবে)

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
                          "Freight2You Trucking Financial Report", 
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
                    'Date', 'Base Rate', 'Loaded Mi', 'Fuel Sur', 'DH Miles', 'Tolls/Bon', 
                    'Revenue', 'Cost', 'Driver Pay', 'Owner Pay', 'Net Profit'
                  ],
                  data: loadCalcs.map((item) {
                    final date = "${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}";
                    return [
                      date,
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
```

---

## ৩. ভেরিফিকেশন এবং টেস্টিং

১. ব্যাকএন্ড সার্ভার ও ফ্লাটার রিলোড করার পর যখন আপনি **Download CSV** অথবা **Download PDF** বাটনে ট্যাপ করবেন, তখন আপনার ফোনের ডাউনলোডে একটি চমৎকার ও সুসংগঠিত রিপোর্ট সেভ হবে।
২. আপনার পিডিএফে প্রতিটি ট্রাক ক্যালকুলেশনের নিখুঁত কলাম (যেমন `driverPay`, `trueCPM`, `totalProfit`) এখন পরিষ্কারভাবে সমস্ত ডাটা প্রদর্শন করবে।