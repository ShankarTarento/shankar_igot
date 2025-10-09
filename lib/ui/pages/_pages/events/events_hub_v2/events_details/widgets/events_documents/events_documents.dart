import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/event_detailv2_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/widgets/events_documents/widgets/events_documents_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventsDocuments extends StatefulWidget {
  final List<EventHandout> eventHandouts;
  const EventsDocuments({super.key, required this.eventHandouts});

  @override
  State<EventsDocuments> createState() => _EventsDocumentsState();
}

class _EventsDocumentsState extends State<EventsDocuments> {
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
              AppLocalizations.of(context)!.mDocuments,
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        tilePadding: EdgeInsets.only(left: 8, right: 8).r,
        childrenPadding: EdgeInsets.only(left: 8, right: 8, bottom: 8).r,
        children: <Widget>[
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.eventHandouts.length,
            itemBuilder: (context, index) {
              return EventsDocumentsCard(
                eventHandout: widget.eventHandouts[index],
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 36.w,
                color: AppColors.grey40,
              );
            },
          ),
        ],
      ),
    );
  }
}
