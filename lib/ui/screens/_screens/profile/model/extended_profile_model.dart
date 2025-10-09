import 'achievement_item_model.dart';
import 'education_qualification_item_model.dart';
import 'location_item_model.dart';
import 'service_history_model.dart';

class ExtendedProfile {
  final String userid;
  final UserServices serviceHistory;
  final AchievementsModel achievements;
  final EducationModel educationalQualifications;
  final LocationDetailsModel locationDetails;

  ExtendedProfile(
      {required this.userid,
      required this.serviceHistory,
      required this.achievements,
      required this.educationalQualifications,
      required this.locationDetails});

  factory ExtendedProfile.fromJson(Map<String, dynamic> json) {
    return ExtendedProfile(
      userid: json['userid'] ?? '',
      serviceHistory: UserServices.fromJson(json['serviceHistory'] ?? {}),
      achievements: AchievementsModel.fromJson(json['achievements'] ?? {}),
      educationalQualifications:
          EducationModel.fromJson(json['educationalQualifications'] ?? {}),
      locationDetails:
          LocationDetailsModel.fromJson(json['locationDetails'] ?? {}),
    );
  }
}

class LocationDetailsModel {
  List<LocationItemModel> data;
  final int count;

  LocationDetailsModel({required this.data, required this.count});

  factory LocationDetailsModel.fromJson(Map<String, dynamic> json) {
    return LocationDetailsModel(
        data: (json['data'] as List<dynamic>? ?? [])
            .map((e) => LocationItemModel.fromJson(e))
            .toList(),
        count: json['count'] ?? 0);
  }
}

class UserServices {
  List<ServiceHistoryModel> data;
  int count;

  UserServices({required this.data, required this.count});

  factory UserServices.fromJson(Map<String, dynamic> json) {
    return UserServices(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ServiceHistoryModel.fromJson(e))
          .toList(),
      count: json['count'] ?? 0,
    );
  }
}

class AchievementsModel {
  final List<AchievementItem> data;
  final int count;

  AchievementsModel({required this.data, required this.count});

  factory AchievementsModel.fromJson(Map<String, dynamic> json) {
    return AchievementsModel(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => AchievementItem.fromJson(e))
          .toList(),
      count: json['count'] ?? 0,
    );
  }
}

class EducationModel {
  final List<EducationalQualificationItem> data;
  final int count;

  EducationModel({required this.data, required this.count});

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => EducationalQualificationItem.fromJson(e))
          .toList(),
      count: json['count'] ?? 0,
    );
  }
}
