
class TelemetryEventModel {
  final String? userId;
  final Map eventData;

  TelemetryEventModel({
    this.userId,
    required this.eventData,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'telemetry_data': eventData,
    };
  }
}
