import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/widgets/primary_category_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyLearningCardHeader extends StatefulWidget {
  final Course course;
  const MyLearningCardHeader({super.key, required this.course});

  @override
  State<MyLearningCardHeader> createState() => _MyLearningCardHeaderState();
}

class _MyLearningCardHeaderState extends State<MyLearningCardHeader> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrimaryCategoryWidget(
            contentType: widget.course.courseCategory, addedMargin: true),
        SizedBox(height: 6.w),
        Row(
          children: [
            widget.course.appIcon != ''
                ? ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(12)).r,
                    child: ImageWidget(
                      imageUrl: widget.course.appIcon,
                      width: 107.w,
                      height: 80.h,
                    ))
                : Image.asset(
                    'assets/img/image_placeholder.jpg',
                    width: 107.w,
                    height: 72.w,
                    fit: BoxFit.fitWidth,
                  ),
            Padding(
              padding: const EdgeInsets.only(left: 16).r,
              child: SizedBox(
                width: 0.53.sw,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course.name,
                      style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        letterSpacing: 0.25,
                      ),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 8).r,
                          padding: EdgeInsets.all(3).r,
                          decoration: BoxDecoration(
                              color: AppColors.appBarBackground,
                              border:
                                  Border.all(color: AppColors.grey16, width: 1),
                              borderRadius:
                                  BorderRadius.all(const Radius.circular(4.0))
                                      .r),
                          child: Image.network(
                            widget.course.creatorLogo,
                            height: 16.w,
                            width: 16.w,
                            fit: BoxFit.cover,
                            cacheWidth: 16,
                            cacheHeight: 16,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/img/igot_creator_icon.png',
                              height: 16.w,
                              width: 16.w,
                            ),
                          ),
                        ),
                        Container(
                          width: 0.45.sw,
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(left: 8, right: 8, top: 4).r,
                          child: Text(
                            widget.course.source != ''
                                ? '${AppLocalizations.of(context)!.mCommonBy} ' +
                                    widget.course.source
                                : '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lato(
                              color: AppColors.greys60,
                              fontWeight: FontWeight.w400,
                              fontSize: 12.0.sp,
                              height: 1.5.w,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
