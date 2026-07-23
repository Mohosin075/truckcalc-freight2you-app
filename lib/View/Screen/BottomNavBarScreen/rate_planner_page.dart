import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:truckcalc/Service/Controller/calculation_controller.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/customSnacBar.dart';

class RatePlannerPage extends StatefulWidget {
  const RatePlannerPage({super.key});

  @override
  State<RatePlannerPage> createState() => _RatePlannerPageState();
}

class _RatePlannerPageState extends State<RatePlannerPage> {
  final TextEditingController _desiredProfitController = TextEditingController();
  final TextEditingController _costPerMileController = TextEditingController();
  final TextEditingController _dhPayPerMileController = TextEditingController();
  final TextEditingController _daysPerWeekController = TextEditingController();
  final TextEditingController _maxMilesPerDayController = TextEditingController();
  final TextEditingController _driverPercentController = TextEditingController();

  int loadedMilesNeeded = 0;
  double minTargetRate = 0.0;
  double totalRevenue = 0.0;
  double totalCost = 0.0;
  double maxDHPerDay = 0.0;
  double maxDHPerWeek = 0.0;
  double driverPay = 0.0;
  double ownerPay = 0.0;

  @override
  void initState() {
    super.initState();
    _desiredProfitController.addListener(_calculate);
    _costPerMileController.addListener(_calculate);
    _dhPayPerMileController.addListener(_calculate);
    _daysPerWeekController.addListener(_calculate);
    _maxMilesPerDayController.addListener(_calculate);
    _driverPercentController.addListener(_calculate);
    _calculate();
  }

  void _calculate() {
    double desiredProfit = double.tryParse(_desiredProfitController.text) ?? 0.0;
    double costPerMile = double.tryParse(_costPerMileController.text) ?? 0.0;
    double dhPayPerMile = double.tryParse(_dhPayPerMileController.text) ?? 0.0;
    int daysPerWeek = int.tryParse(_daysPerWeekController.text) ?? 0;
    int maxMilesPerDay = int.tryParse(_maxMilesPerDayController.text) ?? 0;
    int driverPercent = int.tryParse(_driverPercentController.text) ?? 100;

    int totalMilesPerWeek = daysPerWeek * maxMilesPerDay;
    maxDHPerDay = maxMilesPerDay * 0.20;
    maxDHPerWeek = daysPerWeek * maxDHPerDay;
    loadedMilesNeeded = totalMilesPerWeek;

    totalCost = (loadedMilesNeeded + maxDHPerWeek) * costPerMile;
    totalRevenue = desiredProfit + totalCost;

    if ((loadedMilesNeeded + maxDHPerWeek) > 0) {
      minTargetRate = totalRevenue / (loadedMilesNeeded + maxDHPerWeek);
    } else {
      minTargetRate = 0.0;
    }

    driverPay = desiredProfit * (driverPercent / 100);
    ownerPay = desiredProfit - driverPay;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _desiredProfitController.dispose();
    _costPerMileController.dispose();
    _dhPayPerMileController.dispose();
    _daysPerWeekController.dispose();
    _maxMilesPerDayController.dispose();
    _driverPercentController.dispose();
    super.dispose();
  }

  Future<void> _saveCalculation() async {
    final desiredProfit = double.tryParse(_desiredProfitController.text.trim());
    final costPerMile = double.tryParse(_costPerMileController.text.trim());
    final daysPerWeek = int.tryParse(_daysPerWeekController.text.trim());
    final maxMilesPerDay = int.tryParse(_maxMilesPerDayController.text.trim());

    if (desiredProfit == null || desiredProfit <= 0) {
      showCustomSnackBar(
        context: context,
        message: "Please enter a valid Desired Profit greater than 0!",
        isError: true,
      );
      return;
    }

    if (costPerMile == null || costPerMile <= 0) {
      showCustomSnackBar(
        context: context,
        message: "Please enter a valid Cost Per Mile greater than 0!",
        isError: true,
      );
      return;
    }

    if (daysPerWeek == null || daysPerWeek <= 0 || daysPerWeek > 7) {
      showCustomSnackBar(
        context: context,
        message: "Please enter valid Days Per Week (1-7)!",
        isError: true,
      );
      return;
    }

    if (maxMilesPerDay == null || maxMilesPerDay <= 0) {
      showCustomSnackBar(
        context: context,
        message: "Please enter valid Max Miles Per Day greater than 0!",
        isError: true,
      );
      return;
    }

    final controller = Provider.of<CalculationController>(context, listen: false);

    final payload = {
      "type": "GOAL",
      "goalData": {
        "desiredWeeklyProfit": double.tryParse(_desiredProfitController.text) ?? 0.0,
        "costPerMile": double.tryParse(_costPerMileController.text) ?? 0.0,
        "deadheadPayPerMile": double.tryParse(_dhPayPerMileController.text) ?? 0.0,
        "daysPerWeek": int.tryParse(_daysPerWeekController.text) ?? 0,
        "maxMilesPerDay": int.tryParse(_maxMilesPerDayController.text) ?? 0,
        "driverPercentage": int.tryParse(_driverPercentController.text) ?? 100,
        "loadedMilesNeeded": loadedMilesNeeded,
        "minTargetRate": minTargetRate,
        "totalRevenue": totalRevenue,
        "totalCost": totalCost,
        "maxDHPerDay": maxDHPerDay,
        "maxDHPerWeek": maxDHPerWeek,
        "driverPay": driverPay,
        "ownerPay": ownerPay,
      }
    };

    final success = await controller.createCalculation(payload);
    if (success) {
      if (mounted) {
        showCustomSnackBar(context: context, message: "Rate plan saved!", isError: false);
      }
    } else {
      if (mounted) {
        showCustomSnackBar(context: context, message: controller.errorMessage ?? "Failed to save", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rate Planner',
                      style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
                    ),
                    Consumer<CalculationController>(
                      builder: (context, controller, child) {
                        return ElevatedButton(
                          onPressed: controller.inProgress ? null : _saveCalculation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D193),
                            minimumSize: Size(80.w, 36.h),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          ),
                          child: controller.inProgress
                              ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildWeeklyTargetsCard(),
                SizedBox(height: 16.h),
                _buildGoalSettingsCard(),
                SizedBox(height: 16.h),
                _buildCalculatedTargetsCard(),
                SizedBox(height: 16.h),
                _buildDeadheadSuggestionsCard(),
                SizedBox(height: 16.h),
                _buildEarningsSplitCard(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyTargetsCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF021C1C),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WEEKLY TARGETS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildTargetItem('Miles Needed', '$loadedMilesNeeded'),
              SizedBox(width: 40.w),
              _buildTargetItem('Min Rate/Mile', '\$${minTargetRate.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGoalSettingsCard() {
    return _buildSectionCard(
      title: 'Goal Settings',
      child: Column(
        children: [
          _buildInputField(r'Desired Weekly Profit ($)', _desiredProfitController, hintText: '2000'),
          _buildInputField(r'Cost Per Mile ($)', _costPerMileController, hintText: '1.50'),
          _buildInputField(r'Deadhead Pay Per Mile ($)', _dhPayPerMileController, hintText: '1.00'),
          Row(
            children: [
              Expanded(child: _buildInputField('Desired # of Days/Week', _daysPerWeekController, isInt: true, hintText: '5')),
              SizedBox(width: 16.w),
              Expanded(child: _buildInputField('Desired Max Miles/Day', _maxMilesPerDayController, isInt: true, hintText: '600')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatedTargetsCard() {
    return _buildSectionCard(
      title: 'Calculated Targets',
      child: Column(
        children: [
          _buildDarkResultBox('LOADED MILES NEEDED PER WEEK', '$loadedMilesNeeded miles', isGlow: true),
          SizedBox(height: 12.h),
          _buildDarkResultBox('MINIMUM TARGET RATE PER MILE', '\$${minTargetRate.toStringAsFixed(2)}', isGlow: true),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _buildResultSubBox('Total Revenue', '\$${totalRevenue.toStringAsFixed(2)}')),
              SizedBox(width: 16.w),
              Expanded(child: _buildResultSubBox('Total Cost', '\$${totalCost.toStringAsFixed(2)}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeadheadSuggestionsCard() {
    return _buildSectionCard(
      title: 'Deadhead Suggestions',
      child: Row(
        children: [
          Expanded(child: _buildResultSubBox('Max DH Per Day', '${maxDHPerDay % 1 == 0 ? maxDHPerDay.toInt() : maxDHPerDay.toStringAsFixed(1)} mi')),
          SizedBox(width: 16.w),
          Expanded(child: _buildResultSubBox('Max DH Per Week', '${maxDHPerWeek % 1 == 0 ? maxDHPerWeek.toInt() : maxDHPerWeek.toStringAsFixed(1)} mi')),
        ],
      ),
    );
  }

  Widget _buildEarningsSplitCard() {
    double driverPercentValue = (double.tryParse(_driverPercentController.text) ?? 100);
    return _buildSectionCard(
      title: 'Earnings Split',
      child: Column(
        children: [
          _buildInputField('Driver Percentage (%)', _driverPercentController, isInt: true, hintText: '25'),
          SizedBox(height: 16.h),
          _buildSplitItem('DRIVER', '${driverPercentValue.toStringAsFixed(1)}%', '\$${driverPay.toStringAsFixed(2)}'),
          SizedBox(height: 12.h),
          _buildSplitItem('OWNER', '${(100 - driverPercentValue).toStringAsFixed(1)}%', '\$${ownerPay.toStringAsFixed(2)}', color: const Color(0xFF4C86FF)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildSplitItem(String label, String percent, String value, {Color color = const Color(0xFF00D193)}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF081414),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(percent, style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
              Text(value, style: TextStyle(color: color, fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultSubBox(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF081414),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 10.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDarkResultBox(String label, String value, {bool isGlow = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isGlow ? const Color(0xFF021C1C) : const Color(0xFF081414),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isGlow ? const Color(0xFF00D193).withOpacity(0.3) : Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isGlow ? const Color(0xFF00D193) : Colors.white70,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isInt = false, String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
          style: TextStyle(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: hintText ?? (isInt ? '0' : '0.00'),
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF00D193))),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
