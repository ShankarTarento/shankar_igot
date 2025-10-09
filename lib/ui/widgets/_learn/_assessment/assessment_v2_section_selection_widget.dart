import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../constants/index.dart';

typedef IntCallback = void Function(int value);

class SectionSelectionWidgetV2 extends StatefulWidget {
  final List<dynamic> assessmentDetails;
  final IntCallback changeSection;
  final int sectionIndex;
  SectionSelectionWidgetV2(
      {Key? key,
      required this.assessmentDetails,
      required this.changeSection,
      required this.sectionIndex})
      : super(key: key);
  @override
  State<SectionSelectionWidgetV2> createState() =>
      _SectionSelectionWidgetV2State();
}

class _SectionSelectionWidgetV2State extends State<SectionSelectionWidgetV2> {
  dynamic selectedItem;

  List<dynamic> _dropdownItems = [];

  @override
  void initState() {
    super.initState();
    selectedItem = widget.assessmentDetails.toList()[widget.sectionIndex];
    _dropdownItems = widget.assessmentDetails.toList();
  }

  @override
  void didUpdateWidget(SectionSelectionWidgetV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sectionIndex != widget.sectionIndex) {
      selectedItem = widget.assessmentDetails.toList()[widget.sectionIndex];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5).r,
      decoration: BoxDecoration(
          color:
              widget.assessmentDetails[widget.sectionIndex].expectedDuration !=
                      null
                  ? AppColors.grey40
                  : AppColors.darkBlue,
          borderRadius: BorderRadius.circular(63)),
      child: IgnorePointer(
        ignoring:
            widget.assessmentDetails[widget.sectionIndex].expectedDuration !=
                null,
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedItem.identifier,
          underline: Center(),
          dropdownColor: AppColors.darkBlue,
          iconEnabledColor: AppColors.appBarBackground,
          onChanged: (String? newValue) {
            if (widget
                    .assessmentDetails[widget.sectionIndex].expectedDuration ==
                null) {
              int selectedIndex = _dropdownItems
                  .indexWhere((element) => element['identifier'] == newValue);
              if (widget.assessmentDetails[selectedIndex].submitted ==
                      null ||
                  !widget.assessmentDetails[selectedIndex].submitted) {
                setState(() {
                  widget.changeSection(selectedIndex);
                  selectedItem = _dropdownItems.firstWhere(
                      (element) => element['identifier'] == newValue);
                });
              } else if (widget.assessmentDetails[selectedIndex].submitted !=
                      null ||
                  widget.assessmentDetails[selectedIndex].submitted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.mAssessmentResponseAddedMsg,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )));
              }
            }
            // else {
            //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //       content: Column(
            //     children: [
            //       Text(
            //         AppLocalizations.of(context)
            //             !.mAssessmentNotAllowedToSwitchSection,
            //         textAlign: TextAlign.center,
            //       ),
            //     ],
            //   )));
            // }
          },
          items: _dropdownItems.map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem<String>(
              value: value.identifier,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 0.77.sw),
                child: Text(
                  value.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    color: AppColors.appBarBackground,
                    fontSize: 14.0.spMax,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
