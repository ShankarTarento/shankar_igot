import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/events_insights_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/view_all_event_with_filter/view_all_event.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_image_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class BrowseEventsStrip extends StatelessWidget {
  final List<EventInsightsModel> browseEventCardData;
  const BrowseEventsStrip({super.key, required this.browseEventCardData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 16).r,
            child: TitleWidget(
                title: Helper.capitalizeEachWordFirstCharacter(
                    AppLocalizations.of(context)!.mBrowseEvents)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: getCards(context),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> getCards(context) {
    List<Widget> cards = [];
    for (var item in browseEventCardData) {
      if (item.key == EventFilter.karmayogiSaptah) {
        cards.add(browseEventCard(
            key: EventFilter.karmayogiSaptah,
            context: context,
            imageUrl: item.icon,
            title: item.title.getText(context)));
      }
      if (item.key == EventFilter.karmayogiTalks) {
        cards.add(browseEventCard(
            key: EventFilter.karmayogiTalks,
            context: context,
            imageUrl: item.icon,
            title: item.title.getText(context)));
      }
      if (item.key == EventFilter.rajyaKarmayogiSaptha) {
        cards.add(browseEventCard(
            key: EventFilter.rajyaKarmayogiSaptha,
            context: context,
            imageUrl: item.icon,
            title: item.title.getText(context)));
      }
      if (item.key == EventFilter.all) {
        cards.add(browseEventCard(
          context: context,
          imageUrl: item.icon,
          title: item.title.getText(context),
        ));
      }
    }
    return cards;
  }

  Widget browseEventCard(
      {required String title,
      required String imageUrl,
      String? key,
      required BuildContext context}) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            FadeRoute(
                page: ViewAllEvent(
              selectedEventType: key != null ? [key] : [],
            )));
      },
      child: Container(
        padding: EdgeInsets.all(10).r,
        height: 73.w,
        width: 165.w,
        margin: EdgeInsets.only(left: 16).r,
        decoration: BoxDecoration(
          color: AppColors.appBarBackground,
          borderRadius: BorderRadius.circular(8).r,
          border: Border.all(color: AppColors.grey08),
        ),
        child: Row(children: [
          ImageWidget(
            height: 35.w,
            width: 55.w,
            imageUrl: imageUrl,
            fit: BoxFit.contain,
          ),
          SizedBox(
            width: 4.w,
          ),
          SizedBox(
              width: 80.w,
              child: Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ))
        ]),
      ),
    );
  }
}
