import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:igot_http_service_helper/igot_http_service.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/app_home_config_data.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_config_flag_model.dart';
import 'package:karmayogi_mobile/models/_models/app_update_model.dart';
import 'package:karmayogi_mobile/ui/screens/maintenance_screen/maintenance_screen_repository.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';

class AppConfiguration extends ChangeNotifier {
  static final AppConfiguration _singleTon = AppConfiguration._internal();

  AppConfiguration._internal();

  factory AppConfiguration() {
    return _singleTon;
  }
  static final _storage = FlutterSecureStorage();

  bool _useCompetencyv6 = true;
  String? _amritGyaanOrgId;
  static AIConfigFlags _iGOTAiConfig = AIConfigFlags(
      aiTutor: false,
      iGOTAI: false,
      transcription: false,
      useResourceId: false);

  static AIConfigFlags get iGOTAiConfig => _iGOTAiConfig;
  static bool _mentorshipEnabled = false;
  static bool get mentorshipEnabled => _mentorshipEnabled;

  static AppUpdateModel? _appUpdateModel;
  static AppUpdateModel? get appUpdateModel => _appUpdateModel;

  static Map<String, dynamic>? _homeConfigData;
  static Map<String, dynamic>? get homeConfigData => _homeConfigData;

  bool get useCompetencyv6 => _useCompetencyv6;
  String? get amritGyaanOrgId => _amritGyaanOrgId;

  set useCompetencyv6(bool value) {
    _useCompetencyv6 = value;
  }

  static Future getAiChatBotConfig() async {
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? token = await _storage.read(key: Storage.authToken);
    try {
      Map request = {
        "request": {
          "type": "page",
          "subType": "iGOTAI",
          "action": "page-configuration",
          "component": "portal",
          "rootOrgId": rootOrgId,
        }
      };
      var body = json.encode(request);
      Response response = await post(
          Uri.parse(ApiUrl.baseUrl + ApiUrl.getMicroSiteFormData),
          headers: NetworkHelper.insightHeader(rootOrgId ?? "", token ?? ""),
          body: body);
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        _iGOTAiConfig = AIConfigFlags.fromJson(data['result']['form']['data']);
        // AIConfigFlags(
        //     iGOTAI: true,
        //     aiTutor: true,
        //     transcription: true,
        //     useResourceId: false);
      }
      ;
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> getCompetencyConfig() async {
    try {
      Response response = await HttpService.get(
        apiUri: Uri.parse(ApiUrl.baseUrl + '/assets/env.json'),
        ttl: Duration(minutes: 5),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(response.body);
        String data = body['compentencyVersionKey'];
        _amritGyaanOrgId = body['cbcOrg'];
        _useCompetencyv6 = (data == 'competencies_v6');
      } else {
        _useCompetencyv6 = false;
      }
    } catch (e) {
      debugPrint('Error in getCompetencyConfig: $e');
      _useCompetencyv6 = false;
    }
  }

  Future<Map<String, dynamic>?> getHomeConfig({bool reload = false}) async {
    if (reload || _homeConfigData == null) {
      _homeConfigData = await HomeConfigRepository.getHomeConfig();
      if (_homeConfigData != null) {
        _mentorshipEnabled = _homeConfigData?['mentorshipEnabled'] ?? false;
        if (_homeConfigData?['appUpdate'] is Map<String, dynamic>) {
          _appUpdateModel =
              AppUpdateModel.fromJson(_homeConfigData!['appUpdate']);
        }

        MaintenanceScreenRepository.checkServerMaintenanceStatus(
            _homeConfigData!);
        notifyListeners();
      }
    }
    return _homeConfigData;
  }
}
