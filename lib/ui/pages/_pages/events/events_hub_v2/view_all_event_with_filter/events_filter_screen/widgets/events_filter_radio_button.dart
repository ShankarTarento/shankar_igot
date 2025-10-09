import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/events_filter_model.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:igot_ui_components/utils/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventsFilterRadioButton extends StatefulWidget {
  final String title;
  final List<EventFilterModel> checkListItems;
  final ValueChanged<String> onChanged;
  final String? selectedItem;

  const EventsFilterRadioButton({
    super.key,
    required this.title,
    this.selectedItem,
    required this.checkListItems,
    required this.onChanged,
  });

  @override
  State<EventsFilterRadioButton> createState() => _FilterRadioButtonV2State();
}

class _FilterRadioButtonV2State extends State<EventsFilterRadioButton> {
  late List<EventFilterModel> filteredItems;
  String? selectedItem;
  bool showAll = false;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.checkListItems;
    selectedItem = widget.selectedItem;
  }

  @override
  void didUpdateWidget(covariant EventsFilterRadioButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedItem != widget.selectedItem) {
      setState(() {
        filteredItems = widget.checkListItems;
        selectedItem = widget.selectedItem;
      });
    }
  }

  void _toggleShowAll() {
    setState(() {
      showAll = !showAll;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayCount =
        (filteredItems.length > 5 && !showAll) ? 5 : filteredItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.w),
        Text(
          widget.title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 16.w),
        Column(
          children: List.generate(
            displayCount,
            (index) {
              final item = filteredItems[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedItem = item.title.id;
                  });
                  widget.onChanged(selectedItem!);
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 25).r,
                  height: 20.w,
                  child: Row(
                    children: [
                      Radio(
                        value: item.title.id,
                        groupValue: selectedItem,
                        onChanged: (String? value) {
                          setState(() {
                            selectedItem = value!;
                          });
                          widget.onChanged(value!);
                        },
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return ModuleColors.darkBlue;
                            }
                            return ModuleColors.black40;
                          },
                        ),
                      ),
                      Text(
                        ModuleHelper.capitalize(item.title.text),
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: ModuleColors.greys60,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (filteredItems.length > 5)
          TextButton(
            onPressed: _toggleShowAll,
            style: TextButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
            ),
            child: Text(
              showAll
                  ? AppLocalizations.of(context)!.mCompetencyViewLessTxt
                  : AppLocalizations.of(context)!.mStaticViewAll,
              style: GoogleFonts.lato(
                color: AppColors.darkBlue,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        SizedBox(height: 16.w),
      ],
    );
  }
}
