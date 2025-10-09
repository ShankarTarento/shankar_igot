import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmptyConnectionState extends StatelessWidget {
  final String? message;
  const EmptyConnectionState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ImageWidget(
            height: 90.w,
            imageUrl: ApiUrl.baseUrl + "/assets/icons/no-data.svg"),
        SizedBox(height: 16.w),
        Text(
          message ?? AppLocalizations.of(context)!.mMsgNoConnectionFound,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
