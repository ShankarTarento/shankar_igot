import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/notification_icon.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/widgets/events_share_page.dart';
import 'package:karmayogi_mobile/ui/widgets/title_regular_grey60.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventDetailsAppbar extends StatefulWidget implements PreferredSizeWidget {
  final bool automaticallyImplyLeading;
  final String eventId;

  EventDetailsAppbar({
    this.automaticallyImplyLeading = true,
    required this.eventId,
  });

  @override
  _EventDetailsAppbarState createState() => _EventDetailsAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _EventDetailsAppbarState extends State<EventDetailsAppbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.appBarBackground,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_sharp, size: 24.sp, color: AppColors.greys60),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Spacer(),
          _notificationButton(),
          _shareButton(context),
        ],
      ),
    );
  }

  Widget _notificationButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0).r,
      child: NotificationIcon(),
    );
  }

  Widget _shareButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0).r,
      child: GestureDetector(
        onTap: () => _shareModalBottomSheetMenu(context),
        child: Icon(
          Icons.share,
          color: AppColors.darkBlue,
        ),
      ),
    );
  }

  void _shareModalBottomSheetMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return EventsSharePage(
          eventId: widget.eventId,
        );
      },
    );
  }

  void receiveShareResponse(String data) {
    _showSuccessDialogBox(context);
  }

  void _showSuccessDialogBox(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) => FutureBuilder(
        future: Future.delayed(Duration(seconds: 3)).then((value) => true),
        builder: (BuildContext futureContext, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            Navigator.of(context).pop();
          }
          return _buildSuccessDialog();
        },
      ),
    );
  }

  Widget _buildSuccessDialog() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16).r,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12).r,
          ),
          actionsPadding: EdgeInsets.zero.r,
          actions: [
            Container(
              padding: EdgeInsets.all(16).r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12).r,
                color: AppColors.positiveLight,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TitleRegularGrey60(
                      AppLocalizations.of(context)!
                          .mContentSharePageSuccessMessage,
                      fontSize: 14.sp,
                      color: AppColors.appBarBackground,
                      maxLines: 3,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 4, 0).r,
                    child: Icon(
                      Icons.check,
                      color: AppColors.appBarBackground,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
