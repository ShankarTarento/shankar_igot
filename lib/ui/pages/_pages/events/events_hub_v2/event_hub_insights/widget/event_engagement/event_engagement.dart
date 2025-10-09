import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/events_insights_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/event_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_image_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class EventEngagement extends StatelessWidget {
  final String title;
  final List<EventInsightsModel> data;

  const EventEngagement({super.key, required this.data, required this.title});

  Future<List<Widget>> getInsightsCards(context) async {
    List<Widget> insightsCards = [];
    Map<String, dynamic> eventData =
        await EventRepository().getUserEnrolledEventStatistics();

    for (var item in data) {
      if (item.key == "eventsEnrolled") {
        insightsCards.add(
          eventEngagementCard(
            image: ImageWidget(
              height: 40.w,
              width: 40.w,
              imageUrl: item.icon,
            ),
            subtitle: eventData["eventsEnrolled"] != null
                ? eventData["eventsEnrolled"].toString()
                : "-",
            title: item.title.getText(context),
          ),
        );
      }
      if (item.key == "hoursSpentOnEvents") {
        insightsCards.add(eventEngagementCard(
          image: ImageWidget(
            imageUrl: item.icon,
            width: 40.0.w,
            height: 40.0.w,
            color: AppColors.primaryOne,
          ),
          subtitle: eventData['hoursSpentOnEvents'] != null
              ? DateTimeHelper.getTimeFormat(
                  (eventData['hoursSpentOnEvents']).toString())
              : "-",
          title: item.title.getText(context),
        ));
      }
      if (item.key == "eventsAttended") {
        insightsCards.add(eventEngagementCard(
          image: ImageWidget(
            height: 40.w,
            width: 40.w,
            imageUrl: item.icon,
          ),
          subtitle: eventData['eventsAttended'] != null
              ? eventData['eventsAttended'].toString()
              : "-",
          title: item.title.getText(context),
        ));
      }
    }
    return insightsCards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: true,
        title: Text(Helper.capitalizeEachWordFirstCharacter(title),
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            )),
        centerTitle: false,
        shadowColor: Colors.transparent,
      ),
      body: FutureBuilder<List<Widget>>(
        future: getInsightsCards(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return getSkeletonLoading();
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0).r,
              child: Column(
                children: snapshot.data!,
              ),
            );
          }

          return Center(
            child: Text(
              AppLocalizations.of(context)!.mNoResourcesFound,
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget eventEngagementCard({
    required String title,
    required String subtitle,
    required Widget image,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16).r,
      height: 100.w,
      width: 1.sw,
      padding: EdgeInsets.all(16).r,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: Row(children: [
        image,
        VerticalDivider(
          width: 32.w,
          thickness: 1,
          color: AppColors.grey40,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Helper.capitalizeEachWordFirstCharacter(title),
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                color: AppColors.greys60,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: 4.w,
            ),
            Text(
              subtitle,
              style: GoogleFonts.montserrat(
                fontSize: 24.sp,
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
      ]),
    );
  }

  Widget getSkeletonLoading() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: ContainerSkeleton(
            height: 100,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
