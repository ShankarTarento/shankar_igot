import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/text_input_field.dart';
import 'package:karmayogi_mobile/util/validations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../../../constants/index.dart';
import '../../../../../../../../screens/_screens/profile/ui/widgets/dropdown_with_search.dart';
import '../../../../../../../../screens/_screens/profile/view_model/profile_primary_details_view_model.dart';

class EditDesignationDetails extends StatefulWidget {
  final bool isCadreProgram;
  final bool isOrgBasedDesignation;
  final ValueChanged<String> designationDetails;

  const EditDesignationDetails({
    Key? key,
    required this.designationDetails,
    this.isOrgBasedDesignation = false,
    required this.isCadreProgram,
  }) : super(key: key);

  @override
  State<EditDesignationDetails> createState() => _EditDesignationDetailsState();
}

class _EditDesignationDetailsState extends State<EditDesignationDetails> {
  final TextEditingController _othershController = TextEditingController();
  ValueNotifier<List<String>> designationList = ValueNotifier([]);
  String designationQuery = '';
  String _designation = '';
  int pageNo = 0;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Designation field
        FieldNameWidget(
          isMandatory: true,
          fieldName: AppLocalizations.of(context)!.mStaticDesignation,
          isApprovalField: false,
        ),
        SizedBox(height: 8.h),
        ValueListenableBuilder(
            valueListenable: designationList,
            builder: (context, designations, _) {
              return Container(
                decoration: BoxDecoration(
                    color: AppColors.appBarBackground,
                    borderRadius: BorderRadius.circular(4).r),
                child: DropdownWithSearch(
                  hintText: AppLocalizations.of(context)!.mStaticSelectHere,
                  query: designationQuery,
                  isPaginated: true,
                  parentContext: context,
                  optionList: designations,
                  selectedOption: _designation,
                  borderRadius: 4,
                  borderColor: AppColors.grey16,
                  defaultItem: widget.isCadreProgram
                      ? EnglishLang.others.toUpperCase()
                      : null,
                  callback: (String designation) {
                    _designation = designation;
                    widget.designationDetails(_designation);
                    setState(() {});
                  },
                  onSearchChanged: (String query) async {
                    if (designationQuery == query) {
                      pageNo++;
                    } else {
                      pageNo = 0;
                    }
                    return await ProfilePrimaryDetailsViewModel()
                        .getDesignations(
                            context: context,
                            isOrgBasedDesignation: widget.isOrgBasedDesignation,
                            offset: pageNo,
                            query: query);
                  },
                ),
              );
            }),
        widget.isCadreProgram
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0).r,
                child: Text(
                  AppLocalizations.of(context)!
                      .mNoteForDoptBlendedProgramDesignation,
                ),
              )
            : SizedBox(),
        _designation == EnglishLang.others.toUpperCase()
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                FieldNameWidget(
                    isMandatory: true,
                    fieldName:
                        AppLocalizations.of(context)!.mProfileEnterDesignation),
                TextInputField(
                    minLines: 1,
                    keyboardType: TextInputType.text,
                    controller: _othershController,
                    hintText:
                        AppLocalizations.of(context)!.mEditProfileTypeHere,
                    onChanged: (p0) {
                      widget.designationDetails(_designation);
                    },
                    validatorFuntion: (String? value) {
                      return Validations.validateDesignation(
                          context: context, value: value ?? '');
                    }),
              ])
            : SizedBox()
      ],
    );
  }

  void _populateFields() async {
    // Fetching profile data and populating the fields
    Profile? profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    List<dynamic> inReviewFields =
        Provider.of<ProfileRepository>(context, listen: false).inReview;
    dynamic inReviewDesignation =
        inReviewFields.where((element) => element.designation != null);
    _designation = (inReviewFields.isNotEmpty && inReviewDesignation.isNotEmpty)
        ? inReviewDesignation.first.designation
        : (profileDetails?.designation ?? "");
    designationList.value = await fetchDesignations();
    setState(() {});
  }

  Future<List<String>> fetchDesignations(
      {String query = '', int offset = 0}) async {
    if (designationQuery != query) {
      designationQuery = query;
      pageNo = 0;
      offset = 0;
    }
    List<String> newDesignations =
        await ProfilePrimaryDetailsViewModel().getDesignations(
      context: context,
      isOrgBasedDesignation: widget.isOrgBasedDesignation,
      offset: offset,
      query: query,
    );

    if (newDesignations.isEmpty) {
      return [];
    } else {
      return newDesignations;
    }
  }
}
