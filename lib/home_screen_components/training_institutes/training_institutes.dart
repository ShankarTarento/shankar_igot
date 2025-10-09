import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/home_screen_components/models/learn_tab_model.dart';
import 'package:karmayogi_mobile/home_screen_components/training_institutes/training_institutes_service.dart';
import 'package:karmayogi_mobile/models/_models/provider_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/home_page/providers/providers.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrainingInstitutes extends StatefulWidget {
  final TabItems tabItemData;
  const TrainingInstitutes({super.key, required this.tabItemData});

  @override
  State<TrainingInstitutes> createState() => _TrainingInstitutesState();
}

class _TrainingInstitutesState extends State<TrainingInstitutes> {
  @override
  void initState() {
    providerFuture = _getFeaturedProviders();

    super.initState();
  }

  late Future<List<ProviderCardModel>> providerFuture;
  Future<List<ProviderCardModel>> _getFeaturedProviders() async {
    return TrainingInstitutesService.getProviders(
        stripData: widget.tabItemData.courseStripData!);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0).r,
      child: FutureBuilder(
          future: providerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: CourseCardSkeletonPage(),
              );
            }
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return Padding(
                padding: EdgeInsets.only(bottom: 24.r),
                child: Providers(
                  topProviderList: snapshot.data!,
                ),
              );
            }
            return SizedBox(
              height: 290.w,
              child: Center(
                child: AnimationConfiguration.staggeredList(
                  position: 0,
                  duration: const Duration(milliseconds: 800),
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.all(16).r,
                      child: NoDataWidget(
                        message:
                            AppLocalizations.of(context)!.mNoResourcesFound,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
