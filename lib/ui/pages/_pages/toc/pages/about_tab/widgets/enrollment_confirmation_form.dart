import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EnrollmentConfirmationForm extends StatelessWidget {
  final Batch selectedBatch;
  final ValueChanged<String> enrollParentAction;

  const EnrollmentConfirmationForm(
      {super.key,
      required this.enrollParentAction,
      required this.selectedBatch});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.w,
      padding: EdgeInsets.only(top: 24, left: 16, right: 16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.mSurveyFormOneStepAwayFromEnroll,
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 16.w,
          ),
          Text(
            "${AppLocalizations.of(context)!.mThisBatchStarting} ${DateTimeHelper.getDateTimeInFormat(selectedBatch.startDate, desiredDateFormat: IntentType.dateFormat2)} - ${DateTimeHelper.getDateTimeInFormat(selectedBatch.endDate, desiredDateFormat: IntentType.dateFormat2)}, ${AppLocalizations.of(context)!.mBatchStartConsent}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(
            height: 20.w,
          ),
          Row(
            children: [
              SizedBox(
                width: 1.sw / 2.3,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(AppColors.appBarBackground),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        side: BorderSide(color: AppColors.darkBlue),
                        borderRadius: BorderRadius.circular(63.0).r,
                      ),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.mStaticCancel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              Spacer(),
              SizedBox(
                width: 1.sw / 2.3,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    enrollParentAction("Confirm");
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(AppColors.darkBlue),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(63.0).r,
                      ),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.mStaticEnroll,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
