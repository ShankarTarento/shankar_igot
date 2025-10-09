import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/alert_dialog/alert_dialog.dart';
import 'package:karmayogi_mobile/constants/_constants/learn_compatibility_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/assessment_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/_models/guest_data_model.dart';
import '../../../../../constants/index.dart';
import '../../../../../models/_models/assessment_info_model.dart';
import '../../../../../util/index.dart';
import '../model/assessment_response_data_model.dart';
import '../model/navigation_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssessmentViewModel {
  AssessmentRepository assessmentRepository = AssessmentRepository();
  Future<AssessmentResponseDataModel?> getAssessmentData(
      {required BuildContext context,
      NavigationModel? resourceInfo,
      required String courseCategory,
      required String courseId,
      required String parentCourseId,
      required String identifier,
      required int compatibilityLevel,
      GuestDataModel? guestUserData,
      bool isFeatured = false}) async {
    try {
      if (resourceInfo == null) return null;

      if (isAssessmentWithFileURL(resourceInfo)) {
        return await _handleAssessmentWithURL(resourceInfo);
      } else {
        if (_isAdvancedAssessment(compatibilityLevel)) {
          return isFeatured
              ? await _fetchPublicAssessmentData(
                  context: context,
                  identifier: identifier,
                  parentContextId: parentCourseId,
                  guestUserData: guestUserData)
              : await _fetchAdvancedAssessmentData(
                  identifier: identifier, parentContextId: parentCourseId);
        } else {
          return isFeatured
              ? await _fetchPublicAssessmentData(
                  context: context,
                  identifier: identifier,
                  parentContextId: parentCourseId,
                  guestUserData: guestUserData)
              : await _fetchBasicAssessmentData(
                  identifier: identifier,
                  resourceInfo: resourceInfo,
                  parentContextId: parentCourseId);
        }
      }
    } catch (e) {
      print("Error fetching assessment data: $e");
      return null;
    }
  }

  /// Assessment with ArtifactURL
  bool isAssessmentWithFileURL(NavigationModel resource) {
    return resource.artifactUrl != null && resource.artifactUrl!.isNotEmpty;
  }

  /// Assessment with ArtifactURL
  Future<dynamic> _handleAssessmentWithURL(NavigationModel resourceInfo) async {
    String? fileUri =
        resourceInfo.artifactUrl!.contains('static.karmayogiprod.nic.in')
            ? Helper.generateCdnUri(resourceInfo.artifactUrl)
            : resourceInfo.artifactUrl;

    if (fileUri != null) {
      final response = await assessmentRepository.getAssessmentData(fileUri);
      return AssessmentResponseDataModel(
          questionSet: [], assessmentResponse: response);
    } else {
      return null;
    }
  }

  /// Advanced assessment
  bool _isAdvancedAssessment(int compatibility) {
    return compatibility >=
        AssessmentCompatibility.multimediaCompatibility.version;
  }

  /// Advanced assessment
  Future<AssessmentResponseDataModel> _fetchAdvancedAssessmentData(
      {required String identifier, required String parentContextId}) async {
    AssessmentInfo? assessmentInfo;
    List questionSet = [];
    var retakeInfo = await assessmentRepository
        .getRetakeStandaloneAssessmentInfo(identifier);
    if ((!(retakeInfo is int)) &&
        retakeInfo['attemptsMade'] < retakeInfo['attemptsAllowed']) {
      assessmentInfo = await assessmentRepository.getStandaloneAssessmentInfo(
          identifier,
          parentContextId: parentContextId);
    }
    if (assessmentInfo != null && assessmentInfo.errMessage == null) {
      for (var i = 0; i < assessmentInfo.questions.length; i++) {
        final response =
            await assessmentRepository.getStandaloneAssessmentQuestions(
                identifier, assessmentInfo.questions[i].childNodes);
        questionSet.add(response);
      }
    }
    return AssessmentResponseDataModel(
        assessmentInfo: assessmentInfo,
        questionSet: questionSet,
        retakeInfo: !(retakeInfo is int) ? retakeInfo : null);
  }

  /// Basic assessment
  Future<dynamic> _fetchBasicAssessmentData(
      {required String identifier,
      required NavigationModel resourceInfo,
      required String parentContextId}) async {
    List questionSet = [];
    var retakeInfo;
    AssessmentInfo? assessmentInfo = await assessmentRepository
        .getAssessmentInfo(identifier, parentContextId: parentContextId);
    if (resourceInfo.primaryCategory == PrimaryCategory.finalAssessment &&
        assessmentInfo != null &&
        assessmentInfo.errMessage == null) {
      retakeInfo =
          await assessmentRepository.getRetakeAssessmentInfo(identifier);
    }

    if (assessmentInfo != null && assessmentInfo.errMessage == null) {
      for (var i = 0; i < assessmentInfo.questions.length; i++) {
        final response = await assessmentRepository.getAssessmentQuestions(
            identifier, assessmentInfo.questions[i].childNodes);
        questionSet.add(response);
      }
    }

    return AssessmentResponseDataModel(
        assessmentInfo: assessmentInfo,
        questionSet: questionSet,
        retakeInfo: !(retakeInfo is int) ? retakeInfo : null);
  }

  /// public assessment
  Future<AssessmentResponseDataModel> _fetchPublicAssessmentData(
      {required BuildContext context,
      required String identifier,
      required String parentContextId,
      GuestDataModel? guestUserData}) async {
    AssessmentInfo? assessmentInfo;
    List questionSet = [];
    final publicAssessmentData =
        await assessmentRepository.getPublicAssessmentInfo(
            assessmentId: identifier,
            parentContextId: parentContextId,
            guestUserData: guestUserData);

    // Check if already submitted
    if (publicAssessmentData is Map &&
        ((publicAssessmentData['response'] ?? '')
            .toString()
            .contains("submitted"))) {
      showDialog(
          context: context,
          builder: (BuildContext cxt) {
            return AlertDialogWidget(
              dialogRadius: 8,
              subtitle: AppLocalizations.of(context)!
                  .mAssessmentAlreadySubmittedGuestMessage,
              primaryButtonText: AppLocalizations.of(context)!.mStaticOk,
              onPrimaryButtonPressed: () async {
                Navigator.of(cxt).pop();
                Navigator.of(context).pop();
              },
              primaryButtonTextStyle: GoogleFonts.lato(
                color: AppColors.appBarBackground,
                fontWeight: FontWeight.w700,
                fontSize: 14.0.sp,
                height: 1.5.w,
              ),
              primaryButtonBgColor: AppColors.darkBlue,
            );
          });
    }

    if (publicAssessmentData is Map &&
        publicAssessmentData['questionSet'] != null) {
      final questionSet = publicAssessmentData['questionSet'];
      assessmentInfo = await AssessmentInfo.fromJson(questionSet);
    }

    if (assessmentInfo != null && assessmentInfo.errMessage == null) {
      for (var i = 0; i < assessmentInfo.questions.length; i++) {
        final response =
            await assessmentRepository.getPublicAssessmentQuestions(
                identifier,
                parentContextId,
                assessmentInfo.questions[i].childNodes,
                guestUserData);
        questionSet.add(response);
      }
    }

    return AssessmentResponseDataModel(
        assessmentInfo: assessmentInfo,
        questionSet: questionSet,
        retakeInfo: null);
  }

  /// get pre-requisite assessment data
  Future<AssessmentChild?> getPreRequisiteAssessmentData(
      {required String identifier, bool isFeatured = false}) async {
        AssessmentChild? assessmentChild;
        try {
          AssessmentInfo? assessmentInfo = await assessmentRepository.getPreEnrollAssessmentInfo(identifier, isFeatured);

          if (assessmentInfo?.questions.isNotEmpty ?? false) {
            for (final question in assessmentInfo!.questions) {
              if ((question.contextCategory?.toLowerCase() ?? '') == PrimaryCategory.preEnrolmentAssessment.toLowerCase()) {
                assessmentChild = question;
                break;
              }
            }
          }
          return assessmentChild;
        } catch (e) {
          return null;
        }
  }

}
