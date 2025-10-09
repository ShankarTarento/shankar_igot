import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/services/gyaan_karmayogi_services.dart';
import 'package:karmayogi_mobile/util/index.dart';
import 'package:provider/provider.dart';

class AgkForm extends StatefulWidget {
  const AgkForm({super.key});

  @override
  State<AgkForm> createState() => _AgkFormState();
}

class _AgkFormState extends State<AgkForm> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GyaanKarmayogiServicesV2>(
        builder: (context, providerData, child) {
      Map<String, dynamic>? knowMore =
          providerData.amritGyaanConfig['knowMoreInfo'];
      Map<String, dynamic>? mobileConfig =
          providerData.amritGyaanConfig['mobileConfig'];

      return knowMore != null
          ? Column(
              children: [
                SvgPicture.network(
                  ApiUrl.baseUrl +
                      '/assets/instances/eagle/banners/hubs/knowledgeresource/karmayogi-info.svg',
                  height: 171.w,
                ),
                Container(
                  width: 1.sw,
                  padding:
                      EdgeInsets.only(left: 50, right: 50, top: 24, bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.darkBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: AppColors.appBarBackground,
                      ),
                      SizedBox(
                        height: 16.w,
                      ),
                      Text(
                        knowMore['helpTextKey'] ?? '',
                        style: GoogleFonts.lato(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.appBarBackground),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 16.w,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          mobileConfig != null &&
                                  mobileConfig.isNotEmpty &&
                                  mobileConfig['clickHere'] != null
                              ? Helper.doLaunchUrl(
                                  url: mobileConfig['clickHere'])
                              : null;
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(AppColors.primaryOne),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                        child: Text(
                          knowMore['btnName'],
                          style: GoogleFonts.lato(
                              color: AppColors.greys, fontSize: 14.sp),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          : SizedBox();
    });
  }
}
