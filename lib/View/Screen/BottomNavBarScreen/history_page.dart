import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:truckcalc/Model/calculation_model.dart';
import 'package:truckcalc/Service/Controller/calculation_controller.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:intl/intl.dart';
import 'package:truckcalc/View/Widgets/customSnacBar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CalculationController>(context, listen: false).fetchCalculations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Text(
                  'History',
                  style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search calculations...',
                    hintStyle: const TextStyle(color: Colors.white30),
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: Consumer<CalculationController>(
                  builder: (context, controller, child) {
                    if (controller.inProgress && controller.calculations.isEmpty) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF00D193)));
                    }
                    if (controller.calculations.isEmpty) {
                      return const Center(child: Text("No calculations found", style: TextStyle(color: Colors.white70)));
                    }

                    final filteredCalculations = controller.calculations.where((calculation) {
                      if (_searchQuery.isEmpty) return true;
                      final query = _searchQuery.toLowerCase();
                      
                      // Match calculation type
                      final type = (calculation.type ?? '').toLowerCase();
                      if (type.contains(query)) return true;
                      
                      // Match specific headers / details based on type
                      if (calculation.type == 'LOAD' && calculation.loadData != null) {
                        final ld = calculation.loadData!;
                        if (ld.loadNumber != null && ld.loadNumber!.toLowerCase().contains(query)) return true;
                        if (ld.loadedMiles?.toString().contains(query) ?? false) return true;
                        if (ld.totalRevenue?.toString().contains(query) ?? false) return true;
                        if (ld.totalProfit?.toString().contains(query) ?? false) return true;
                      } else if (calculation.type == 'GOAL' && calculation.goalData != null) {
                        final gd = calculation.goalData!;
                        if (gd.desiredWeeklyProfit?.toString().contains(query) ?? false) return true;
                        if (gd.loadedMilesNeeded?.toString().contains(query) ?? false) return true;
                      } else if (calculation.type == 'COST' && calculation.costData != null) {
                        final cd = calculation.costData!;
                        if (cd.totalWeeklyOperatingCost?.toString().contains(query) ?? false) return true;
                        if (cd.trueCPM?.toString().contains(query) ?? false) return true;
                      }
                      
                      // Match date
                      if (calculation.createdAt != null) {
                        try {
                          DateTime dt = DateTime.parse(calculation.createdAt!).toLocal();
                          final timeStr = DateFormat('M/d/yyyy, H:mm').format(dt).toLowerCase();
                          if (timeStr.contains(query)) return true;
                        } catch (_) {}
                      }
                      
                      return false;
                    }).toList();

                    if (filteredCalculations.isEmpty) {
                      return const Center(child: Text("No matching calculations found", style: TextStyle(color: Colors.white70)));
                    }

                    return RefreshIndicator(
                      onRefresh: () => controller.fetchCalculations(),
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: filteredCalculations.length,
                        itemBuilder: (context, index) {
                          final calculation = filteredCalculations[index];
                          return _buildHistoryCard(calculation);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(CalculationModel calculation) {
    String header = "";
    String result = "";
    
    if (calculation.type == 'LOAD' && calculation.loadData != null) {
      final ld = calculation.loadData!;
      final loadNoStr = (ld.loadNumber != null && ld.loadNumber!.isNotEmpty) ? 'Load #${ld.loadNumber}: ' : 'Load: ';
      header = '$loadNoStr${ld.loadedMiles ?? 0}mi + ${ld.dhMiles ?? 0}DH @ \$${ld.baseRate?.toStringAsFixed(2) ?? "0.00"}/mi';
      result = '= Revenue: \$${ld.totalRevenue?.toStringAsFixed(2) ?? "0.00"}, Profit: \$${ld.totalProfit?.toStringAsFixed(2) ?? "0.00"}';
    } else if (calculation.type == 'GOAL' && calculation.goalData != null) {
      final gd = calculation.goalData!;
      header = 'Weekly Goal: \$${gd.desiredWeeklyProfit?.toStringAsFixed(2) ?? "0.00"}, ${gd.daysPerWeek ?? 0} days';
      result = '= Need ${gd.loadedMilesNeeded ?? 0}mi @ \$${gd.minTargetRate?.toStringAsFixed(2) ?? "0.00"}/mi';
    } else if (calculation.type == 'COST' && calculation.costData != null) {
      final cd = calculation.costData!;
      header = 'Weekly Costs: Fixed \$${cd.totalWeeklyFixed?.toStringAsFixed(2) ?? "0.00"} + Variable \$${cd.totalWeeklyVariable?.toStringAsFixed(2) ?? "0.00"}';
      result = '= Total: \$${cd.totalWeeklyOperatingCost?.toStringAsFixed(2) ?? "0.00"}, CPM: \$${cd.trueCPM?.toStringAsFixed(2) ?? "0.00"}';
    }

    String time = "";
    if (calculation.createdAt != null) {
      try {
        DateTime dt = DateTime.parse(calculation.createdAt!).toLocal();
        time = DateFormat('M/d/yyyy, H:mm').format(dt);
      } catch (e) {
        time = calculation.createdAt!;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF081414).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(header, style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
                SizedBox(height: 10.h),
                Text(
                  result,
                  style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6.h),
                Text(time, style: TextStyle(color: Colors.white24, fontSize: 10.sp)),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () async {
              if (calculation.id != null) {
                final success = await Provider.of<CalculationController>(context, listen: false).deleteCalculation(calculation.id!);
                if (success) {
                  if (mounted) {
                    showCustomSnackBar(context: context, message: "Calculation deleted", isError: false);
                  }
                }
              }
            },
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(Icons.close, color: Colors.redAccent, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
