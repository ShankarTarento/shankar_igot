import 'package:flutter/cupertino.dart';
import 'package:karmayogi_mobile/util/edit_profile_mandatory_helper.dart';
import 'package:provider/provider.dart';
import '../../../../../models/index.dart';
import '../../../../../respositories/index.dart';

class ProfilePrimaryDetailsViewModel {
  static final ProfilePrimaryDetailsViewModel _instance =
      ProfilePrimaryDetailsViewModel._internal();
  factory ProfilePrimaryDetailsViewModel() {
    return _instance;
  }

  ProfilePrimaryDetailsViewModel._internal();

  Future<List<String>> getGroups(context) async {
    List<dynamic> listData =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getGroups();

    List<String> groups = [];
    listData.forEach((item) {
      //UAT input for removing others from list of groups
      if (!item.toString().toLowerCase().contains('others')) {
        groups.add(item);
      }
    });
    return groups;
  }

  Future<List<String>> getDesignations(
      {required BuildContext context,
      bool isOrgBasedDesignation = false,
      bool isCadreProgram = false,
      int offset = 0,
      String query = ''}) async {
    List<dynamic> orgLevelDesignationsList = [];
    if (isOrgBasedDesignation) {
      orgLevelDesignationsList = Provider.of<ProfileRepository>(context, listen: false).orgLevelDesignationsList;
      if (orgLevelDesignationsList.isEmpty) {
        RegistrationLinkModel? orgInfo = await Provider.of<ProfileRepository>(context, listen: false).getOrgFrameworkId();
        if (orgInfo != null) {
          if (orgInfo.orgId != null) {
            orgLevelDesignationsList =
            await Provider.of<ProfileRepository>(context, listen: false)
                .getOrgBasedDesignations(orgInfo.orgId!);
          }
        }
      }
    } else {
      orgLevelDesignationsList = await EditProfileMandatoryHelper()
          .getDesignations(context, offset, query);
    }
    if (isCadreProgram && !orgLevelDesignationsList.contains('OTHERS')) {
      orgLevelDesignationsList.add('OTHERS');
    }
    return orgLevelDesignationsList.cast<String>();
  }
}
