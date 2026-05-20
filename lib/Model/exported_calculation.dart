class ExportedCalculation {
  final String id;
  final String type;
  final DateTime createdAt;
  final Map<String, dynamic> rawData;

  ExportedCalculation({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.rawData,
  });

  factory ExportedCalculation.fromJson(Map<String, dynamic> json) {
    return ExportedCalculation(
      id: json['id'] ?? json['_id'] ?? '',
      type: json['type'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      rawData: Map<String, dynamic>.from(json)
        ..remove('id')
        ..remove('_id')
        ..remove('type')
        ..remove('createdAt'),
    );
  }
}
