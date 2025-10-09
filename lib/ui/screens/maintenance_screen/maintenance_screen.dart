import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/common_components/models/maintenance_screen_model.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/screens/maintenance_screen/maintenance_screen_repository.dart';
import 'package:karmayogi_mobile/util/index.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../localization/_langs/english_lang.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  ServerUnderMaintenance? maintenanceConfig;

  @override
  void initState() {
    super.initState();

    maintenanceConfig = MaintenanceScreenRepository.serverUnderMaintenanceData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/maintenance.jpg'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              Spacer(),
              Padding(
                padding:
                    const EdgeInsets.only(left: 130.0, top: 0, right: 20).r,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      maintenanceConfig?.greet.getText(context) ?? '',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.orangeTourText,
                      ),
                    ),
                    Text(
                      maintenanceConfig?.title.getText(context) ?? '',
                      style: GoogleFonts.montserrat(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greys,
                      ),
                    ),
                    SizedBox(
                      height: 20.w,
                    ),
                    Text(
                      maintenanceConfig?.description.getText(context) ?? '',
                      style: GoogleFonts.lato(
                        fontSize: 12.sp,
                        height: 1.3,
                        fontWeight: FontWeight.w400,
                        color: AppColors.greys,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10.w,
                    ),
                    Text(
                      maintenanceConfig?.subTitle.getText(context) ?? '' + ' ',
                      style: GoogleFonts.lato(
                        fontSize: 12.sp,
                        height: 1.3,
                        fontWeight: FontWeight.w900,
                        color: AppColors.greys,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20.w,
                    ),
                    maintenanceConfig?.thumbnailTitle != null
                        ? Text(
                            maintenanceConfig?.thumbnailTitle!
                                    .getText(context) ??
                                '',
                            style: GoogleFonts.lato(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.greys),
                          )
                        : SizedBox(),
                    SizedBox(
                      height: 10.w,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (maintenanceConfig != null &&
                              maintenanceConfig?.thumbnails != null &&
                              maintenanceConfig!.thumbnails!.isNotEmpty)
                            for (var thumbnail
                                in maintenanceConfig!.thumbnails!)
                              InkWell(
                                onTap: () async {
                                  await canLaunchUrl(
                                          Uri.parse(thumbnail.redirectionUrl))
                                      .then((value) => value
                                          ? launchUrl(
                                              Uri.parse(
                                                  thumbnail.redirectionUrl),
                                              mode: LaunchMode
                                                  .externalApplication)
                                          : throw 'Please try after sometime');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0).r,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 80.w,
                                        width: 110.w,
                                        child: CachedNetworkImage(
                                          imageUrl: ApiUrl.baseUrl +
                                              '/' +
                                              thumbnail.image,
                                          errorWidget:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                            'assets/img/image_placeholder.jpg',
                                            width: double.infinity.w,
                                            fit: BoxFit.fill,
                                          ),
                                          placeholder: (context, url) =>
                                              ContainerSkeleton(
                                            height: 65.w,
                                            width: 110.w,
                                            radius: 8.r,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 50.w,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/img/conference_icon.svg',
                        width: 28.0.w,
                        height: 28.0.w,
                        colorFilter:
                            ColorFilter.mode(AppColors.appBarBackground, BlendMode.srcIn),
                      ),
                      SizedBox(
                        height: 16.w,
                      ),
                      Text(
                        AppLocalizations.of(context)!.mJoinConferenceMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 16.sp,
                          color: AppColors.appBarBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 32.w,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await canLaunchUrl(
                                  Uri.parse(EnglishLang.htmlTeamsUriLink))
                              .then((value) => value
                                  ? launchUrl(
                                      Uri.parse(EnglishLang.htmlTeamsUriLink),
                                      mode: LaunchMode.externalApplication)
                                  : throw 'Please try after sometime');
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(142.w, 40.w),
                          backgroundColor: AppColors.orangeTourText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.mCallNow,
                          style: GoogleFonts.lato(
                            color: AppColors.greys,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16.w,
                      ),
                      Text(
                        AppLocalizations.of(context)!.mEmailUs,
                        style: GoogleFonts.lato(
                            color: AppColors.appBarBackground, fontSize: 16.sp),
                      ),
                      InkWell(
                        onTap: () async {
                          await Helper.mailTo(supportEmail);
                        },
                        child: Text(
                          supportEmail,
                          style: GoogleFonts.lato(
                              color: AppColors.orangeTourText,
                              decoration: TextDecoration.underline),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 50.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
