// Updated Calculation Model with accurate field names as per API docs
class CalculationModel {
  String? id;
  String? type;
  LoadData? loadData;
  GoalData? goalData;
  CostData? costData;
  String? createdAt;

  CalculationModel({
    this.id,
    this.type,
    this.loadData,
    this.goalData,
    this.costData,
    this.createdAt,
  });

  CalculationModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    type = json['type'];
    loadData = json['loadData'] != null ? LoadData.fromJson(json['loadData']) : null;
    goalData = json['goalData'] != null ? GoalData.fromJson(json['goalData']) : null;
    costData = json['costData'] != null ? CostData.fromJson(json['costData']) : null;
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['type'] = type;
    if (loadData != null) data['loadData'] = loadData!.toJson();
    if (goalData != null) data['goalData'] = goalData!.toJson();
    if (costData != null) data['costData'] = costData!.toJson();
    data['createdAt'] = createdAt;
    return data;
  }
}

class LoadData {
  String? loadNumber;
  double? baseRate;
  double? fuelSurcharge;
  int? loadedMiles;
  double? tolls;
  int? dhMiles;
  double? dhRate;
  double? bonus;
  int? driverPercentage;
  double? costPerMile;
  double? totalRevenue;
  double? totalProfit;
  double? totalFSC;
  double? totalDH;
  int? totalMiles;
  double? compensationPerMile;
  double? totalCost;
  double? profitPerMile;
  double? driverPay;
  double? ownerPay;

  LoadData({
    this.loadNumber,
    this.baseRate,
    this.fuelSurcharge,
    this.loadedMiles,
    this.tolls,
    this.dhMiles,
    this.dhRate,
    this.bonus,
    this.driverPercentage,
    this.costPerMile,
    this.totalRevenue,
    this.totalProfit,
    this.totalFSC,
    this.totalDH,
    this.totalMiles,
    this.compensationPerMile,
    this.totalCost,
    this.profitPerMile,
    this.driverPay,
    this.ownerPay,
  });

  LoadData.fromJson(Map<String, dynamic> json) {
    loadNumber = json['loadNumber']?.toString();
    baseRate = (json['baseRate'] as num?)?.toDouble();
    fuelSurcharge = (json['fuelSurcharge'] as num?)?.toDouble();
    loadedMiles = (json['loadedMiles'] as num?)?.toInt();
    tolls = (json['tolls'] as num?)?.toDouble();
    dhMiles = (json['dhMiles'] as num?)?.toInt();
    dhRate = (json['dhRate'] as num?)?.toDouble();
    bonus = (json['bonus'] as num?)?.toDouble();
    driverPercentage = (json['driverPercentage'] as num?)?.toInt();
    costPerMile = (json['costPerMile'] as num?)?.toDouble();
    totalRevenue = (json['totalRevenue'] as num?)?.toDouble();
    totalProfit = (json['totalProfit'] as num?)?.toDouble();
    totalFSC = (json['totalFSC'] as num?)?.toDouble();
    totalDH = (json['totalDH'] as num?)?.toDouble();
    totalMiles = (json['totalMiles'] as num?)?.toInt();
    compensationPerMile = (json['compensationPerMile'] as num?)?.toDouble();
    totalCost = (json['totalCost'] as num?)?.toDouble();
    profitPerMile = (json['profitPerMile'] as num?)?.toDouble();
    driverPay = (json['driverPay'] as num?)?.toDouble();
    ownerPay = (json['ownerPay'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'loadNumber': loadNumber,
      'baseRate': baseRate,
      'fuelSurcharge': fuelSurcharge,
      'loadedMiles': loadedMiles,
      'tolls': tolls,
      'dhMiles': dhMiles,
      'dhRate': dhRate,
      'bonus': bonus,
      'driverPercentage': driverPercentage,
      'costPerMile': costPerMile,
      'totalRevenue': totalRevenue,
      'totalProfit': totalProfit,
      'totalFSC': totalFSC,
      'totalDH': totalDH,
      'totalMiles': totalMiles,
      'compensationPerMile': compensationPerMile,
      'totalCost': totalCost,
      'profitPerMile': profitPerMile,
      'driverPay': driverPay,
      'ownerPay': ownerPay,
    };
  }
}

class GoalData {
  double? desiredWeeklyProfit;
  double? costPerMile;
  double? deadheadPayPerMile;
  int? daysPerWeek;
  int? maxMilesPerDay;
  int? driverPercentage;
  int? loadedMilesNeeded;
  double? minTargetRate;
  double? totalRevenue;
  double? totalCost;
  double? maxDHPerDay;
  double? maxDHPerWeek;
  double? driverPay;
  double? ownerPay;

  GoalData({
    this.desiredWeeklyProfit,
    this.costPerMile,
    this.deadheadPayPerMile,
    this.daysPerWeek,
    this.maxMilesPerDay,
    this.driverPercentage,
    this.loadedMilesNeeded,
    this.minTargetRate,
    this.totalRevenue,
    this.totalCost,
    this.maxDHPerDay,
    this.maxDHPerWeek,
    this.driverPay,
    this.ownerPay,
  });

  GoalData.fromJson(Map<String, dynamic> json) {
    desiredWeeklyProfit = (json['desiredWeeklyProfit'] as num?)?.toDouble();
    costPerMile = (json['costPerMile'] as num?)?.toDouble();
    deadheadPayPerMile = (json['deadheadPayPerMile'] as num?)?.toDouble();
    daysPerWeek = (json['daysPerWeek'] as num?)?.toInt();
    maxMilesPerDay = (json['maxMilesPerDay'] as num?)?.toInt();
    driverPercentage = (json['driverPercentage'] as num?)?.toInt();
    loadedMilesNeeded = (json['loadedMilesNeeded'] as num?)?.toInt();
    minTargetRate = (json['minTargetRate'] as num?)?.toDouble();
    totalRevenue = (json['totalRevenue'] as num?)?.toDouble();
    totalCost = (json['totalCost'] as num?)?.toDouble();
    maxDHPerDay = (json['maxDHPerDay'] as num?)?.toDouble();
    maxDHPerWeek = (json['maxDHPerWeek'] as num?)?.toDouble();
    driverPay = (json['driverPay'] as num?)?.toDouble();
    ownerPay = (json['ownerPay'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'desiredWeeklyProfit': desiredWeeklyProfit,
      'costPerMile': costPerMile,
      'deadheadPayPerMile': deadheadPayPerMile,
      'daysPerWeek': daysPerWeek,
      'maxMilesPerDay': maxMilesPerDay,
      'driverPercentage': driverPercentage,
      'loadedMilesNeeded': loadedMilesNeeded,
      'minTargetRate': minTargetRate,
      'totalRevenue': totalRevenue,
      'totalCost': totalCost,
      'maxDHPerDay': maxDHPerDay,
      'maxDHPerWeek': maxDHPerWeek,
      'driverPay': driverPay,
      'ownerPay': ownerPay,
    };
  }
}

class CostData {
  double? insurance;
  double? truckPayment;
  double? escrow;
  double? repairSavings;
  double? driverPayFixed;
  double? permits;
  double? otherFixed;
  int? milesPerWeek;
  double? avgMPG;
  double? fuelPrice;
  int? oilChangesPerYear;
  double? costPerOilChange;
  double? tireCostPerYear;
  double? maintenanceCostPerYear;
  double? totalWeeklyFixed;
  double? weeklyFuelCost;
  double? weeklyOilChangeCost;
  double? weeklyTireCost;
  double? weeklyMaintenanceCost;
  double? totalWeeklyVariable;
  double? totalWeeklyOperatingCost;
  double? trueCPM;

  CostData({
    this.insurance,
    this.truckPayment,
    this.escrow,
    this.repairSavings,
    this.driverPayFixed,
    this.permits,
    this.otherFixed,
    this.milesPerWeek,
    this.avgMPG,
    this.fuelPrice,
    this.oilChangesPerYear,
    this.costPerOilChange,
    this.tireCostPerYear,
    this.maintenanceCostPerYear,
    this.totalWeeklyFixed,
    this.weeklyFuelCost,
    this.weeklyOilChangeCost,
    this.weeklyTireCost,
    this.weeklyMaintenanceCost,
    this.totalWeeklyVariable,
    this.totalWeeklyOperatingCost,
    this.trueCPM,
  });

  CostData.fromJson(Map<String, dynamic> json) {
    insurance = (json['insurance'] as num?)?.toDouble();
    truckPayment = (json['truckPayment'] as num?)?.toDouble();
    escrow = (json['escrow'] as num?)?.toDouble();
    repairSavings = (json['repairSavings'] as num?)?.toDouble();
    driverPayFixed = (json['driverPayFixed'] as num?)?.toDouble();
    permits = (json['permits'] as num?)?.toDouble();
    otherFixed = (json['otherFixed'] as num?)?.toDouble();
    milesPerWeek = (json['milesPerWeek'] as num?)?.toInt();
    avgMPG = (json['avgMPG'] as num?)?.toDouble();
    fuelPrice = (json['fuelPrice'] as num?)?.toDouble();
    oilChangesPerYear = (json['oilChangesPerYear'] as num?)?.toInt();
    costPerOilChange = (json['costPerOilChange'] as num?)?.toDouble();
    tireCostPerYear = (json['tireCostPerYear'] as num?)?.toDouble();
    maintenanceCostPerYear = (json['maintenanceCostPerYear'] as num?)?.toDouble();
    totalWeeklyFixed = (json['totalWeeklyFixed'] as num?)?.toDouble();
    weeklyFuelCost = (json['weeklyFuelCost'] as num?)?.toDouble();
    weeklyOilChangeCost = (json['weeklyOilChangeCost'] as num?)?.toDouble();
    weeklyTireCost = (json['weeklyTireCost'] as num?)?.toDouble();
    weeklyMaintenanceCost = (json['weeklyMaintenanceCost'] as num?)?.toDouble();
    totalWeeklyVariable = (json['totalWeeklyVariable'] as num?)?.toDouble();
    totalWeeklyOperatingCost = (json['totalWeeklyOperatingCost'] as num?)?.toDouble();
    trueCPM = (json['trueCPM'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'insurance': insurance,
      'truckPayment': truckPayment,
      'escrow': escrow,
      'repairSavings': repairSavings,
      'driverPayFixed': driverPayFixed,
      'permits': permits,
      'otherFixed': otherFixed,
      'milesPerWeek': milesPerWeek,
      'avgMPG': avgMPG,
      'fuelPrice': fuelPrice,
      'oilChangesPerYear': oilChangesPerYear,
      'costPerOilChange': costPerOilChange,
      'tireCostPerYear': tireCostPerYear,
      'maintenanceCostPerYear': maintenanceCostPerYear,
      'totalWeeklyFixed': totalWeeklyFixed,
      'weeklyFuelCost': weeklyFuelCost,
      'weeklyOilChangeCost': weeklyOilChangeCost,
      'weeklyTireCost': weeklyTireCost,
      'weeklyMaintenanceCost': weeklyMaintenanceCost,
      'totalWeeklyVariable': totalWeeklyVariable,
      'totalWeeklyOperatingCost': totalWeeklyOperatingCost,
      'trueCPM': trueCPM,
    };
  }
}
