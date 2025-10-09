import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/custom_profile_data.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/org_custom_fields_data.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/repository/custom_profile_field_repository.dart';

import '../../../../../constants/_constants/app_constants.dart';
import '../../../../../constants/_constants/storage_constants.dart';
import '../ui/widgets/searchable_boottosheet_content.dart';

class ProfileHelper {
  void showSearchableBottomSheet({
    required BuildContext context,
    BuildContext? parentContext,
    required List<String> items,
    required Function(String) onItemSelected,
    String? defaultItem,
    Future<List<String>> Function(String)? onFetchMore,
    bool hasMore = true,
    String query = '',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SearchableBottomSheetContent(
          items: items,
          onItemSelected: onItemSelected,
          defaultItem: defaultItem,
          onFetchMore: onFetchMore,
          hasMore: hasMore,
          initialQuery: query,
          parentContext: parentContext),
    );
  }

  Future<bool> isRestrictedUser() async {
    final _storage = FlutterSecureStorage();
    String? profileStatus = await _storage.read(key: Storage.profileStatus);
    String? deptName = await _storage.read(key: Storage.deptName);
    if (profileStatus == UserProfileStatus.notMyUser) {
      return ((deptName ?? '').toLowerCase() ==
          RegistrationRequests.IGOT_DEPT_NAME.toLowerCase());
    }
    return false;
  }

  static Future<bool> checkCustomProfileFields() async {
    try {
      OrgCustomFieldsData? orgCustomFieldsData =
          await CustomProfileFieldRepository.getOrgDetails();
      if (orgCustomFieldsData != null &&
          orgCustomFieldsData.customFieldIds.isNotEmpty) {
        if (!orgCustomFieldsData.isPopUpEnabled) {
          return false;
        }
        List<CustomProfileData> customProfiledata =
            await CustomProfileFieldRepository().getCustomFieldData();
        for (var data in orgCustomFieldsData.customFieldIds) {
          if (!customProfiledata.any((element) {
            return data == element.customFieldId &&
                (element.value == null ||
                    element.value.toString().isEmpty ||
                    element.values == null ||
                    element.values!.isEmpty);
          })) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
