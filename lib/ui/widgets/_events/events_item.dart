import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/ui/widgets/primary_category_widget.dart';
import '../../../util/helper.dart';

class EventsItem extends StatelessWidget {
  final event;
  const EventsItem({Key? key, this.event}) : super(key: key);

  formateDate(date) {
    return DateFormat("MMMM d, y").format(DateTime.parse(date));
  }

  formateTime(time) {
    return time.substring(0, 5);
  }

  generateEvent(context) {
    var eventWidgets = Column(
      children: <Widget>[],
    );
    eventWidgets.children.add(ClipRRect(
        //  borderRadius: BorderRadius.all(Radius.circular(40)),
        child: Stack(fit: StackFit.passthrough, children: <Widget>[
      ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ).r,
        child: event.eventIcon != null
            ? (Image.network(
                Helper.convertImageUrl(
                  event.eventIcon,
                ),
                fit: BoxFit.fitHeight,
                // fit: BoxFit.fill,
                width: double.infinity.w,
                height: 150.w,
                errorBuilder: (context, error, stackTrace) => SizedBox.shrink(),
              ))
            : Image.asset(
                'assets/img/image_placeholder.jpg',
                width: double.infinity.w,
                height: 150.w,
                fit: BoxFit.fitWidth,
              ),
      )
    ])));
    eventWidgets.children.add(
      Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 4).r,
        alignment: Alignment.topLeft,
        child: PrimaryCategoryWidget(
          contentType: event.eventType,
          addedMargin: true,
        ),
      ),
    );
    eventWidgets.children.add(
      Container(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 4).r,
        alignment: Alignment.topLeft,
        child: Text(
          event.source != null ? event.source : 'iGOT',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lato(
            color: AppColors.greys60,
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
    eventWidgets.children.add(Container(
      // height: 43,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 4).r,
      child: Text(
        event.name != null ? event.name : '',
        maxLines: 1,
        style: GoogleFonts.lato(
          color: AppColors.greys87,
          fontWeight: FontWeight.w700,
          fontSize: 16.0.sp,
          height: 1.5.w,
        ),
      ),
    ));
    eventWidgets.children.add(Container(
      // constraints: BoxConstraints(minHeight: 60),
      height: 30.w,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(left: 16, right: 16).r,
      child: Text(
        formateDate(event.startDate) + ' ' + formateTime(event.startTime),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.lato(
          color: AppColors.darkBlue,
          fontWeight: FontWeight.w400,
          fontSize: 14.0.sp,
          height: 1.5.w,
        ),
      ),
    ));
    eventWidgets.children.add(Container(
      // constraints: BoxConstraints(minHeight: 60),
      // height: 50,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16).r,
      child: Text(
        event.description != null ? event.description : '',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.lato(
          color: AppColors.greys60,
          fontWeight: FontWeight.w400,
          fontSize: 14.0.sp,
          height: 1.5.w,
        ),
      ),
    ));

    return eventWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 12).r,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey08,
            blurRadius: 6.0.r,
            spreadRadius: 0.r,
            offset: Offset(
              3,
              3,
            ),
          ),
        ],
        border: Border.all(color: AppColors.grey08),
        borderRadius: BorderRadius.circular(6).r,
      ),
      child: generateEvent(context),
    );
  }
}
