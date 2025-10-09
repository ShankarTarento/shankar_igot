import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_sector_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SectorSubsectorView extends StatefulWidget {
  final List<SectorDetails> sectorDetails;
  const SectorSubsectorView({super.key, required this.sectorDetails});

  @override
  State<SectorSubsectorView> createState() => _SectorSubsectorViewState();
}

class _SectorSubsectorViewState extends State<SectorSubsectorView> {
  late Map<String, List<String>> sectorsWithSubsectors;
  String? selectedSector;
  List<String> selectedSubSectors = [];

  @override
  void initState() {
    super.initState();

    sectorsWithSubsectors = _mapSectorsWithSubsectors(widget.sectorDetails);
    if (sectorsWithSubsectors.isNotEmpty) {
      selectedSector = sectorsWithSubsectors.keys.first;
      selectedSubSectors = sectorsWithSubsectors[selectedSector] ?? [];
    }
  }

  Map<String, List<String>> _mapSectorsWithSubsectors(
      List<SectorDetails> list) {
    final Map<String, Set<String>> grouped = {};

    for (final item in list) {
      if (item.sectorName.trim().isEmpty) continue;
      grouped.putIfAbsent(item.sectorName, () => {});
      if (item.subSectorName.trim().isNotEmpty == true) {
        grouped[item.sectorName]!.add(item.subSectorName.trim());
      }
    }

    return grouped.map((k, v) => MapEntry(k, v.toList()));
  }

  @override
  Widget build(BuildContext context) {
    return sectorsWithSubsectors.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(left: 16.0).r,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.mStaticSectors,
                  style: GoogleFonts.lato(
                      fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12.w),
                _buildSectorPills(),
                SizedBox(height: 12.w),
                _buildSubSectorCards(),
              ],
            ),
          )
        : SizedBox();
  }

  Widget _buildSectorPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sectorsWithSubsectors.keys.map((sectorName) {
          final isSelected = sectorName == selectedSector;
          return InkWell(
            onTap: () {
              setState(() {
                selectedSector = sectorName;
                selectedSubSectors = sectorsWithSubsectors[sectorName] ?? [];
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.r),
                color: Colors.transparent,
                border: Border.all(
                    color: isSelected ? AppColors.darkBlue : AppColors.greys60,
                    width: 1.w),
              ),
              child: Text(
                sectorName,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.darkBlue : AppColors.greys60,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubSectorCards() {
    if (selectedSubSectors.isEmpty) return const SizedBox();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: selectedSubSectors.map((subSector) {
          return Container(
            width: 0.7.sw,
            margin: EdgeInsets.only(right: 12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.primaryOne,
            ),
            child: Container(
              margin: EdgeInsets.only(top: 4.w),
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12).r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.appBarBackground,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subSector,
                    style: GoogleFonts.lato(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.r),
                      border: Border.all(color: AppColors.darkBlue, width: 1.w),
                    ),
                    child: Text(
                      subSector,
                      style: GoogleFonts.lato(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.w),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
