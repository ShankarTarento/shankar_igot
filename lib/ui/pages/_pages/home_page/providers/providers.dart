import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/show_all_card/show_all_card.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';

import 'package:karmayogi_mobile/ui/pages/_pages/microsites/screen/all_provider_screen/browse_by_all_provider.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/screen/microsite_screen/ati_cti_microsites_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/helper.dart';

import '../../../../../constants/index.dart';
import '../../../../../models/_models/provider_model.dart';
import '../../../../../util/faderoute.dart';

class Providers extends StatefulWidget {
  final List<ProviderCardModel> topProviderList;
  const Providers({Key? key, required this.topProviderList}) : super(key: key);

  @override
  State<Providers> createState() => _ProvidersState();
}

class _ProvidersState extends State<Providers> {
  @override
  void initState() {
    randomNumber = Random().nextInt(AppColors.networkBg.length);
    super.initState();
  }

  int randomNumber = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 260.w,
          child: ListView.builder(
              itemCount: widget.topProviderList.length >= 5
                  ? 6
                  : widget.topProviderList.length + 1,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                if (index == widget.topProviderList.length) {
                  return InkWell(
                    onTap: () {
                      HomeTelemetryService.generateInteractTelemetryData(
                        TelemetryIdentifier.showAll,
                        subType: TelemetrySubType.providers,
                      );
                      Navigator.push(
                        context,
                        FadeRoute(page: BrowseByAllProvider()),
                      );
                    },
                    child: ShowAllCard(),
                  );
                }
                return Container(
                  margin: EdgeInsets.only(left: 16).r,
                  height: 250.w,
                  width: 245.w,
                  decoration: BoxDecoration(
                    color: AppColors.appBarBackground,
                    border: Border.all(color: AppColors.grey08),
                    borderRadius: BorderRadius.circular(12).w,
                  ),
                  child: Stack(
                    children: [
                      Column(children: [
                        Container(
                            height: 72.w,
                            decoration: BoxDecoration(
                              color: AppColors.providerColors()[index],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ).r,
                            ),
                            child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                color: AppColors.greys60,
                                imageUrl: ApiUrl.baseUrl +
                                    '/assets/mobile_app/assets/provider_background.png',
                                placeholder: (context, url) => Container(
                                        decoration: BoxDecoration(
                                      color: AppColors.providerColors()[index],
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ).r,
                                    )),
                                errorWidget: (context, url, error) => Container(
                                        decoration: BoxDecoration(
                                      color: AppColors.providerColors()[index],
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ).r,
                                    )))),
                        Padding(
                          padding: const EdgeInsets.only(
                                  left: 20.0, right: 20, top: 52)
                              .r,
                          child: SizedBox(
                            height: 90.w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.topProviderList[index].name ?? '',
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                        InkWell(
                            onTap: () {
                              HomeTelemetryService
                                  .generateInteractTelemetryData(
                                widget.topProviderList[index].orgId ?? '',
                                subType: TelemetrySubType.trainingInstitutes,
                                clickId: TelemetryIdentifier.cardContent,
                              );
                              Navigator.push(
                                context,
                                FadeRoute(
                                    page: AtiCtiMicroSitesScreen(
                                  providerName:
                                      widget.topProviderList[index].name,
                                  orgId: widget.topProviderList[index].orgId,
                                )),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.mViewProvider,
                                  style: GoogleFonts.lato(
                                      color: AppColors.darkBlue,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400),
                                ),
                                Icon(Icons.chevron_right)
                              ],
                            )),
                        SizedBox(
                          height: 16.w,
                        )
                      ]),
                      Positioned(
                        top: 24.w,
                        left: 74.w,
                        child: Container(
                          height: 97.w,
                          width: 97.w,
                          //  padding: EdgeInsets.all(2).r,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey08),
                            color: AppColors.appBarBackground,
                            borderRadius: BorderRadius.circular(50).r,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.grey.withValues(alpha: 0.5),
                                spreadRadius: 1.w,
                                blurRadius: 3.w,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: (widget.topProviderList[index].logoUrl != null)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50).r,
                                  child: Image.network(
                                    widget.topProviderList[index].logoUrl!,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Container(
                                  height: 97.w,
                                  width: 97.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.networkBg[randomNumber],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      Helper.getInitialsNew(
                                          widget.topProviderList[index].name ??
                                              ''),
                                      style: GoogleFonts.lato(
                                          color: AppColors.avatarText,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.0.sp),
                                    ),
                                  ),
                                ),
                        ),
                      )
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }
}
