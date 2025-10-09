import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/custom_profile_data.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/custom_profile_field_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/org_custom_fields_data.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/services/custom_profile_field_services.dart';
import 'package:http/http.dart';

class CustomProfileFieldRepository {
  static OrgCustomFieldsData? _orgCustomFieldsData;

  static OrgCustomFieldsData? get getOrgCustomFieldsData =>
      _orgCustomFieldsData;

  static Future<OrgCustomFieldsData?> getOrgDetails() async {
    try {
      Response response = await CustomProfileFieldServices.getOrgFrameworkId();
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded['result']['response']['customfieldsdata'] != null) {
          _orgCustomFieldsData = OrgCustomFieldsData.fromJson(
              decoded['result']['response']['customfieldsdata']);
          return _orgCustomFieldsData;
        }
      } else {
        throw Exception(
            'Failed to fetch organization details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('getOrgDetails error: $error');
    }
    return null;
  }

  Future<List<CustomField>> getCustomFields() async {
    try {
      // First: Get org custom field IDs
      final orgCustomFieldData = _orgCustomFieldsData ?? await getOrgDetails();
      if (orgCustomFieldData == null) {
        debugPrint('Org custom fields data is null. Skipping fetch.');
        return [];
      }

      // Second: Fetch all available custom fields
      final response = await CustomProfileFieldServices.getProfileCustomFields(
          customFieldIds: orgCustomFieldData.customFieldIds);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch custom fields. Status code: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> rawFields =
          decoded['result']['searchResults']['data'] ?? [];

      final customFields =
          rawFields.map((e) => CustomField.fromJson(e)).toList();

      return customFields;
    } catch (error, stackTrace) {
      debugPrint('getCustomFields error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return [];
    }
  }

  Future<List<CustomProfileData>> getCustomFieldData() async {
    try {
      // Step 1: Get org custom field config
      final orgCustomFieldData = _orgCustomFieldsData ?? await getOrgDetails();
      if (orgCustomFieldData == null) {
        debugPrint('Org custom fields data is null. Skipping fetch.');
        return [];
      }

      // Step 2: Fetch profile data
      final response = await CustomProfileFieldServices.getCustomProfileData();
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch custom field data. Status code: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> data =
          decoded['result']['response']['customFieldValues'] ?? [];

      // Step 3: Parse and filter by org custom field IDs
      final customFieldData = data
          .map((item) =>
              CustomProfileData.fromJson(item as Map<String, dynamic>))
          .where((item) =>
              orgCustomFieldData.customFieldIds.contains(item.customFieldId))
          .toList();

      return customFieldData;
    } catch (error, stackTrace) {
      debugPrint('getCustomFieldData error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return [];
    }
  }

  Future<void> updateCustomProfileData(
      List<CustomProfileData> customProfileData) async {
    try {
      List<Map<String, dynamic>> customProfileDataList =
          customProfileData.map((e) => e.toJson()).toList();

      final response = await CustomProfileFieldServices.updateCustomProfileData(
          customProfileDataList);
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update custom profile data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('updateCustomProfileData error: $error');
      throw error;
    }
  }
}
