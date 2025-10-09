import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/connection_relationship_model.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/index.dart';
import '../../../../../models/index.dart';
import '../../../../../respositories/index.dart';
import '../../../../../util/index.dart';

class ProfileDashboardViewModel {
  final _storage = FlutterSecureStorage();
  final ProfileRepository profileRepository = ProfileRepository();

  // Get profile details
  Future<Profile?> getProfileDetails(
      String? userId, BuildContext context) async {
    final profileRepo = Provider.of<ProfileRepository>(context, listen: false);
    String wid = await _storage.read(key: Storage.wid) ?? '';
    Profile? profileDetails = await profileRepo.getBasicProfileDetailsById(
        userId ?? wid,
        isCurrentUser: userId == null || userId == wid);
    return profileDetails;
  }

  Future<void> getProfileInReviewFields() async {
    await profileRepository.getInReviewFields(forceUpdate: true);
    // To get the In review fields which is SENT FOR APPROVAL
    await profileRepository.getInReviewFields(
        isApproved: true, forceUpdate: true);
    // To get the rejected fields
    await profileRepository.getInReviewFields(
        isRejected: true, forceUpdate: true);
  }

  void generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.myProfilePageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.myProfilePageUri,
        env: TelemetryEnv.profile);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  /// Get profile connection relationship
  Future<ConnectionRelationshipModel?> getConnectionRelationship(
      String? userId) async {
    ConnectionRelationshipModel? connectionRelationshipModel =
        await profileRepository.getConnectionRelationship(userId ?? '');
    if (connectionRelationshipModel != null)
      return connectionRelationshipModel;
    else
      return ConnectionRelationshipModel();
  }
}
