import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:karmayogi_mobile/ui/learn_hub/repository/learn_hub_repository.dart';
import 'package:karmayogi_mobile/ui/learn_hub/screens/your_learning_screen/widget/your_learning_card/your_learning_card.dart';
import 'package:karmayogi_mobile/ui/learn_hub/screens/your_learning_screen/widget/your_learning_card/your_learning_card_skeleton.dart';
import '../../../../models/_models/course_model.dart';

class YourLearningScreen extends StatefulWidget {
  const YourLearningScreen({Key? key}) : super(key: key);

  @override
  _YourLearningScreenState createState() => _YourLearningScreenState();
}

class _YourLearningScreenState extends State<YourLearningScreen> {
  late Future<List<Course>> _continueLearningCourses;

  @override
  void initState() {
    super.initState();
    _continueLearningCourses =
        LearnHubRepository().getContinueLearningCourses();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: _continueLearningCourses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingList();
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return _buildCourseList(snapshot.data!);
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildLoadingList() {
    return AnimationLimiter(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 6,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8).r,
                  child: const YourLearningCardSkeleton(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseList(List<Course> courses) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AnimationLimiter(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8).r,
                        child: YourLearningCard(course: courses[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 200.h),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final localization = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 125).r,
          child: SvgPicture.asset(
            'assets/img/empty_search.svg',
            width: 0.2.sw,
            height: 0.2.sh,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16).r,
          child: Text(
            localization.mLearnNotStartedAnyCourse,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  height: 1.5.w,
                  letterSpacing: 0.25,
                ),
          ),
        ),
        SizedBox(
          width: 0.75.sw,
          child: Padding(
            padding: const EdgeInsets.only(top: 20).r,
            child: Text(
              localization.mLearnEnrollGetStarted,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    height: 1.5.w,
                    letterSpacing: 0.25,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ),
      ],
    );
  }
}
