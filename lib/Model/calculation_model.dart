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
    if (loadData != null) {
      data['loadData'] = loadData!.toJson();
    }
    if (goalData != null) {
      data['goalData'] = goalData!.toJson();
    }
    if (costData != null) {
      data['costData'] = costData!.toJson();
    }
    data['createdAt'] = createdAt;
    return data;
  }
}

class LoadData {
  double? baseRate;
  double? fuelSurcharge;
  int? loadedMiles;
  double? tolls;
  int? dhMiles;
  double? dhRate;
  double? bonus;
  int? driverPercentage;
  double? totalRevenue;
  double? totalProfit;
  double? totalFSC;
  double? totalDH;
  int? totalMiles;
  double? compensationPerMile;
  double? costPerMile;
  double? totalCost;
  double? profitPerMile;
  double? driverPay;
  double? ownerPay;

  LoadData({
    this.baseRate,
    this.fuelSurcharge,
    this.loadedMiles,
    this.tolls,
    this.dhMiles,
    this.dhRate,
    this.bonus,
    this.driverPercentage,
    this.totalRevenue,
    this.totalProfit,
    this.totalFSC,
    this.totalDH,
    this.totalMiles,
    this.compensationPerMile,
    this.costPerMile,
    this.totalCost,
    this.profitPerMile,
    this.driverPay,
    this.ownerPay,
  });

  LoadData.fromJson(Map<String, dynamic> json) {
    baseRate = (json['baseRate'] as num?)?.toDouble();
    fuelSurcharge = (json['fuelSurcharge'] as num?)?.toDouble();
    loadedMiles = (json['loadedMiles'] as num?)?.toInt();
    tolls = (json['tolls'] as num?)?.toDouble();
    dhMiles = (json['dhMiles'] as num?)?.toInt();
    dhRate = (json['dhRate'] as num?)?.toDouble();
    bonus = (json['bonus'] as num?)?.toDouble();
    driverPercentage = (json['driverPercentage'] as num?)?.toInt();
    totalRevenue = (json['totalRevenue'] as num?)?.toDouble();
    totalProfit = (json['totalProfit'] as num?)?.toDouble();
    totalFSC = (json['totalFSC'] as num?)?.toDouble();
    totalDH = (json['totalDH'] as num?)?.toDouble();
    totalMiles = (json['totalMiles'] as num?)?.toInt();
    compensationPerMile = (json['compensationPerMile'] as num?)?.toDouble();
    costPerMile = (json['costPerMile'] as num?)?.toDouble();
    totalCost = (json['totalCost'] as num?)?.toDouble();
    profitPerMile = (json['profitPerMile'] as num?)?.toDouble();
    driverPay = (json['driverPay'] as num?)?.toDouble();
    ownerPay = (json['ownerPay'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['baseRate'] = baseRate;
    data['fuelSurcharge'] = fuelSurcharge;
    data['loadedMiles'] = loadedMiles;
    data['tolls'] = tolls;
    data['dhMiles'] = dhMiles;
    data['dhRate'] = dhRate;
    data['bonus'] = bonus;
    data['driverPercentage'] = driverPercentage;
    data['totalRevenue'] = totalRevenue;
    data['totalProfit'] = totalProfit;
    data['totalFSC'] = totalFSC;
    data['totalDH'] = totalDH;
    data['totalMiles'] = totalMiles;
    data['compensationPerMile'] = compensationPerMile;
    data['costPerMile'] = costPerMile;
    data['totalCost'] = totalCost;
    data['profitPerMile'] = profitPerMile;
    data['driverPay'] = driverPay;
    data['ownerPay'] = ownerPay;
    return data;
  }
}

class GoalData {
  double? desiredWeeklyProfit;
  double? costPerMile;
  double? deadheadPayPerMile;
  int? desiredDaysPerWeek;
  int? desiredMaxMilesPerDay;
  int? driverPercentage;
  int? milesNeeded;
  double? minRatePerMile;
  double? totalRevenue;
  double? totalCost;
  int? maxDHPerDay;
  int? maxDHPerWeek;

  GoalData({
    this.desiredWeeklyProfit,
    this.costPerMile,
    this.deadheadPayPerMile,
    this.desiredDaysPerWeek,
    this.desiredMaxMilesPerDay,
    this.driverPercentage,
    this.milesNeeded,
    this.minRatePerMile,
    this.totalRevenue,
    this.totalCost,
    this.maxDHPerDay,
    this.maxDHPerWeek,
  });

  GoalData.fromJson(Map<String, dynamic> json) {
    desiredWeeklyProfit = (json['desiredWeeklyProfit'] as num?)?.toDouble();
    costPerMile = (json['costPerMile'] as num?)?.toDouble();
    deadheadPayPerMile = (json['deadheadPayPerMile'] as num?)?.toDouble();
    desiredDaysPerWeek = (json['desiredDaysPerWeek'] as num?)?.toInt();
    desiredMaxMilesPerDay = (json['desiredMaxMilesPerDay'] as num?)?.toInt();
    driverPercentage = (json['driverPercentage'] as num?)?.toInt();
    milesNeeded = (json['milesNeeded'] as num?)?.toInt();
    minRatePerMile = (json['minRatePerMile'] as num?)?.toDouble();
    totalRevenue = (json['totalRevenue'] as num?)?.toDouble();
    totalCost = (json['totalCost'] as num?)?.toDouble();
    maxDHPerDay = (json['maxDHPerDay'] as num?)?.toInt();
    maxDHPerWeek = (json['maxDHPerWeek'] as num?)?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['desiredWeeklyProfit'] = desiredWeeklyProfit;
    data['costPerMile'] = costPerMile;
    data['deadheadPayPerMile'] = deadheadPayPerMile;
    data['desiredDaysPerWeek'] = desiredDaysPerWeek;
    data['desiredMaxMilesPerDay'] = desiredMaxMilesPerDay;
    data['driverPercentage'] = driverPercentage;
    data['milesNeeded'] = milesNeeded;
    data['minRatePerMile'] = minRatePerMile;
    data['totalRevenue'] = totalRevenue;
    data['totalCost'] = totalCost;
    data['maxDHPerDay'] = maxDHPerDay;
    data['maxDHPerWeek'] = maxDHPerWeek;
    return data;
  }
}

class CostData {
  double? insurance;
  double? truckPayment;
  double? escrow;
  double? repairSavings;
  double? driverPay;
  double? permits;
  double? otherFixedCosts;
  double? totalWeeklyFixedCosts;
  int? milesPerWeek;
  double? avgMPG;
  double? fuelPrice;
  double? fuelCost;
  int? oilChangesPerYear;
  double? costPerOilChange;
  double? weeklyOilChangeCost;
  double? tireCostPerYear;
  double? weeklyTireCost;
  double? maintenanceCostPerYear;
  double? weeklyMaintenanceCost;
  double? totalWeeklyVariableCosts;
  double? totalWeeklyOperatingCost;
  double? trueCPM;

  CostData({
    this.insurance,
    this.truckPayment,
    this.escrow,
    this.repairSavings,
    this.driverPay,
    this.permits,
    this.otherFixedCosts,
    this.totalWeeklyFixedCosts,
    this.milesPerWeek,
    this.avgMPG,
    this.fuelPrice,
    this.fuelCost,
    this.oilChangesPerYear,
    this.costPerOilChange,
    this.weeklyOilChangeCost,
    this.tireCostPerYear,
    this.weeklyTireCost,
    this.maintenanceCostPerYear,
    this.weeklyMaintenanceCost,
    this.totalWeeklyVariableCosts,
    this.totalWeeklyOperatingCost,
    this.trueCPM,
  });

  CostData.fromJson(Map<String, dynamic> json) {
    insurance = (json['insurance'] as num?)?.toDouble();
    truckPayment = (json['truckPayment'] as num?)?.toDouble();
    escrow = (json['escrow'] as num?)?.toDouble();
    repairSavings = (json['repairSavings'] as num?)?.toDouble();
    driverPay = (json['driverPay'] as num?)?.toDouble();
    permits = (json['permits'] as num?)?.toDouble();
    otherFixedCosts = (json['otherFixedCosts'] as num?)?.toDouble();
    totalWeeklyFixedCosts = (json['totalWeeklyFixedCosts'] as num?)?.toDouble();
    milesPerWeek = (json['milesPerWeek'] as num?)?.toInt();
    avgMPG = (json['avgMPG'] as num?)?.toDouble();
    fuelPrice = (json['fuelPrice'] as num?)?.toDouble();
    fuelCost = (json['fuelCost'] as num?)?.toDouble();
    oilChangesPerYear = (json['oilChangesPerYear'] as num?)?.toInt();
    costPerOilChange = (json['costPerOilChange'] as num?)?.toDouble();
    weeklyOilChangeCost = (json['weeklyOilChangeCost'] as num?)?.toDouble();
    tireCostPerYear = (json['tireCostPerYear'] as num?)?.toDouble();
    weeklyTireCost = (json['weeklyTireCost'] as num?)?.toDouble();
    maintenanceCostPerYear = (json['maintenanceCostPerYear'] as num?)?.toDouble();
    weeklyMaintenanceCost = (json['weeklyMaintenanceCost'] as num?)?.toDouble();
    totalWeeklyVariableCosts = (json['totalWeeklyVariableCosts'] as num?)?.toDouble();
    totalWeeklyOperatingCost = (json['totalWeeklyOperatingCost'] as num?)?.toDouble();
    trueCPM = (json['trueCPM'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['insurance'] = insurance;
    data['truckPayment'] = truckPayment;
    data['escrow'] = escrow;
    data['repairSavings'] = repairSavings;
    data['driverPay'] = driverPay;
    data['permits'] = permits;
    data['otherFixedCosts'] = otherFixedCosts;
    data['totalWeeklyFixedCosts'] = totalWeeklyFixedCosts;
    data['milesPerWeek'] = milesPerWeek;
    data['avgMPG'] = avgMPG;
    data['fuelPrice'] = fuelPrice;
    data['fuelCost'] = fuelCost;
    data['oilChangesPerYear'] = oilChangesPerYear;
    data['costPerOilChange'] = costPerOilChange;
    data['weeklyOilChangeCost'] = weeklyOilChangeCost;
    data['tireCostPerYear'] = tireCostPerYear;
    data['weeklyTireCost'] = weeklyTireCost;
    data['maintenanceCostPerYear'] = maintenanceCostPerYear;
    data['weeklyMaintenanceCost'] = weeklyMaintenanceCost;
    data['totalWeeklyVariableCosts'] = totalWeeklyVariableCosts;
    data['totalWeeklyOperatingCost'] = totalWeeklyOperatingCost;
    data['trueCPM'] = trueCPM;
    return data;
  }
}
