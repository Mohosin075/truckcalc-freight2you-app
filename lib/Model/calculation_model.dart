class CalculationModel {
  String? id;
  String? type;
  LoadData? loadData;
  String? createdAt;

  CalculationModel({this.id, this.type, this.loadData, this.createdAt});

  CalculationModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    type = json['type'];
    loadData = json['loadData'] != null ? LoadData.fromJson(json['loadData']) : null;
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['type'] = type;
    if (loadData != null) {
      data['loadData'] = loadData!.toJson();
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

  LoadData(
      {this.baseRate,
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
      this.ownerPay});

  LoadData.fromJson(Map<String, dynamic> json) {
    baseRate = (json['baseRate'] as num?)?.toDouble();
    fuelSurcharge = (json['fuelSurcharge'] as num?)?.toDouble();
    loadedMiles = json['loadedMiles'];
    tolls = (json['tolls'] as num?)?.toDouble();
    dhMiles = json['dhMiles'];
    dhRate = (json['dhRate'] as num?)?.toDouble();
    bonus = (json['bonus'] as num?)?.toDouble();
    driverPercentage = json['driverPercentage'];
    totalRevenue = (json['totalRevenue'] as num?)?.toDouble();
    totalProfit = (json['totalProfit'] as num?)?.toDouble();
    totalFSC = (json['totalFSC'] as num?)?.toDouble();
    totalDH = (json['totalDH'] as num?)?.toDouble();
    totalMiles = json['totalMiles'];
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
