import 'package:flutter/material.dart';

import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_survey_form/blended_program_survey_form.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_user_form/blended_program_user_form.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/enrollment_confirmation_form.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/enrollment_details.dart';

import 'package:provider/provider.dart';

class SurveyFormBottomSheet extends StatefulWidget {
  final bool isCadreProgram;
  final String title;
  final Batch selectedBatch;
  final String courseIdName;
  final String courseId;
  final Map<dynamic, dynamic>? response;
  final int formId;
  final Function(String) setEnrollStatus;

  const SurveyFormBottomSheet({
    super.key,
    required this.isCadreProgram,
    required this.selectedBatch,
    required this.courseIdName,
    this.response,
    required this.courseId,
    required this.title,
    required this.setEnrollStatus,
    required this.formId,
  });

  @override
  State<SurveyFormBottomSheet> createState() => _SurveyFormBottomSheetState();
}

class _SurveyFormBottomSheetState extends State<SurveyFormBottomSheet> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  List<Map<String, dynamic>> formData = [];
  @override
  void initState() {
    constructFormData();
    super.initState();
  }

  void constructFormData() {
    List bpEnrolMandatoryProfileFields = widget.selectedBatch.batchAttributes!
            .raw['bpEnrolMandatoryProfileFields'] ??
        [];

    for (var form in bpEnrolMandatoryProfileFields) {
      if (widget.selectedBatch.batchAttributes?.raw['userProfileFileds'] ==
          BlendedProgramProfileSurvey.existingData) {
        getFormWidgets(form);
      } else {
        formData.add(form);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.response != null
            ? formData.isNotEmpty
                ? Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        BlendedProgramUserForm(
                          isCadreProgram: widget.isCadreProgram,
                          title: widget.title,
                          courseId: widget.courseId,
                          selectedBatch: widget.selectedBatch,
                          bpEnrolMandatoryProfileFields: formData,
                          saveAndNext: () {
                            _nextPage();
                          },
                        ),
                        widget.response!['clientVersion'] != null &&
                                widget.response!['clientVersion'].toString() ==
                                    blendedProgramFormVersion
                            ? BlendedProgramSurveyForm(
                                courseId: widget.courseId,
                                enrollParentAction: (value) {
                                  widget.setEnrollStatus(value);
                                },
                                batch: widget.selectedBatch,
                                surveyFormData: widget.response!,
                              )
                            : EnrollmentDetailsForm(
                                batch: widget.selectedBatch,
                                surveyform: widget.response,
                                courseDetails: widget.courseIdName,
                                courseId: widget.courseId,
                                formId: widget.formId,
                                enrollParentAction: (value) {
                                  widget.setEnrollStatus(value);
                                },
                              ),
                      ],
                    ),
                  )
                : widget.response!['clientVersion'] != null &&
                        widget.response!['clientVersion'].toString() ==
                            blendedProgramFormVersion
                    ? Expanded(
                        child: BlendedProgramSurveyForm(
                          courseId: widget.courseId,
                          enrollParentAction: (value) {
                            widget.setEnrollStatus(value);
                          },
                          batch: widget.selectedBatch,
                          surveyFormData: widget.response!,
                        ),
                      )
                    : Expanded(
                        child: EnrollmentDetailsForm(
                          batch: widget.selectedBatch,
                          surveyform: widget.response,
                          courseDetails: widget.courseIdName,
                          courseId: widget.courseId,
                          formId: widget.formId,
                          enrollParentAction: (value) {
                            widget.setEnrollStatus(value);
                          },
                        ),
                      )
            : formData.isNotEmpty
                ? Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        BlendedProgramUserForm(
                          isCadreProgram: widget.isCadreProgram,
                          title: widget.title,
                          courseId: widget.courseId,
                          selectedBatch: widget.selectedBatch,
                          bpEnrolMandatoryProfileFields: formData,
                          saveAndNext: () {
                            _nextPage();
                          },
                        ),
                        EnrollmentConfirmationForm(
                          enrollParentAction: widget.setEnrollStatus,
                          selectedBatch: widget.selectedBatch,
                        )
                      ],
                    ),
                  )
                : EnrollmentConfirmationForm(
                    enrollParentAction: widget.setEnrollStatus,
                    selectedBatch: widget.selectedBatch,
                  )
      ],
    );
  }

  void _nextPage() {
    if (_currentPageIndex < 1) {
      _currentPageIndex++;
      _pageController.animateToPage(
        _currentPageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void getFormWidgets(Map<String, dynamic> fieldData) {
    Profile? profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    switch (fieldData['displayName']) {
      case "Name":
        profileDetails?.firstName != null && profileDetails?.firstName != ''
            ? formData.add(fieldData)
            : null;

        break;
      case "Organisation":
        formData.add(fieldData);
        print("Handle the logic for Organisation");
        break;

      case "Group":
        if (profileDetails?.professionalDetails != null &&
            profileDetails!.professionalDetails!.isNotEmpty &&
            profileDetails.professionalDetails![0]['group'] != null) {
          formData.add(fieldData);
        }
        break;
      case "Designation":
        profileDetails?.professionalDetails != null &&
                profileDetails!.professionalDetails!.isNotEmpty &&
                profileDetails.professionalDetails![0]['designation'] != null
            ? formData.add(fieldData)
            : null;

        break;

      case "Employee ID":
        profileDetails?.employmentDetails?['employeeCode'] != null &&
                profileDetails?.employmentDetails?['employeeCode'] != ''
            ? formData.add(fieldData)
            : null;

        break;
      case "Email":
        formData.add(fieldData);
        break;
      case "Mobile Number":
        if (profileDetails?.personalDetails['mobile'] != null &&
            profileDetails?.personalDetails['mobile'] != '') {
          formData.add(fieldData);
        }

        break;
      case "Gender":
        profileDetails?.personalDetails['gender'] != null &&
                profileDetails?.personalDetails['gender'] != ''
            ? formData.add(fieldData)
            : null;

        break;
      case "Date of Birth":
        profileDetails?.personalDetails['dob'] != null &&
                profileDetails?.personalDetails['dob'] != ''
            ? formData.add(fieldData)
            : null;
        break;
      case "Mother Tongue":
        profileDetails?.personalDetails['domicileMedium'] != null &&
                profileDetails?.personalDetails['domicileMedium'] != ''
            ? formData.add(fieldData)
            : null;
        break;
      case "Category":
        profileDetails?.personalDetails['category'] != null &&
                profileDetails?.personalDetails['category'] != ''
            ? formData.add(fieldData)
            : null;
        break;
      case "Office Pin Code":
        profileDetails?.employmentDetails?['pinCode'] != null &&
                profileDetails?.employmentDetails?['pinCode'] != ''
            ? formData.add(fieldData)
            : null;
        break;

      case "eHRMS ID / External System ID":
        profileDetails?.ehrmsId != null && profileDetails?.ehrmsId != ''
            ? formData.add(fieldData)
            : null;

        break;
      case "Date of Retirement":
        profileDetails?.dateOfRetirement != null &&
                profileDetails?.dateOfRetirement != ''
            ? formData.add(fieldData)
            : null;

        break;

      case "Are you a Cadre Employee":
        profileDetails?.cadreDetails != null &&
                profileDetails!.cadreDetails!.isNotEmpty
            ? formData.add(fieldData)
            : null;

        break;
      case "Type of Service":
        profileDetails?.cadreDetails?['civilServiceType'] != null &&
                profileDetails?.cadreDetails?['civilServiceType'] != ''
            ? formData.add(fieldData)
            : null;

        break;

      case "Service":
        profileDetails?.cadreDetails?['civilServiceName'] != null &&
                profileDetails?.cadreDetails?['civilServiceName'] != ''
            ? formData.add(fieldData)
            : null;

        break;

      case "Cadre":
        profileDetails?.cadreDetails?['cadreName'] != null &&
                profileDetails?.cadreDetails?['cadreName'] != ''
            ? formData.add(fieldData)
            : null;

        break;

      case "Cadre Batch":
        profileDetails?.cadreDetails?['cadreBatch'] != null &&
                profileDetails?.cadreDetails?['cadreBatch'] != ''
            ? formData.add(fieldData)
            : null;

        break;

      case "Cadre Controlling Authority Name":
        profileDetails?.cadreDetails?['cadreControllingAuthorityName'] !=
                    null &&
                profileDetails
                        ?.cadreDetails?['cadreControllingAuthorityName'] !=
                    ''
            ? formData.add(fieldData)
            : null;

        break;

      default:
        print("Unknown display name=====${fieldData['displayName']}");
    }
  }
}
