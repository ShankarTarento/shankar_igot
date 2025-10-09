import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/select_from_bottomsheet.dart';
import 'package:karmayogi_mobile/util/validations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditGroupDetails extends StatefulWidget {
  final ValueChanged<String> groupDetails;
  final bool isCadreProgram;

  const EditGroupDetails(
      {Key? key, required this.groupDetails, required this.isCadreProgram})
      : super(key: key);

  @override
  State<EditGroupDetails> createState() => _EditGroupDetailsState();
}

class _EditGroupDetailsState extends State<EditGroupDetails> {
  String _groupKey = 'group';
  final TextEditingController _groupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  @override
  void dispose() {
    super.dispose();
    _groupController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Group field
        FieldNameWidget(
          isMandatory: true,
          fieldName: AppLocalizations.of(context)!.mStaticGroup,
        ),
        SelectFromBottomSheet(
          fieldName: EnglishLang.group,
          controller: _groupController,
          callBack: () {
            widget.groupDetails(_groupController.text);

            setState(() {});
          },
          parentContext: context,
          validator: (value) =>
              Validations.validateGroup(context: context, value: value ?? ''),
        ),
        widget.isCadreProgram
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0).r,
                child: Text(AppLocalizations.of(context)!
                    .mNoteForDoptBlendedProgramGroup),
              )
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

    dynamic inReviewGroup =
        inReviewFields.where((element) => element.containsKey(_groupKey));

    _groupController.text =
        (inReviewFields.isNotEmpty && inReviewGroup.isNotEmpty)
            ? inReviewGroup.first[_groupKey]
            : (profileDetails?.group ?? '');

    setState(() {});
  }
}
