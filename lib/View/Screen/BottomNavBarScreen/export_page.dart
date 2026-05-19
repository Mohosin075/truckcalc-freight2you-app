import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:truckcalc/Service/Controller/calculation_controller.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/CustomButton.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:truckcalc/View/Widgets/customSnacBar.dart';
import 'package:truckcalc/Model/calculation_model.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CalculationController>(context, listen: false).fetchCalculations();
    });
  }

  Future<void> _handleExport() async {
    final controller = Provider.of<CalculationController>(context, listen: false);
    final url = await controller.exportData();
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          showCustomSnackBar(context: context, message: "Could not launch export URL", isError: true);
        }
      }
    } else {
      if (mounted) {
        showCustomSnackBar(context: context, message: controller.errorMessage ?? "Export failed", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Consumer<CalculationController>(
            builder: (context, controller, child) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export',
                      style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00302E).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFF00D193).withOpacity(0.2)),
                      ),
                      child: Text(
                        '${controller.calculations.length} calculations ready to export',
                        style: const TextStyle(color: Color(0xFF00D193), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _buildExportCard(
                      'CSV Export',
                      'For Excel & Sheets',
                      'Spreadsheet-friendly format. Opens in Excel, Google Sheets.',
                      'Download CSV',
                      Icons.insert_drive_file,
                      controller.inProgress,
                    ),
                    SizedBox(height: 16.h),
                    _buildExportCard(
                      'PDF Export',
                      'For printing & sharing',
                      'Formatted report for printing or sharing.',
                      'Download PDF',
                      Icons.picture_as_pdf,
                      controller.inProgress,
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      'Preview',
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    _buildPreviewSection(controller.calculations),
                    SizedBox(height: 100.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExportCard(String title, String subtitle, String desc, String btnText, IconData icon, bool isLoading) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: const Color(0xFF00D193), size: 24),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  Text(subtitle, style: TextStyle(color: Colors.white38, fontSize: 11.sp)),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(desc, style: TextStyle(color: Colors.white60, fontSize: 12.sp, height: 1.4)),
          SizedBox(height: 20.h),
          CustomButton(
            buttonName: btnText,
            isYellowGradient: true,
            onPressed: isLoading ? () {} : _handleExport,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(List<CalculationModel> calculations) {
    if (calculations.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: const Center(child: Text("No data to preview", style: TextStyle(color: Colors.white38))),
      );
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: calculations.take(3).map((calc) {
          String text = "";
          if (calc.type == 'LOAD' && calc.loadData != null) {
            text = 'Load: ${calc.loadData!.loadedMiles}mi + ${calc.loadData!.dhMiles}DH = Profit: \$${calc.loadData!.totalProfit?.toStringAsFixed(0)}';
          } else if (calc.type == 'GOAL' && calc.goalData != null) {
            text = 'Goal: \$${calc.goalData!.desiredWeeklyProfit} = Need ${calc.goalData!.milesNeeded}mi';
          } else if (calc.type == 'COST' && calc.costData != null) {
            text = 'Costs: Fixed \$${calc.costData!.totalWeeklyFixedCosts?.toStringAsFixed(0)} + Variable \$${calc.costData!.totalWeeklyVariableCosts?.toStringAsFixed(0)}';
          }
          return _previewItem(text);
        }).toList(),
      ),
    );
  }

  Widget _previewItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        text,
        style: TextStyle(color: Colors.white38, fontSize: 11.sp, height: 1.5),
      ),
    );
  }
}
