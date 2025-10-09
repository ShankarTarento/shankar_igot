import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/util/index.dart';

class EventsDescription extends StatefulWidget {
  final String eventDescription;
  const EventsDescription({super.key, required this.eventDescription});

  @override
  State<EventsDescription> createState() => _EventsDescriptionState();
}

class _EventsDescriptionState extends State<EventsDescription> {
  bool trimText = true;
  final int _maxLength = 100;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (trimText && widget.eventDescription.length > _maxLength)
              ? widget.eventDescription.substring(0, _maxLength - 1) + '...'
              : widget.eventDescription,
          style: GoogleFonts.lato(
            decoration: TextDecoration.none,
            color: AppColors.greys,
            fontSize: 14.sp,
            height: 1.5.w,
            fontWeight: FontWeight.w400,
          ),
        ),
        widget.eventDescription.length > _maxLength
            ? Padding(
                padding: const EdgeInsets.only(top: 8).r,
                child: InkWell(
                    onTap: _toggleReadMore,
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 2.0).r,
                      child: Text(
                        trimText
                            ? Helper.capitalizeFirstLetter(
                                AppLocalizations.of(context)!.mStaticShowAll)
                            : Helper.capitalizeFirstLetter(
                                AppLocalizations.of(context)!.mStaticShowLess),
                        style: GoogleFonts.lato(
                          color: AppColors.darkBlue,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.darkBlue,
                            width: 1.3,
                          ),
                        ),
                      ),
                    )),
              )
            : Center(),
      ],
    );
  }

  void _toggleReadMore() {
    setState(() {
      trimText = !trimText;
    });
  }
}
