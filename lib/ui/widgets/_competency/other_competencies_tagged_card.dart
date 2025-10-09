import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/models/_models/browse_v5_competency_card_model.dart';

import '../../../constants/index.dart';

class OtherTaggedCompetency extends StatelessWidget {
  final BrowseV5CompetencyCardModel otherTaggedCompetencies;
  final bool needTaggedStatus;
  const OtherTaggedCompetency(this.otherTaggedCompetencies,
      {this.needTaggedStatus = false});

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
                        CompetencyItemWIdget(
                          title: 'Sub theme',
                          subTitle: otherTaggedCompetencies.competencySubTheme!,
                        ),
                        CompetencyItemWIdget(
                          title: 'Theme',
                          subTitle: otherTaggedCompetencies.competencyTheme!,
                        ),
                        CompetencyItemWIdget(
                          title: 'Area',
                          subTitle: otherTaggedCompetencies.competencyArea!,
                        ),
                        // needTaggedStatus
                        //     ? Row(
                        //         children: [
                        //           Padding(
                        //             padding: EdgeInsets.only(top: 16.0),
                        //             child: Text(
                        //               'Tagged to course: ',
                        //               style: GoogleFonts.lato(
                        //                   color: AppColors.greys87,
                        //                   fontSize: 14.0,
                        //                   fontWeight: FontWeight.w400),
                        //             ),
                        //           ),
                        //           Padding(
                        //             padding: EdgeInsets.fromLTRB(16, 16, 0, 0),
                        //             child: Text(
                        //               'Tagged',
                        //               style: GoogleFonts.lato(
                        //                   color: AppColors.greys87,
                        //                   fontSize: 14.0,
                        //                   fontWeight: FontWeight.w400),
                        //             ),
                        //           ),
                        //           // Padding(
                        //           //   padding: EdgeInsets.fromLTRB(16, 16, 0, 0),
                        //           //   child: Row(
                        //           //     children: [
                        //           //       (otherTaggedCompetencies
                        //           //                       .courseCompetencyLevel !=
                        //           //                   null &&
                        //           //               otherTaggedCompetencies
                        //           //                       .courseCompetencyLevel !=
                        //           //                   '')
                        //           //           ? (Row(
                        //           //               children: [
                        //           //                 for (var i = 0;
                        //           //                     i <
                        //           //                         int.parse(
                        //           //                             otherTaggedCompetencies
                        //           //                                 .courseCompetencyLevel
                        //           //                                 .replaceAll(
                        //           //                                     'Level ',
                        //           //                                     ''));
                        //           //                     i++)
                        //           //                   (Padding(
                        //           //                     padding:
                        //           //                         const EdgeInsets.only(
                        //           //                             left: 3),
                        //           //                     child: Container(
                        //           //                       height: 6,
                        //           //                       width: 12,
                        //           //                       decoration:
                        //           //                           BoxDecoration(
                        //           //                         color: AppColors
                        //           //                             .primaryThree,
                        //           //                         borderRadius:
                        //           //                             BorderRadius.all(
                        //           //                           Radius.circular(
                        //           //                               1.0),
                        //           //                         ),
                        //           //                       ),
                        //           //                     ),
                        //           //                   )),
                        //           //                 for (var i = 0;
                        //           //                     i <
                        //           //                         5 -
                        //           //                             int.parse(otherTaggedCompetencies
                        //           //                                 .courseCompetencyLevel
                        //           //                                 .replaceAll(
                        //           //                                     'Level ',
                        //           //                                     ''));
                        //           //                     i++)
                        //           //                   (Padding(
                        //           //                     padding:
                        //           //                         const EdgeInsets.only(
                        //           //                             left: 3),
                        //           //                     child: Container(
                        //           //                       height: 6,
                        //           //                       width: 12,
                        //           //                       decoration:
                        //           //                           BoxDecoration(
                        //           //                         color:
                        //           //                             AppColors.grey08,
                        //           //                         borderRadius:
                        //           //                             BorderRadius.all(
                        //           //                           Radius.circular(
                        //           //                               1.0),
                        //           //                         ),
                        //           //                       ),
                        //           //                     ),
                        //           //                   ))
                        //           //               ],
                        //           //             ))
                        //           //           : Row(
                        //           //               children: [
                        //           //                 for (var i = 0; i < 5; i++)
                        //           //                   (Padding(
                        //           //                     padding:
                        //           //                         const EdgeInsets.only(
                        //           //                             left: 3),
                        //           //                     child: Container(
                        //           //                       height: 6,
                        //           //                       width: 12,
                        //           //                       decoration:
                        //           //                           BoxDecoration(
                        //           //                         color:
                        //           //                             AppColors.grey08,
                        //           //                         borderRadius:
                        //           //                             BorderRadius.all(
                        //           //                           Radius.circular(
                        //           //                               1.0),
                        //           //                         ),
                        //           //                       ),
                        //           //                     ),
                        //           //                   ))
                        //           //               ],
                        //           //             ),
                        //           //     ],
                        //           //   ),
                        //           // ),
                        //         ],
                        //       )
                        //     : Center(),
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

class CompetencyItemWIdget extends StatelessWidget {
  const CompetencyItemWIdget({
    Key? key,
    required this.title,
    required this.subTitle,
  }) : super(key: key);

  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60.w,
          child: Text(
            '$title: ',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8, 4, 0, 4).r,
          child: Container(
            width: 0.65.sw,
            child: Text(
              subTitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
