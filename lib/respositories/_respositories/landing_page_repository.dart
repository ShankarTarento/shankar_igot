import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/models/_models/landing_page_info_model.dart';
import 'package:karmayogi_mobile/models/_models/user_nudge_info_model.dart';
import 'package:karmayogi_mobile/services/_services/landing_page_service.dart';

class LandingPageRepository extends ChangeNotifier {
  UserNudgeInfo? _userNudgeInfo;
  UserNudgeInfo? get userNudgeInfo => _userNudgeInfo;
  LandingPageInfo? getLandingPageInfoData;

  bool _isProfileCardExpanded = true;
  bool get isProfileCardExpanded => _isProfileCardExpanded;

  bool _displayUserNudge = false;
  bool get displayUserNudge => _displayUserNudge;

  bool _displayOverlayTheme = true;
  bool get displayOverlayTheme => _displayOverlayTheme;

  int _profileDelay = 5;
  int get profileDelay => _profileDelay;

  int _nudgeDelay = 10;
  int get nudgeDelay => _nudgeDelay;

  bool _isConfigAPICalled = false;
  var _configInfoData;
  bool _showGetStarted = false;

  Size _profileCardSize = Size(100, 100);
  Size? get profileCardSize => _profileCardSize;

  Future<void> getUserNudgeAndThemeInfo() async {
    if (!_isConfigAPICalled) {
      var content = await LandingPageService.getUserNudgeInfo();
      _configInfoData = content;

      _isConfigAPICalled = true;
    } else {
      _configInfoData = _configInfoData;
    }
    _displayUserNudge = _configInfoData['profileTimelyNudges']['enable'];
    _profileDelay = int.parse(
        _configInfoData['profileTimelyNudges']['profileDelayInSec'].toString());
    _nudgeDelay = int.parse(
        _configInfoData['profileTimelyNudges']['nudgeDelayInSec'].toString());
    List<UserNudgeInfo> data = _configInfoData['profileTimelyNudges']['data']
        .map(
          (dynamic item) => UserNudgeInfo.fromJson(item),
        )
        .toList()
        .cast<UserNudgeInfo>();

    DateTime now = DateTime.now();
    for (var element in data) {
      if (now.hour >= element.startSlot && now.hour < element.endSlot) {
        _userNudgeInfo = element;
        break;
      } else if (element.startSlot > element.endSlot) {
        _userNudgeInfo = element;
        break;
      }
    }

    notifyListeners();
  }

  void changeExpansionProfileCard(bool value) {
    if (_isProfileCardExpanded != value) {
      _isProfileCardExpanded = value;
      notifyListeners();
    }
  }

  bool get showGetStarted => _showGetStarted;

  void updateShowGetStarted(bool value) {
    if (_showGetStarted != value) {
      _showGetStarted = value;
      notifyListeners();
    }
  }

  void setProfileCardSize(Size size) {
    if (_profileCardSize != size) {
      _profileCardSize = size;
      notifyListeners();
    }
  }
}
