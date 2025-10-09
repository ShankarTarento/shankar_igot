import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SeeAllConnectionRequests extends StatelessWidget {
  final connectionRequests;
  final parentAction;
  final maxLimitToShowRequests = 3;

  SeeAllConnectionRequests(this.connectionRequests, {this.parentAction});
  bool get showRequests =>
      this.connectionRequests.data.length > maxLimitToShowRequests;
  @override
  Widget build(BuildContext context) {
    return connectionRequests.data.length > 0
        ? InkWell(
            onTap: parentAction,
            splashColor: Theme.of(context).primaryColor,
            child: Stack(children: _buildItems(context)))
        : SizedBox.shrink();
  }

  List<Widget> _buildItems(BuildContext context) {
    List<Widget> stackElements = [];
    stackElements.add(Container(
      height: 56.w,
      padding: const EdgeInsets.all(14).r,
      margin: const EdgeInsets.all(1.5).r,
      decoration: BoxDecoration(
        color: AppColors.darkBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8).r,
        border: Border.all(
          color: AppColors.darkBlue.withValues(alpha: 0.1),
          width: 1, //                   <--- border width here
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: 170.w,
            child: Text(
              AppLocalizations.of(context)!.mStaticMyActivitySeePendingReqs,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge!
                  .copyWith(letterSpacing: 0.5.r),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 4.w,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3.0).r,
            child: Icon(
              Icons.arrow_forward_ios_sharp,
              size: 12.sp,
              weight: 2,
              grade: 2,
              color: AppColors.darkBlue,
            ),
          ),
          Spacer(),
          _stackedConnRequests(),
          Visibility(
            visible: showRequests,
            child: Text(
              '+ ${connectionRequests.data.length - maxLimitToShowRequests}',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(letterSpacing: 0.25.r),
            ),
          ),
        ],
      ),
    ));

    stackElements.add(Positioned(
      // draw a red marble
      top: -1,
      right: -1,
      child: new Icon(Icons.brightness_1,
          size: 8.0.sp, color: AppColors.negativeLight),
    ));
    return stackElements;
  }

  Widget _stackedConnRequests() {
    return Container(
        width: showRequests ? 80 : 50,
        height: 24.w,
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: connectionRequests.data.length > maxLimitToShowRequests
                ? maxLimitToShowRequests
                : connectionRequests.data.length,
            itemBuilder: (context, index) {
              return Align(
                widthFactor: 0.4,
                child: CircleAvatar(
                  backgroundColor: AppColors.appBarBackground,
                  child: CircleAvatar(
                    backgroundColor: AppColors.networkBg[
                        Random().nextInt(AppColors.networkBg.length)],
                    radius: 11,
                    child: Text(
                      getInitials(connectionRequests.data[index]['fullName']),
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(letterSpacing: 0.5.r),
                    ),
                  ),
                ),
              );
            }));
  }
}

String getInitials(String fullName) => fullName.isNotEmpty
    ? fullName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
    : '';
