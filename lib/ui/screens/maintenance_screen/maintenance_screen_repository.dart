import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/common_components/models/maintenance_screen_model.dart';

class MaintenanceScreenRepository {
  static bool _serverUnderMaintenance = false;
  static bool get serverUnderMaintenance => _serverUnderMaintenance;

  static ServerUnderMaintenance? _serverUnderMaintenanceData;
  static ServerUnderMaintenance? get serverUnderMaintenanceData =>
      _serverUnderMaintenanceData;

  static bool checkServerMaintenanceStatus(Map<String, dynamic> homeConfig) {
    try {
      _serverUnderMaintenanceData =
          ServerUnderMaintenance.fromJson(homeConfig['serverUnderMaintenance']);

      if (_serverUnderMaintenanceData == null) return false;

      _serverUnderMaintenance = _serverUnderMaintenanceData!.enabled;

      return _serverUnderMaintenanceData!.enabled;
    } catch (e) {
      debugPrint('Error checking server maintenance status: $e');
      return false;
    }
  }
}
