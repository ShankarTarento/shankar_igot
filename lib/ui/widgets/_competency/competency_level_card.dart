import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class CompetencyLevelCard extends StatefulWidget {
  // const CompetencyLevelCard({ Key? key }) : super(key: key);
  final int index;
  final ValueChanged<Map> selectLevel;
  final ValueChanged<bool> checkSelectStatus;
  final int? selectedLevel;
  final levelDetails;
  CompetencyLevelCard(
      {required this.index,
      required this.selectLevel,
      this.selectedLevel,
      this.levelDetails,
      required this.checkSelectStatus});

  @override
  _CompetencyLevelCardState createState() => _CompetencyLevelCardState();
}

class _CompetencyLevelCardState extends State<CompetencyLevelCard> {
  // int _selected;

  @override
  Widget build(BuildContext context) {
    // print('Radio: ' + widget.selectedLevel.toString());
    return Container(
      width: 75.w,
      color: AppColors.appBarBackground,
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(16).r,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Radio(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity:
                              VisualDensity(horizontal: -4, vertical: 0),
                          value: widget.index,
                          groupValue: widget.selectedLevel,
                          onChanged: (value) {
                            setState(() {
                              widget.checkSelectStatus(true);
                              widget.selectLevel({
                                'levelValue': value,
                                'id': widget.levelDetails['id'],
                                'level': widget.levelDetails['level'],
                                'name': widget.levelDetails['name']
                              });
                            });
                          }),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4).r,
                        child: Container(
                          width: 1.sw / 4,
                          child: Text(
                            widget.levelDetails['level'],
                            // "Name of the competency",

                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.sp,
                                ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1.sw / 3,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4).r,
                          child: Text(
                            widget.levelDetails['name'],
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  VerticalDivider(
                    thickness: 1,
                    width: 20.w,
                    color: AppColors.grey16,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        width: 1.sw / 2,
                        child: Text(
                          widget.levelDetails[
                              'description'], // "Design and set up interface and interconnections from or among sensors, through a network, to a main location, to enable transmission of information",

                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                              ),
                        ),
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     // Navigator.push(
                      //     //   context,
                      //     //   FadeRoute(
                      //     //       page: CoursesInCompetency(
                      //     //           browseCompetencyCardModel)),
                      //     // );
                      //   },
                      //   child: Text(
                      //     "Read more",
                      //     style: GoogleFonts.lato(
                      //       color: AppColors.primaryThree,
                      //       fontWeight: FontWeight.w700,
                      //       fontSize: 14,
                      //     ),
                      //   ),
                      // ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
