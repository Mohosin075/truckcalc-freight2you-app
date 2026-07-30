import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:truckcalc/Service/Controller/calculation_controller.dart';
import 'package:truckcalc/Service/Controller/auth_controller.dart';
import 'package:truckcalc/Service/Api%20service/user_service.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/customSnacBar.dart';

class LoadCalculatorPage extends StatefulWidget {
  const LoadCalculatorPage({super.key});

  @override
  State<LoadCalculatorPage> createState() => _LoadCalculatorPageState();
}

class _LoadCalculatorPageState extends State<LoadCalculatorPage> {
  final TextEditingController _loadNumberController = TextEditingController();
  final TextEditingController _baseRateController = TextEditingController();
  final TextEditingController _fscController = TextEditingController();
  final TextEditingController _loadedMilesController = TextEditingController();
  final TextEditingController _tollsController = TextEditingController();
  final TextEditingController _dhMilesController = TextEditingController();
  final TextEditingController _dhRateController = TextEditingController();
  final TextEditingController _bonusController = TextEditingController();
  final TextEditingController _driverPercentController = TextEditingController();
  final TextEditingController _costPerMileController = TextEditingController();

  double totalFSC = 0.0;
  double totalDH = 0.0;
  double totalRevenue = 0.0;
  int totalMiles = 0;
  double compensationPerMile = 0.0;
  double profitPerMile = 0.0;
  double totalProfit = 0.0;
  double totalCost = 0.0;
  double driverPay = 0.0;
  double ownerPay = 0.0;

  void _loadInputsFromStorage() {
    final box = GetStorage();
    final rawInputs = box.read('load_inputs');
    final Map<String, dynamic> inputs = rawInputs is Map ? Map<String, dynamic>.from(rawInputs) : {};
    _loadNumberController.text = inputs['loadNumber']?.toString() ?? '';
    _baseRateController.text = inputs['baseRate']?.toString() ?? '';
    _fscController.text = inputs['fuelSurcharge']?.toString() ?? '';
    _loadedMilesController.text = inputs['loadedMiles']?.toString() ?? '';
    _tollsController.text = inputs['tolls']?.toString() ?? '';
    _dhMilesController.text = inputs['dhMiles']?.toString() ?? '';
    _dhRateController.text = inputs['dhRate']?.toString() ?? '';
    _bonusController.text = inputs['bonus']?.toString() ?? '';
    _driverPercentController.text = inputs['driverPercentage']?.toString() ?? '';
    _costPerMileController.text = inputs['costPerMile']?.toString() ?? '';
  }

  @override
  void initState() {
    super.initState();
    _loadInputsFromStorage();
    _baseRateController.addListener(_calculate);
    _fscController.addListener(_calculate);
    _loadedMilesController.addListener(_calculate);
    _tollsController.addListener(_calculate);
    _dhMilesController.addListener(_calculate);
    _dhRateController.addListener(_calculate);
    _bonusController.addListener(_calculate);
    _driverPercentController.addListener(_calculate);
    _costPerMileController.addListener(_calculate);
    _calculate();
  }

  void _calculate() {
    double baseRate = double.tryParse(_baseRateController.text) ?? 0.0;
    double fsc = double.tryParse(_fscController.text) ?? 0.0;
    int loadedMiles = int.tryParse(_loadedMilesController.text) ?? 0;
    double tolls = double.tryParse(_tollsController.text) ?? 0.0;
    int dhMiles = int.tryParse(_dhMilesController.text) ?? 0;
    double dhRate = double.tryParse(_dhRateController.text) ?? 0.0;
    double bonus = double.tryParse(_bonusController.text) ?? 0.0;
    int driverPercent = int.tryParse(_driverPercentController.text) ?? 100;
    double costPerMile = double.tryParse(_costPerMileController.text) ?? 0.0;

    totalFSC = fsc * loadedMiles;
    totalDH = dhRate * dhMiles;
    totalRevenue = (baseRate * loadedMiles) + totalFSC + totalDH + bonus + tolls;
    totalMiles = loadedMiles + dhMiles;
    compensationPerMile = totalMiles > 0 ? totalRevenue / totalMiles : 0.0;
    profitPerMile = compensationPerMile - costPerMile;
    totalProfit = profitPerMile * totalMiles;
    totalCost = costPerMile * totalMiles;
    driverPay = totalRevenue * (driverPercent / 100);
    ownerPay = totalRevenue - driverPay;

    if (mounted) {
      setState(() {});
    }

    final box = GetStorage();
    final draftData = {
      "loadNumber": _loadNumberController.text.trim(),
      "baseRate": _baseRateController.text.trim().isEmpty ? null : double.tryParse(_baseRateController.text),
      "fuelSurcharge": _fscController.text.trim().isEmpty ? null : double.tryParse(_fscController.text),
      "loadedMiles": _loadedMilesController.text.trim().isEmpty ? null : int.tryParse(_loadedMilesController.text),
      "tolls": _tollsController.text.trim().isEmpty ? null : double.tryParse(_tollsController.text),
      "dhMiles": _dhMilesController.text.trim().isEmpty ? null : int.tryParse(_dhMilesController.text),
      "dhRate": _dhRateController.text.trim().isEmpty ? null : double.tryParse(_dhRateController.text),
      "bonus": _bonusController.text.trim().isEmpty ? null : double.tryParse(_bonusController.text),
      "driverPercentage": _driverPercentController.text.trim().isEmpty ? null : int.tryParse(_driverPercentController.text),
      "costPerMile": _costPerMileController.text.trim().isEmpty ? null : double.tryParse(_costPerMileController.text),
    };
    box.write('load_inputs', draftData);
  }

  @override
  void dispose() {
    _loadNumberController.dispose();
    _baseRateController.dispose();
    _fscController.dispose();
    _loadedMilesController.dispose();
    _tollsController.dispose();
    _dhMilesController.dispose();
    _dhRateController.dispose();
    _bonusController.dispose();
    _driverPercentController.dispose();
    _costPerMileController.dispose();
    super.dispose();
  }

  Future<void> _saveCalculation() async {
    final baseRate = double.tryParse(_baseRateController.text.trim());
    final loadedMiles = int.tryParse(_loadedMilesController.text.trim());

    if (baseRate == null || baseRate <= 0) {
      showCustomSnackBar(
        context: context,
        message: "Please enter a valid Base Rate greater than 0!",
        isError: true,
      );
      return;
    }

    if (loadedMiles == null || loadedMiles <= 0) {
      showCustomSnackBar(
        context: context,
        message: "Please enter valid Loaded Miles greater than 0!",
        isError: true,
      );
      return;
    }

    final controller = Provider.of<CalculationController>(context, listen: false);
    
    final payload = {
      "type": "LOAD",
      "loadData": {
        "loadNumber": _loadNumberController.text.trim(),
        "baseRate": double.tryParse(_baseRateController.text) ?? 0.0,
        "fuelSurcharge": double.tryParse(_fscController.text) ?? 0.0,
        "loadedMiles": int.tryParse(_loadedMilesController.text) ?? 0,
        "tolls": double.tryParse(_tollsController.text) ?? 0.0,
        "dhMiles": int.tryParse(_dhMilesController.text) ?? 0,
        "dhRate": double.tryParse(_dhRateController.text) ?? 0.0,
        "bonus": double.tryParse(_bonusController.text) ?? 0.0,
        "driverPercentage": int.tryParse(_driverPercentController.text) ?? 100,
        "totalRevenue": totalRevenue,
        "totalProfit": totalProfit,
        "totalFSC": totalFSC,
        "totalDH": totalDH,
        "totalMiles": totalMiles,
        "compensationPerMile": compensationPerMile,
        "costPerMile": double.tryParse(_costPerMileController.text) ?? 0.0,
        "totalCost": totalCost,
        "profitPerMile": profitPerMile,
        "driverPay": driverPay,
        "ownerPay": ownerPay,
      }
    };

    final success = await controller.createCalculation(payload);
    if (success) {
      if (mounted) {
        showCustomSnackBar(context: context, message: "Load calculation saved!", isError: false);
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
                      'Load Calculator',
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
                _buildSummaryHeader(),
                SizedBox(height: 16.h),
                _buildLoadDetailsCard(),
                SizedBox(height: 16.h),
                _buildRevenueInputsCard(),
                SizedBox(height: 16.h),
                _buildDeadheadBonusCard(),
                SizedBox(height: 16.h),
                _buildSummaryTableCard(),
                SizedBox(height: 16.h),
                _buildDriverProfitCard(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF021C1C),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LOAD CALCULATOR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildSummaryItem('Total Revenue', '\$${totalRevenue.toStringAsFixed(2)}'),
              SizedBox(width: 40.w),
              _buildSummaryItem('Total Profit', '\$${totalProfit.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRevenueInputsCard() {
    return _buildSectionCard(
      title: 'Revenue Inputs',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInputField('Base Rate Per Mile', _baseRateController, hintText: '2.50')),
              SizedBox(width: 16.w),
              Expanded(child: _buildInputField('Fuel Surcharge/Mile', _fscController, hintText: '0.50')),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildInputField('Loaded Miles', _loadedMilesController, isInt: true, hintText: '1000')),
              SizedBox(width: 16.w),
              Expanded(child: _buildInputField('Tolls (\$)', _tollsController, hintText: '50.00')),
            ],
          ),
          SizedBox(height: 16.h),
          _buildDarkResultBox(r'Total FSC $', '\$${totalFSC.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildDeadheadBonusCard() {
    return _buildSectionCard(
      title: 'Deadhead & Bonus',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInputField('DH Miles', _dhMilesController, isInt: true, hintText: '100')),
              SizedBox(width: 16.w),
              Expanded(child: _buildInputField('DH Rate Per Mile', _dhRateController, hintText: '0.00')),
            ],
          ),
          SizedBox(height: 16.h),
          _buildDarkResultBox(r'Total DH $', '\$${totalDH.toStringAsFixed(2)}'),
          SizedBox(height: 16.h),
          _buildInputField('Bonus/Accessorial Pay', _bonusController, hintText: '0.00'),
        ],
      ),
    );
  }

  Widget _buildSummaryTableCard() {
    return _buildSectionCard(
      title: 'Summary',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDarkResultBox('Total Revenue', '\$${totalRevenue.toStringAsFixed(2)}', small: true)),
              SizedBox(width: 16.w),
              Expanded(child: _buildDarkResultBox('Total Miles', '$totalMiles', small: true)),
            ],
          ),
          SizedBox(height: 12.h),
          _buildDarkResultBox('Compensation Per Mile', '\$${compensationPerMile.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildDriverProfitCard() {
    return _buildSectionCard(
      title: 'PROFIT',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildLabelValue('Profit Per Mile', '\$${profitPerMile.toStringAsFixed(2)}')),
              Expanded(child: _buildInputField('Cost Per Mile', _costPerMileController, hintText: '1.50')),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildLabelValue('Total Profit', '\$${totalProfit.toStringAsFixed(2)}')),
              Expanded(child: _buildLabelValue('Total Cost', '\$${totalCost.toStringAsFixed(2)}')),
            ],
          ),
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



  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDarkResultBox(String label, String value, {bool small = false}) {
    return Container(
      width: double.infinity,
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
          Text(value, style: TextStyle(color: Colors.white, fontSize: small ? 16.sp : 18.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLoadDetailsCard() {
    return _buildSectionCard(
      title: 'Load Details',
      child: _buildInputField('Load #', _loadNumberController, isText: true, hintText: 'Enter Load Number')
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isInt = false, bool isText = false, String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 32.h,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: isText ? TextInputType.text : TextInputType.numberWithOptions(decimal: !isInt),
          style: TextStyle(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: hintText ?? '0',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF00D193))),
          ),
        ),
      ],
    );
  }
}
