import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/constants/custom_field_constats.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/custom_profile_data.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/custom_profile_field_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/repository/custom_profile_field_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/widgets/custom_profile_dropdown.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/widgets/custom_profile_text_field.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditCustomProfileFields extends StatefulWidget {
  final List<CustomProfileData> customProfileData;
  final Function() onSubmit;
  const EditCustomProfileFields(
      {super.key, required this.customProfileData, required this.onSubmit});

  @override
  State<EditCustomProfileFields> createState() =>
      _EditCustomProfileFieldsState();
}

class _EditCustomProfileFieldsState extends State<EditCustomProfileFields> {
  late Future<List<CustomField>> customFieldsFuture;
  final List<Widget> customFieldWidgets = [];
  final Map<CustomField, TextEditingController> controllers = {};
  final Map<CustomField, CustomProfileData?> masterListData = {};

  final _repository = CustomProfileFieldRepository();

  @override
  void initState() {
    super.initState();
    customFieldsFuture = _repository.getCustomFields();
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<Widget> buildCustomFields({required List<CustomField> customFields}) {
    customFieldWidgets.clear();

    for (var customField in customFields) {
      if (customField.type == CustomFieldConstants.text) {
        _buildTextField(customField);
      } else if (customField.type == CustomFieldConstants.masterList) {
        _buildMasterListField(customField);
      }
    }

    return customFieldWidgets;
  }

  void _buildTextField(CustomField customField) {
    // Find existing data if available
    final existingData = _findExistingData(customField.customFieldId);

    // Create controller with initial value if data exists
    if (!controllers.containsKey(customField)) {
      if (existingData != null) {
        controllers[customField] =
            TextEditingController(text: existingData.value ?? "");
      } else {
        controllers[customField] = TextEditingController();
      }
    }

    // Add text field widget
    customFieldWidgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0).r,
        child: CustomProfileTextField(
          controller: controllers[customField]!,
          customField: customField,
        ),
      ),
    );
  }

  void _buildMasterListField(CustomField customField) {
    // Find existing data if available
    final existingData = _findExistingData(customField.customFieldId);

    // Set initial master list value
    if (!masterListData.containsKey(customField)) {
      masterListData[customField] = existingData;
    }

    // Add dropdown widget
    customFieldWidgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0).r,
        child: CustomProfileDropdown(
          initialValue: masterListData[customField],
          customField: customField,
          onChanged: (value) {
            setState(() {
              masterListData[customField] = value;
            });
          },
        ),
      ),
    );
  }

  // Helper to find existing data for a field
  CustomProfileData? _findExistingData(String fieldId) {
    try {
      return widget.customProfileData
          .firstWhere((data) => data.customFieldId == fieldId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appBarBackground,
          automaticallyImplyLeading: false,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.close, color: AppColors.greys60),
              onPressed: () => Navigator.pop(context),
            ),
          ],
          title: Text(
            AppLocalizations.of(context)!.mEditOrgSpecificDetails,
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.greys,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0).r,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                FutureBuilder<List<CustomField>>(
                  future: customFieldsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                              3,
                              (index) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ContainerSkeleton(
                                        height: 35.w,
                                        width: 0.4.sw,
                                      ),
                                      SizedBox(height: 8.h),
                                      ContainerSkeleton(
                                        height: 45.w,
                                        width: 1.sw,
                                      ),
                                      SizedBox(height: 20.h),
                                    ],
                                  )));
                    }

                    if (snapshot.data != null) {
                      return Column(
                        children: buildCustomFields(
                          customFields: snapshot.data!,
                        ),
                      );
                    }
                    return Center(
                      child:
                          Text(AppLocalizations.of(context)!.mMsgNoDataFound),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding:
              EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0)
                  .r,
          decoration: BoxDecoration(color: AppColors.appBarBackground),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50).r,
              ),
              minimumSize: Size(double.infinity, 48.h),
            ),
            onPressed: submitCustomFields,
            child: Text(
              AppLocalizations.of(context)!.mProfileSaveChanges,
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submitCustomFields() async {
    bool allFieldsValid = true;
    final List<CustomProfileData> submitCustomProfileData = [];

    // Validate and collect text field data
    for (final entry in controllers.entries) {
      final field = entry.key;
      final controller = entry.value;

      if (field.isMandatory && controller.text.isEmpty) {
        allFieldsValid = false;
        break;
      }

      // Only add if there's text
      if (controller.text.isNotEmpty) {
        submitCustomProfileData.add(CustomProfileData(
          customFieldId: field.customFieldId,
          type: field.type,
          attributeName: field.attributeName,
          value: controller.text,
        ));
      }
    }

    // Validate and collect master list data
    for (final entry in masterListData.entries) {
      final field = entry.key;
      final value = entry.value;

      if (field.isMandatory && value == null) {
        allFieldsValid = false;
        break;
      }

      // Only add if there's data
      if (value != null) {
        submitCustomProfileData.add(value);
      }
    }

    // Show error if validation fails
    if (!allFieldsValid) {
      Helper.showSnackBarMessage(
        context: context,
        text: AppLocalizations.of(context)!.mFillRequiredFields,
        bgColor: AppColors.mandatoryRed,
      );
      return;
    }

    try {
      // Submit data
      await _repository.updateCustomProfileData(submitCustomProfileData);

      // Show success message
      Helper.showSnackBarMessage(
        context: context,
        text: AppLocalizations.of(context)!.mProfileUpdatedSuccessfully,
        bgColor: AppColors.positiveDark,
      );
      widget.onSubmit();
      Navigator.pop(context);
    } catch (e) {
      Helper.showSnackBarMessage(
        context: context,
        text: AppLocalizations.of(context)!.mStaticSomethingWrongTryLater,
        bgColor: AppColors.mandatoryRed,
      );
    }
  }
}
