import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_resource_details.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/details_screen/widgets/details_screen_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/details_screen/widgets/resource_details_screen_header.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/details_screen/widgets/resource_player.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/details_screen/widgets/sector_subsector_view.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/services/gyaan_karmayogi_services.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/course_sharing/course_sharing_page.dart';

class ResourceDetailsScreenV2 extends StatefulWidget {
  final String resourceId;
  final int? startAt;

  const ResourceDetailsScreenV2({
    super.key,
    this.startAt,
    required this.resourceId,
  });

  @override
  State<ResourceDetailsScreenV2> createState() =>
      _ResourceDetailsScreenV2State();
}

class _ResourceDetailsScreenV2State extends State<ResourceDetailsScreenV2> {
  @override
  void initState() {
    getResourceDetails();
    super.initState();
  }

  void receiveShareResponse(String data) {
    _showSuccessDialogBox();
  }

  _showSuccessDialogBox() => {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (BuildContext contxt) => FutureBuilder(
                future:
                    Future.delayed(Duration(seconds: 3)).then((value) => true),
                builder: (BuildContext futureContext, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    Navigator.of(contxt).pop();
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AlertDialog(
                          insetPadding: EdgeInsets.symmetric(horizontal: 16).r,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12).r),
                          actionsPadding: EdgeInsets.zero,
                          actions: [
                            Container(
                              padding: EdgeInsets.all(16).r,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12).r,
                                  color: AppColors.positiveLight),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Container(
                                        child: Text(
                                      AppLocalizations.of(context)!
                                          .mContentSharePageSuccessMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lato(
                                        color: AppColors.appBarBackground,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14.sp,
                                        letterSpacing: 0.25,
                                        height: 1.3.w,
                                      ),
                                    )),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 4, 4, 0)
                                            .r,
                                    child: Icon(
                                      Icons.check,
                                      color: AppColors.appBarBackground,
                                      size: 24.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ],
                  );
                }))
      };

  late Future<ResourceDetails?> resourceDetailsFuture;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ResourceDetails?>(
        future: resourceDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return DetailsScreenSkeleton();
          }
          if (snapshot.data != null) {
            ResourceDetails resourceDetails = snapshot.data!;

            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                titleSpacing: 0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    size: 24.sp,
                    color: ModuleColors.greys60,
                    weight: 700,
                  ),
                ),
                title: Row(children: [
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: false,
                        enableDrag: false,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return Container(
                              child: CourseSharingPage(
                            resourceDetails.identifier!,
                            resourceDetails.name!,
                            resourceDetails.posterImage!,
                            resourceDetails.source!,
                            resourceDetails.primaryCategory!,
                            receiveShareResponse,
                          ));
                        },
                      );
                    },
                    icon: Icon(
                      Icons.share,
                      size: 24.sp,
                      color: ModuleColors.greys60,
                      weight: 700,
                    ),
                  )
                ]),
              ),
              body: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResourceDetailsScreenHeaderV2(
                          resourceDetails: resourceDetails),
                      Padding(
                        padding: const EdgeInsets.all(16).r,
                        child: ResourcePlayer(
                          resourceDetails: resourceDetails,
                          startAt: widget.startAt,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                                left: 16.0, right: 16, bottom: 16)
                            .r,
                        child: Text(
                          resourceDetails.description ?? '',
                          style: GoogleFonts.lato(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SectorSubsectorView(
                        sectorDetails: resourceDetails.sectors ?? [],
                      ),
                      SizedBox(height: 150.w),
                    ]),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(),
            body: Column(
              children: [
                SizedBox(height: 150.w),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.mNoResourcesFound,
                    style: GoogleFonts.lato(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  getResourceDetails() async {
    resourceDetailsFuture =
        GyaanKarmayogiServicesV2.getResourceDetails(id: widget.resourceId);
  }
}
