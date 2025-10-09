import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_sector_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/view_all_page/view_all_pages.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/services/gyaan_karmayogi_services.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SectorsViewV2 extends StatefulWidget {
  String? selectedSector;
  Function(String?) getSelectedSector;

  SectorsViewV2({
    required this.selectedSector,
    required this.getSelectedSector,
    Key? key,
  }) : super(key: key);

  @override
  State<SectorsViewV2> createState() => _SectorsViewV2State();
}

class _SectorsViewV2State extends State<SectorsViewV2> {
  List<Color> sectorColors = [];
  List<GyaanKarmayogiSector> sectors = [];
  @override
  void initState() {
    sectorColors = AppColors.gyaanKarmayogiSubSectorColors;
    getSectors();
    super.initState();
  }

  getSectors() async {
    sectors =
        await Provider.of<GyaanKarmayogiServicesV2>(context, listen: false)
            .getAvailableSectorWithIcon();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0).r,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.mStaticSectors,
                    style: GoogleFonts.lato(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          FadeRoute(
                              page: ViewAllScreenV2(
                            index: 0,
                          )));
                    },
                    child: Text(
                      AppLocalizations.of(context)!.mStaticViewAll,
                      style: GoogleFonts.lato(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.darkBlue,
                  )
                ],
              ),
              InkWell(
                onTap: () {
                  widget.selectedSector = null;
                  widget.getSelectedSector(null);
                  setState(() {});
                },
                child: Container(
                  margin: EdgeInsets.only(top: 16, bottom: 16).r,
                  width: 1.sw,
                  height: 70.w,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1.5.w,
                        color: widget.selectedSector == null
                            ? AppColors.primaryOne
                            : Colors.transparent),
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(12).r,
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.mAllSectors,
                      style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.appBarBackground),
                    ),
                  ),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2 / 0.8,
                children: List.generate(
                  sectors.length > 8 ? 8 : sectors.length,
                  (index) => InkWell(
                    onTap: () async {
                      widget.selectedSector = sectors[index].name;
                      widget.getSelectedSector(sectors[index].name);

                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.all(12).r,
                      height: 70.w,
                      width: 1.sw / 2.4,
                      decoration: BoxDecoration(
                          color: sectorColors[index],
                          borderRadius: BorderRadius.circular(12).r,
                          border: Border.all(
                              width: 1.5.w,
                              color: widget.selectedSector != null &&
                                      widget.selectedSector!.toLowerCase() ==
                                          sectors[index].name.toLowerCase()
                                  ? AppColors.primaryOne
                                  : Colors.transparent)),
                      child: Row(
                        children: [
                          sectors[index].iconUrl != null
                              ? SizedBox(
                                  height: 24.w,
                                  width: 24.w,
                                  child: ImageWidget(
                                    imageUrl: Helper.convertImageUrl(
                                        sectors[index].iconUrl!),
                                    height: 24.w,
                                    width: 24.w,
                                  ),
                                )
                              : SizedBox(),
                          SizedBox(
                            width: 5.w,
                          ),
                          SizedBox(
                            width: 1.sw / 3.4,
                            child: Text(
                              Helper.capitalize(sectors[index].name),
                              style: GoogleFonts.lato(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.greys,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
