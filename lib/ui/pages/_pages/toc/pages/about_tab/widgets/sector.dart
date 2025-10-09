import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../constants/index.dart';
import '../../../../../../../models/_models/gyaan_sector_model.dart';

class Sector extends StatefulWidget {
  final List<SectorDetails> sectorDetails;

  const Sector({super.key, required this.sectorDetails});

  @override
  State<Sector> createState() => _SectorState();
}

class _SectorState extends State<Sector> {
  int selectedIndex = 0;
  List<Map<String, dynamic>> sectorMapList = [];
  @override
  void initState() {
    super.initState();
    fetchSectorMapList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.mStaticSectors,
              style: Theme.of(context).textTheme.titleLarge),
          SizedBox(
            height: 16.w,
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 32.w,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sectorMapList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    selectedIndex = index;
                    setState(() {});
                  },
                  child: Container(
                      margin: EdgeInsets.only(right: 16).w,
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 16).r,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedIndex == index
                              ? AppColors.darkBlue
                              : Color.fromRGBO(0, 0, 0, 1)
                                  .withValues(alpha: 0.08),
                          width: 1.w,
                        ),
                        borderRadius: BorderRadius.circular(18).w,
                      ),
                      child: Center(
                        child: Text(sectorMapList[index]['sector'],
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                    color: selectedIndex == index
                                        ? AppColors.darkBlue
                                        : AppColors.greys60,
                                    fontWeight: selectedIndex == index
                                        ? FontWeight.w700
                                        : FontWeight.w400)),
                      )),
                ),
              ),
            ),
            sectorMapList[selectedIndex]['subSector'].isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(
                            sectorMapList[selectedIndex]['subSector'].length,
                            (index) => Container(
                                width: 340.w,
                                margin: EdgeInsets.only(top: 15, right: 15).r,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8).r,
                                    color: AppColors.orangeShade1),
                                child: Container(
                                  width: 1.sw,
                                  margin: EdgeInsets.only(
                                    top: 4,
                                  ).r,
                                  padding: EdgeInsets.only(
                                          top: 8, bottom: 16, left: 6, right: 6)
                                      .r,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8).r,
                                      border: Border.all(
                                          color: AppColors.greys
                                              .withValues(alpha: 0.04)),
                                      color: AppColors.appBarBackground),
                                  child: Text(
                                    sectorMapList[selectedIndex]['subSector']
                                        [index],
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(color: AppColors.greys60),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )))),
                  )
                : Center()
          ])
        ]);
  }

  void fetchSectorMapList() {
    widget.sectorDetails.forEach((item) {
      Map<String, dynamic>? sectorMap = sectorMapList
          .cast<Map<String, dynamic>?>()
          .firstWhere(
              (element) =>
                  element != null && element['sector'] == item.sectorName,
              orElse: () => null);
      if (sectorMap == null) {
        sectorMapList.add({
          'sector': item.sectorName,
          'subSector': item.subSectorName.isNotEmpty ? [item.subSectorName] : []
        });
      } else {
        sectorMap['subSector'].add(item.subSectorName);
      }
    });
  }
}
