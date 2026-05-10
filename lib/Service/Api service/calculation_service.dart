import 'package:truckcalc/Model/calculation_model.dart';
import 'package:truckcalc/Service/Api%20service/network_caller.dart';
import 'package:truckcalc/Service/urls.dart';

class CalculationService {
  static Future<NetworkResponse> createCalculation(Map<String, dynamic> payload) async {
    return await NetworkCaller.postRequest(
      url: Urls.calculationsUrl,
      body: payload,
    );
  }

  static Future<List<CalculationModel>> getMyCalculations() async {
    final response = await NetworkCaller.getRequest(
      url: Urls.calculationsUrl,
    );

    if (response.isSuccess && response.body != null) {
      final List<dynamic> data = response.body!['data'] ?? [];
      return data.map((json) => CalculationModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<NetworkResponse> getStats() async {
    return await NetworkCaller.getRequest(url: Urls.calculationStatsUrl);
  }

  static Future<NetworkResponse> exportData() async {
    return await NetworkCaller.getRequest(url: Urls.calculationExportUrl);
  }

  static Future<NetworkResponse> getSingleCalculation(String id) async {
    return await NetworkCaller.getRequest(url: Urls.getSingleCalculationUrl(id));
  }

  static Future<NetworkResponse> deleteCalculation(String id) async {
    return await NetworkCaller.deleteRequest(url: Urls.deleteCalculationUrl(id));
  }
}
