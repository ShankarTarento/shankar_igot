import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/home_screen_components/models/learn_tab_model.dart';
import 'package:karmayogi_mobile/home_screen_components/providers_external_courses/provider_service.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';

import 'package:karmayogi_mobile/ui/pages/_pages/home_page/content_providers/widgets/market_place_list.dart';

class ProvidersExternalCourses extends StatefulWidget {
  final TabItems tabItemData;
  const ProvidersExternalCourses({super.key, required this.tabItemData});

  @override
  State<ProvidersExternalCourses> createState() =>
      _ProvidersExternalCoursesState();
}

class _ProvidersExternalCoursesState extends State<ProvidersExternalCourses> {
  @override
  void initState() {
    externalCourseFuture = ProviderService.getExternalCourses(
        stripData: widget.tabItemData.courseStripData!);
    super.initState();
  }

  late Future<List<Course>> externalCourseFuture;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16).r,
      child: MarketPlaceList(
        externalCourses: externalCourseFuture,
      ),
    );
  }
}
