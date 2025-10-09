import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class TaggedCompetency extends StatefulWidget {
  final yourTaggedCompetency;
  final courseCompetencies;
  const TaggedCompetency({this.yourTaggedCompetency, this.courseCompetencies});

  @override
  _TaggedCompetencyState createState() => _TaggedCompetencyState();
}

class _TaggedCompetencyState extends State<TaggedCompetency> {
  // int _courseCompetencyLevel;

  @override
  void initState() {
    super.initState();
    // findCourseCompetencyLevel(widget.yourTaggedCompetency.id);
  }

  // void findCourseCompetencyLevel(String id) {
  //   if (widget.courseCompetencies != null) {
  //     for (var i = 0; i < widget.courseCompetencies.length; i++) {
  //       if (widget.courseCompetencies[i].id == id) {
  //         setState(() {
  //           _courseCompetencyLevel = int.parse(widget
  //               .courseCompetencies[i].courseCompetencyLevel
  //               .replaceAll('Level ', ''));
  //         });
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      color: AppColors.appBarBackground,
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5).r,
      padding: EdgeInsets.all(16).r,
      // decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.zero)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 0.85.sw,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 5).r,
                            child: Text(
                              widget.yourTaggedCompetency.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(
                                    fontSize: 16.sp,
                                  ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 16.0).r,
                              child: Text(
                                'Competency type: ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, 16, 0, 0).r,
                              child: Text(
                                widget.yourTaggedCompetency.competencyType,
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 16.0).r,
                              child: Text(
                                'Tagged to course: ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 16, 0, 0).r,
                              child: Text(
                                'Tagged',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 16, 0, 0).r,
                              child: Row(
                                children: [
                                  widget.yourTaggedCompetency
                                              .courseCompetencyLevel !=
                                          null
                                      ? (Row(
                                          children: [
                                            for (var i = 0;
                                                i <
                                                    int.parse(widget
                                                        .yourTaggedCompetency
                                                        .courseCompetencyLevel
                                                        .replaceAll(
                                                            'Level ', ''));
                                                i++)
                                              (Padding(
                                                padding: const EdgeInsets.only(
                                                        left: 3)
                                                    .r,
                                                child: Container(
                                                  height: 6.w,
                                                  width: 12.w,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors.primaryThree,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(1.0).r,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                            for (var i = 0;
                                                i <
                                                    5 -
                                                        int.parse(widget
                                                            .yourTaggedCompetency
                                                            .courseCompetencyLevel
                                                            .replaceAll(
                                                                'Level ', ''));
                                                i++)
                                              (Padding(
                                                padding: const EdgeInsets.only(
                                                        left: 3)
                                                    .r,
                                                child: Container(
                                                  height: 6.w,
                                                  width: 12.w,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.grey08,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(1.0).r,
                                                    ),
                                                  ),
                                                ),
                                              ))
                                          ],
                                        ))
                                      : Row(
                                          children: [
                                            for (var i = 0; i < 5; i++)
                                              (Padding(
                                                padding: const EdgeInsets.only(
                                                        left: 3)
                                                    .r,
                                                child: Container(
                                                  height: 6.w,
                                                  width: 12.w,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.grey08,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(1.0).r,
                                                    ),
                                                  ),
                                                ),
                                              ))
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 16.0).r,
                              child: Text(
                                'Your level: ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),

                            //Not coming the value for Certified from the backend

                            // Padding(
                            //   padding: EdgeInsets.fromLTRB(16, 16, 0, 0),
                            //   child: Text(
                            //     'Certified',
                            //     style: GoogleFonts.lato(
                            //         color: AppColors.greys87,
                            //         fontSize: 14.0,
                            //         fontWeight: FontWeight.w400),
                            //   ),
                            // ),
                            widget.yourTaggedCompetency.selfAttestedLevel !=
                                    null
                                ? Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(16, 16, 0, 0).r,
                                    child: Row(
                                      children: [
                                        for (var i = 0;
                                            i <
                                                widget.yourTaggedCompetency
                                                    .selfAttestedLevel;
                                            i++)
                                          (Padding(
                                            padding:
                                                const EdgeInsets.only(left: 3)
                                                    .r,
                                            child: Container(
                                              height: 6.w,
                                              width: 12.w,
                                              decoration: BoxDecoration(
                                                color: AppColors.positiveLight,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(1.0).r,
                                                ),
                                              ),
                                            ),
                                          )),
                                        for (var i = 0;
                                            i <
                                                5 -
                                                    widget.yourTaggedCompetency
                                                        .selfAttestedLevel;
                                            i++)
                                          (Padding(
                                            padding:
                                                const EdgeInsets.only(left: 3)
                                                    .r,
                                            child: Container(
                                              height: 6.w,
                                              width: 12.w,
                                              decoration: BoxDecoration(
                                                color: AppColors.grey08,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(1.0).r,
                                                ),
                                              ),
                                            ),
                                          ))
                                      ],
                                    ),
                                  )
                                : Center(),
                          ],
                        ),
                        SizedBox(
                          height: 8.w,
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
