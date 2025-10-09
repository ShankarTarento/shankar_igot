import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/widget/gyaan_karmayogi_header.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/widget/sectors_filter_v2.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/widget/sectors_view.dart';

import '../../../../../constants/_constants/color_constants.dart';

class TopSection extends StatefulWidget {
  final Function(Map<String, dynamic>) filterData;

  final Function() navigateToViewAll;

  const TopSection({
    super.key,
    required this.filterData,
    required this.navigateToViewAll,
  });

  @override
  State<TopSection> createState() => _TopSectionState();
}

class _TopSectionState extends State<TopSection> {
  Map filter = {
    'sector': null,
    'subSector': null,
    'category': null,
    'query': null,
  };
  String? selectedSectorValue;
  String? selectedSector;
  String? selectedSubSector;
  String? selectedCategory;
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GyaanKarmayogiHeaderV2(
          searchController: searchController,
          searchFunction: (value) {
            selectedCategory = null;
            selectedSector = null;
            selectedSubSector = null;
            selectedSectorValue = null;
            widget.filterData({
              'sector': null,
              'subSector': null,
              'category': null,
              'query': value,
            });
            setState(() {});
          },
        ),
        SectorsViewV2(
          selectedSector: selectedSectorValue,
          getSelectedSector: (value) {
            selectedSectorValue = value;
            selectedCategory = null;
            selectedSector = null;
            selectedSubSector = null;
            widget.filterData({
              'sector': value,
              'subSector': null,
              'category': null,
              'query': null,
            });
            searchController.clear();
            setState(() {});
          },
        ),
        Container(
          color: AppColors.yellowBckground,
          child: SectorFilterV2(
            navigateToViewAll: widget.navigateToViewAll,
            selectedCategory: selectedCategory,
            selectedSector: selectedSector,
            selectedSubSector: selectedSubSector,
            filterValues: (value) {
              selectedSectorValue = null;
              selectedSector = value['sector'];
              selectedSubSector = value['subSector'];
              selectedCategory = value['category'];
              widget.filterData({
                'sector': value['sector'],
                'subSector': value['subSector'],
                'category': value['category'],
                'query': null,
              });
              searchController.clear();
              setState(() {});
            },
          ),
        ),
      ],
    );
  }
}
