import '../../../../../respositories/index.dart';
import '../model/extended_profile_model.dart';
import '../model/service_history_model.dart';

class ProfileTabViewModel {
  static final ProfileTabViewModel _instance = ProfileTabViewModel._internal();
  factory ProfileTabViewModel() {
    return _instance;
  }

  ProfileTabViewModel._internal();
  Future<ExtendedProfile?> getExtendedProfileData(String? userId) async {
    ExtendedProfile? profile =
        await ProfileRepository().getExtendedProfile(userId);
    return profile;
  }

  ExtendedProfile setDefaultServiceHistory(
      {required String orgName,
      required String designation,
      ExtendedProfile? profile}) {
    if (orgName.isEmpty && designation.isEmpty) {
      return ExtendedProfile(
          userid: '',
          serviceHistory: UserServices(data: [], count: 0),
          achievements: AchievementsModel(data: [], count: 0),
          educationalQualifications: EducationModel(data: [], count: 0),
          locationDetails: LocationDetailsModel(data: [], count: 0));
    } else {
      if (profile == null) {
        return ExtendedProfile(
            userid: '',
            serviceHistory: UserServices(
                data: [defaultServiceHistory(orgName, designation)], count: 1),
            achievements: AchievementsModel(data: [], count: 0),
            educationalQualifications: EducationModel(data: [], count: 0),
            locationDetails: LocationDetailsModel(data: [], count: 0));
      } else if (profile.serviceHistory.data.isEmpty ||
          (!profile.serviceHistory.data.any((item) =>
              item.orgName == orgName && item.designation == designation))) {
        profile.serviceHistory.data
            .insert(0, defaultServiceHistory(orgName, designation));
        profile.serviceHistory.count++;
        return profile;
      } else {
        return profile;
      }
    }
  }

  ServiceHistoryModel defaultServiceHistory(
      String orgName, String designation) {
    return ServiceHistoryModel(
        orgName: orgName,
        designation: designation,
        currentlyWorking: 'true',
        description: '',
        orgState: '',
        orgDistrict: '',
        startDate: '',
        endDate: '',
        uuid: '',
        orgLogo: '');
  }
}
