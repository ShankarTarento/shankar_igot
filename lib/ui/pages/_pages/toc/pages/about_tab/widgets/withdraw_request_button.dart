import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';

import '../../../../../../../models/index.dart';

class WithdrawRequest extends StatefulWidget {
  final Batch? selectedBatch;
  final Course? courseDetails;
  final Function()? withdrawFunction;
  const WithdrawRequest(
      {Key? key, this.courseDetails, this.selectedBatch, this.withdrawFunction})
      : super(key: key);

  @override
  State<WithdrawRequest> createState() => _WithdrawRequestState();
}

class _WithdrawRequestState extends State<WithdrawRequest> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: Container(
        padding: EdgeInsets.only(bottom: 16).r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12).r,
          color: AppColors.orangeTourText.withValues(alpha: 0.2),
        ),
        width: 1.sw,
        child: Column(children: [
          Container(
              margin:
                  EdgeInsets.only(bottom: 10, left: 16, right: 16, top: 16).r,
              padding: EdgeInsets.all(12).r,
              decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  borderRadius: BorderRadius.circular(4).r,
                  border: Border.all(color: AppColors.primaryOne)),
              width: 1.sw,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedBatch!.name,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 4.w,
                  ),
                  Text(
                    '${DateTimeHelper.getDateTimeInFormat(widget.selectedBatch!.startDate, desiredDateFormat: IntentType.dateFormat2)} to  ${DateTimeHelper.getDateTimeInFormat(widget.selectedBatch!.endDate, desiredDateFormat: IntentType.dateFormat2)}',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              )),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16).r,
            child: SizedBox(
              width: 1.sw,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16))
                            .r,
                        side: BorderSide(
                          color: AppColors.grey08,
                        ),
                      ),
                      builder: (BuildContext context) {
                        return Container(
                            height: 220.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8).r)),
                            child: confirmWithdraw());
                      });
                },
                child: Text(
                  'Withdraw request',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                style: ButtonStyle(
                  elevation: WidgetStateProperty.all<double>(0),
                  backgroundColor: WidgetStateProperty.all<Color>(AppColors.appBarBackground),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(63.0).r,
                        side: BorderSide(color: AppColors.darkBlue)),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget confirmWithdraw() {
    return Container(
      padding: EdgeInsets.only(top: 24, bottom: 24, left: 16, right: 16).r,
      width: 1.sw,
      child: Column(
        children: [
          Text(
            'Are you sure you want to withdraw your request?',
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              height: 1.5.w,
            ),
          ),
          SizedBox(
            height: 8.w,
          ),
          Text(
            'You will miss the learning opportunity if you withdraw your enrollment',
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              height: 1.5.w,
            ),
          ),
          SizedBox(
            height: 24.w,
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 40.w,
                  child: ElevatedButton(
                    onPressed: () => {
                      //   widget.enrollParentAction('Cancel'),
                      Navigator.of(context).pop(true)
                    },
                    style: ButtonStyle(
                      elevation: WidgetStateProperty.all<double>(0),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0).r,
                              side: BorderSide(
                                color: AppColors.darkBlue,
                                width: 1.5.w,
                              ))),
                      backgroundColor: WidgetStateProperty.all<Color>(
                          AppColors.appBarBackground),
                    ),
                    // padding: EdgeInsets.all(15.0),
                    child: Text(
                      EnglishLang.cancel,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            letterSpacing: 1,
                          ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 16.w,
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 40.w,
                  child: ElevatedButton(
                    onPressed: () {
                      //   widget.enrollParentAction('Cancel'),
                      //  Navigator.of(context).pop(true)
                      widget.withdrawFunction!();
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      elevation: WidgetStateProperty.all<double>(0),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0).r,
                      )),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(AppColors.darkBlue),
                    ),
                    // padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Confirm',
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            letterSpacing: 1,
                          ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
