import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/event_detailv2_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventsSpeakers extends StatefulWidget {
  final List<Speaker> speakersList;
  const EventsSpeakers({super.key, required this.speakersList});

  @override
  State<EventsSpeakers> createState() => _EventsSpeakersState();
}

class _EventsSpeakersState extends State<EventsSpeakers> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.appBarBackground,
      child: ExpansionTile(
        textColor: AppColors.greys,
        iconColor: AppColors.greys,
        trailing: Transform.rotate(
          angle: isExpanded ? 3.14159 / 2 : 0,
          child: Icon(
            Icons.chevron_right,
            size: 24,
            color: AppColors.greys,
          ),
        ),
        onExpansionChanged: (bool expanding) => setState(() {
          isExpanded = expanding;
        }),
        title: Row(
          children: [
            Text(
              AppLocalizations.of(context)!.mSpeakers,
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        tilePadding: EdgeInsets.only(left: 8, right: 8).r,
        childrenPadding: EdgeInsets.all(8).r,
        children: <Widget>[
          ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return (widget.speakersList[index].email == null ||
                        widget.speakersList[index].name == null)
                    ? SizedBox.shrink()
                    : speakerCard(
                        description:
                            widget.speakersList[index].description ?? "",
                        email: widget.speakersList[index].email!,
                        name: widget.speakersList[index].name!,
                      );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  height: 32.w,
                  color: AppColors.greys60,
                );
              },
              itemCount: widget.speakersList.length),
        ],
      ),
    );
  }

  Widget speakerCard(
      {required String name, required String email, String? description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: GoogleFonts.lato(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 4.w,
        ),
        // Text(
        //   email,
        //   style: GoogleFonts.lato(
        //       fontSize: 12.sp,
        //       fontWeight: FontWeight.w400,
        //       color: AppColors.primaryThree),
        // ),
        // SizedBox(
        //   height: 4.w,
        // ),
        Text(
          description ?? "",
          style: GoogleFonts.lato(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.greys87),
        )
      ],
    );
  }
}
