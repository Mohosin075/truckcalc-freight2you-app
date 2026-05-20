import 'package:flutter/foundation.dart';
import 'package:truckcalc/Model/calculation_model.dart';
import 'package:truckcalc/Model/exported_calculation.dart';
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

  static Future<List<ExportedCalculation>> exportCalculationsFlat() async {
    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.calculationExportUrl,
      );

      if (response.isSuccess && response.body != null) {
        final dynamic bodyData = response.body;
        debugPrint("📥 exportCalculationsFlat RAW BODY: $bodyData");
        
        List<dynamic> list = [];
        if (bodyData is List) {
          list = bodyData;
        } else if (bodyData is Map) {
          if (bodyData['data'] is List) {
            list = bodyData['data'];
          } else if (bodyData['data'] is Map && bodyData['data']['data'] is List) {
            list = bodyData['data']['data'];
          } else if (bodyData['calculations'] is List) {
            list = bodyData['calculations'];
          }
        }

        debugPrint("📥 Parsed ${list.length} items from body");
        return list.map((json) {
          try {
            return ExportedCalculation.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            debugPrint("❌ Error parsing calculation item: $e. Item JSON: $json");
            rethrow;
          }
        }).toList();
      } else {
        debugPrint("❌ Export request failed. success=${response.isSuccess}, body=${response.body}");
        return [];
      }
    } catch (e, stack) {
      debugPrint("❌ Exception in exportCalculationsFlat: $e\n$stack");
      rethrow;
    }
  }

  static Future<NetworkResponse> getSingleCalculation(String id) async {
    return await NetworkCaller.getRequest(url: Urls.getSingleCalculationUrl(id));
  }

  static Future<NetworkResponse> deleteCalculation(String id) async {
    return await NetworkCaller.deleteRequest(url: Urls.deleteCalculationUrl(id));
  }
}
