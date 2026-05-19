import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:truckcalc/Service/Controller/calculation_controller.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/customSnacBar.dart';

class CostsPage extends StatefulWidget {
  const CostsPage({super.key});

  @override
  State<CostsPage> createState() => _CostsPageState();
}

class _CostsPageState extends State<CostsPage> {
  // Fixed costs controllers
  final TextEditingController _insuranceController = TextEditingController(text: '0.00');
  final TextEditingController _truckPaymentController = TextEditingController(text: '0.00');
  final TextEditingController _escrowController = TextEditingController(text: '0.00');
  final TextEditingController _repairSavingsController = TextEditingController(text: '0.00');
  final TextEditingController _driverPayFixedController = TextEditingController(text: '0.00');
  final TextEditingController _permitsController = TextEditingController(text: '0.00');
  final TextEditingController _otherFixedController = TextEditingController(text: '0.00');

  // Variable costs controllers
  final TextEditingController _milesPerWeekController = TextEditingController(text: '2500');
  final TextEditingController _avgMPGController = TextEditingController(text: '6.5');
  final TextEditingController _fuelPriceController = TextEditingController(text: '3.50');
  final TextEditingController _oilChangesYearController = TextEditingController(text: '12');
  final TextEditingController _costPerOilChangeController = TextEditingController(text: '300');
  final TextEditingController _tireCostYearController = TextEditingController(text: '5000');
  final TextEditingController _maintenanceCostYearController = TextEditingController(text: '8000');

  double totalWeeklyFixed = 0.0;
  double weeklyFuelCost = 0.0;
  double weeklyOilChangeCost = 0.0;
  double weeklyTireCost = 0.0;
  double weeklyMaintenanceCost = 0.0;
  double totalWeeklyVariable = 0.0;
  double totalWeeklyOperatingCost = 0.0;
  double trueCPM = 0.0;

  @override
  void initState() {
    super.initState();
    List<TextEditingController> controllers = [
      _insuranceController, _truckPaymentController, _escrowController,
      _repairSavingsController, _driverPayFixedController, _permitsController,
      _otherFixedController, _milesPerWeekController, _avgMPGController,
      _fuelPriceController, _oilChangesYearController, _costPerOilChangeController,
      _tireCostYearController, _maintenanceCostYearController
    ];
    for (var c in controllers) {
      c.addListener(_calculate);
    }
    _calculate();
  }

  void _calculate() {
    double insurance = double.tryParse(_insuranceController.text) ?? 0.0;
    double truckPayment = double.tryParse(_truckPaymentController.text) ?? 0.0;
    double escrow = double.tryParse(_escrowController.text) ?? 0.0;
    double repairSavings = double.tryParse(_repairSavingsController.text) ?? 0.0;
    double driverPayFixed = double.tryParse(_driverPayFixedController.text) ?? 0.0;
    double permits = double.tryParse(_permitsController.text) ?? 0.0;
    double otherFixed = double.tryParse(_otherFixedController.text) ?? 0.0;

    totalWeeklyFixed = insurance + truckPayment + escrow + repairSavings + driverPayFixed + permits + otherFixed;

    int milesPerWeek = int.tryParse(_milesPerWeekController.text) ?? 0;
    double avgMPG = double.tryParse(_avgMPGController.text) ?? 0.0;
    double fuelPrice = double.tryParse(_fuelPriceController.text) ?? 0.0;

    weeklyFuelCost = (avgMPG > 0) ? (milesPerWeek / avgMPG) * fuelPrice : 0.0;

    int oilChangesYear = int.tryParse(_oilChangesYearController.text) ?? 0;
    double costPerOilChange = double.tryParse(_costPerOilChangeController.text) ?? 0.0;
    weeklyOilChangeCost = (oilChangesYear * costPerOilChange) / 52.14;

    double tireCostYear = double.tryParse(_tireCostYearController.text) ?? 0.0;
    weeklyTireCost = tireCostYear / 52.14;

    double maintenanceCostYear = double.tryParse(_maintenanceCostYearController.text) ?? 0.0;
    weeklyMaintenanceCost = maintenanceCostYear / 52.14;

    totalWeeklyVariable = weeklyFuelCost + weeklyOilChangeCost + weeklyTireCost + weeklyMaintenanceCost;
    totalWeeklyOperatingCost = totalWeeklyFixed + totalWeeklyVariable;
    trueCPM = (milesPerWeek > 0) ? totalWeeklyOperatingCost / milesPerWeek : 0.0;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _insuranceController.dispose();
    _truckPaymentController.dispose();
    _escrowController.dispose();
    _repairSavingsController.dispose();
    _driverPayFixedController.dispose();
    _permitsController.dispose();
    _otherFixedController.dispose();
    _milesPerWeekController.dispose();
    _avgMPGController.dispose();
    _fuelPriceController.dispose();
    _oilChangesYearController.dispose();
    _costPerOilChangeController.dispose();
    _tireCostYearController.dispose();
    _maintenanceCostYearController.dispose();
    super.dispose();
  }

  Future<void> _saveCalculation() async {
    final controller = Provider.of<CalculationController>(context, listen: false);

    final payload = {
      "type": "COST",
      "costData": {
        "insurance": double.tryParse(_insuranceController.text) ?? 0.0,
        "truckPayment": double.tryParse(_truckPaymentController.text) ?? 0.0,
        "escrow": double.tryParse(_escrowController.text) ?? 0.0,
        "repairSavings": double.tryParse(_repairSavingsController.text) ?? 0.0,
        "driverPayFixed": double.tryParse(_driverPayFixedController.text) ?? 0.0,
        "permits": double.tryParse(_permitsController.text) ?? 0.0,
        "otherFixed": double.tryParse(_otherFixedController.text) ?? 0.0,
        "totalWeeklyFixed": totalWeeklyFixed,
        "milesPerWeek": int.tryParse(_milesPerWeekController.text) ?? 0,
        "avgMPG": double.tryParse(_avgMPGController.text) ?? 0.0,
        "fuelPrice": double.tryParse(_fuelPriceController.text) ?? 0.0,
        "weeklyFuelCost": weeklyFuelCost,
        "oilChangesPerYear": int.tryParse(_oilChangesYearController.text) ?? 0,
        "costPerOilChange": double.tryParse(_costPerOilChangeController.text) ?? 0.0,
        "weeklyOilChangeCost": weeklyOilChangeCost,
        "tireCostPerYear": double.tryParse(_tireCostYearController.text) ?? 0.0,
        "weeklyTireCost": weeklyTireCost,
        "maintenanceCostPerYear": double.tryParse(_maintenanceCostYearController.text) ?? 0.0,
        "weeklyMaintenanceCost": weeklyMaintenanceCost,
        "totalWeeklyVariable": totalWeeklyVariable,
        "totalWeeklyOperatingCost": totalWeeklyOperatingCost,
        "trueCPM": trueCPM,
      }
    };

    final success = await controller.createCalculation(payload);
    if (success) {
      if (mounted) {
        showCustomSnackBar(context: context, message: "Operating costs saved!", isError: false);
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
                      'CPM Calculator',
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
                _buildTotalOperatingCostHeader(),
                SizedBox(height: 20.h),
                _buildSectionHeader('1. WEEKLY FIXED COSTS'),
                _buildFixedCostsSection(),
                SizedBox(height: 20.h),
                _buildSectionHeader('2. VARIABLE COSTS'),
                _buildVariableCostsSection(),
                SizedBox(height: 20.h),
                _buildSectionHeader('3. TOTAL OPERATING COST'),
                _buildTotalOperatingCostSection(),
                SizedBox(height: 20.h),
                _buildConversionTip(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalOperatingCostHeader() {
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
          const Text('TOTAL OPERATING COST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildSummaryItem('Weekly Total', '\$${totalWeeklyOperatingCost.toStringAsFixed(2)}'),
              SizedBox(width: 40.w),
              _buildSummaryItem('True CPM', '\$${trueCPM.toStringAsFixed(2)}'),
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

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFD81B60)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
      ),
      child: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
    );
  }

  Widget _buildFixedCostsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.r), bottomRight: Radius.circular(12.r)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildInputField('Weekly Insurance Payment', _insuranceController),
          _buildInputField('Weekly Truck Payment', _truckPaymentController),
          _buildInputField('Weekly Escrow Contribution', _escrowController),
          _buildInputField('Weekly Repair Savings', _repairSavingsController),
          _buildInputField('Weekly Self/Driver Pay', _driverPayFixedController),
          _buildInputField('Weekly Permits/Subscriptions', _permitsController),
          _buildInputField('Other Weekly Costs', _otherFixedController),
          SizedBox(height: 16.h),
          _buildDarkResultBox('TOTAL WEEKLY FIXED COSTS', '\$${totalWeeklyFixed.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildVariableCostsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.r), bottomRight: Radius.circular(12.r)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildInputField('Miles Driven Per Week', _milesPerWeekController, isInt: true),
          Row(
            children: [
              Expanded(child: _buildInputField('Average MPG', _avgMPGController)),
              SizedBox(width: 16.w),
              Expanded(child: _buildInputField('Avg Fuel Price (\$ /gal)', _fuelPriceController)),
            ],
          ),
          _buildDarkResultBox('WEEKLY FUEL COST', '\$${weeklyFuelCost.toStringAsFixed(2)}'),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildInputField('Oil Changes/Year', _oilChangesYearController, isInt: true)),
              SizedBox(width: 16.w),
              Expanded(child: _buildInputField('Cost Per Oil Change', _costPerOilChangeController)),
            ],
          ),
          _buildDarkResultBox('WEEKLY OIL CHANGE COST', '\$${weeklyOilChangeCost.toStringAsFixed(2)}'),
          SizedBox(height: 16.h),
          _buildInputField('Tire Cost Per Year', _tireCostYearController),
          _buildDarkResultBox('WEEKLY TIRE COST', '\$${weeklyTireCost.toStringAsFixed(2)}'),
          SizedBox(height: 16.h),
          _buildInputField('Maintenance Cost Per Year', _maintenanceCostYearController),
          _buildDarkResultBox('WEEKLY MAINTENANCE COST', '\$${weeklyMaintenanceCost.toStringAsFixed(2)}'),
          SizedBox(height: 16.h),
          _buildDarkResultBox('TOTAL WEEKLY VARIABLE COSTS', '\$${totalWeeklyVariable.toStringAsFixed(2)}', isLargeValue: true),
        ],
      ),
    );
  }

  Widget _buildTotalOperatingCostSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.r), bottomRight: Radius.circular(12.r)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildResultSubBox('Total Fixed', '\$${totalWeeklyFixed.toStringAsFixed(2)}')),
              SizedBox(width: 16.w),
              Expanded(child: _buildResultSubBox('Total Variable', '\$${totalWeeklyVariable.toStringAsFixed(2)}')),
            ],
          ),
          SizedBox(height: 12.h),
          _buildDarkResultBox('TOTAL WEEKLY OPERATING COST', '\$${totalWeeklyOperatingCost.toStringAsFixed(2)}', isLargeValue: true),
          SizedBox(height: 12.h),
          _buildDarkResultBox('Miles Driven Per Week', '${_milesPerWeekController.text} miles', isMiles: true),
          SizedBox(height: 12.h),
          _buildDarkResultBox('TRUE COST PER MILE', '\$${trueCPM.toStringAsFixed(2)}', isLargeValue: true),
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
          Text(value, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDarkResultBox(String label, String value, {bool isLargeValue = false, bool isMiles = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      margin: EdgeInsets.only(top: 8.h),
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
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isLargeValue ? 24.sp : (isMiles ? 18.sp : 20.sp),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionTip() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'TO CONVERT MONTHLY PAYMENTS TO WEEKLY, DIVIDE BY 4.33',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isInt = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 14.h, bottom: 8.h),
          child: Text(label, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
          style: TextStyle(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: '0.00',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF00D193), width: 1.5)),
          ),
        ),
      ],
    );
  }
}
