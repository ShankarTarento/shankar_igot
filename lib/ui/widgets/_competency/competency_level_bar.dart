import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './../../../constants/index.dart';

class CompetencyLevelBar extends StatelessWidget {
  final String text;
  final bool isWorkOrder;
  final bool isEvaluation;
  final bool isGap;

  CompetencyLevelBar(
      {required this.text,
      this.isWorkOrder = false,
      this.isEvaluation = false,
      this.isGap = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16).r,
      child: Container(
        width: double.infinity.w,
        decoration: BoxDecoration(
          color: AppColors.appBarBackground,
          borderRadius: BorderRadius.all(
            Radius.circular(4.0).r,
          ),
        ),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 20, 12).r,
            child: Row(
              children: [
                isWorkOrder == true
                    ? Container(
                        height: 8.w,
                        width: 20.w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryThree,
                          borderRadius: BorderRadius.all(
                            Radius.circular(3.0).r,
                          ),
                        ),
                      )
                    : isEvaluation
                        ? Container(
                            height: 8.w,
                            width: 20.w,
                            decoration: BoxDecoration(
                              color: AppColors.positiveLight,
                              borderRadius: BorderRadius.all(
                                Radius.circular(3.0).r,
                              ),
                            ),
                          )
                        : isGap == true
                            ? Container(
                                height: 8.w,
                                width: 20.w,
                                decoration: BoxDecoration(
                                    color: AppColors.appBarBackground,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(3.0).r,
                                    ),
                                    border: Border.all(
                                        color: Colors.redAccent, width: 1.5.w)),
                              )
                            : Container(
                                height: 8.w,
                                width: 20.w,
                                decoration: BoxDecoration(
                                  color: AppColors.grey08,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3.0).r,
                                  ),
                                ),
                              ),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.only(left: 12, bottom: 5).r,
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          height: 1.5.w,
                          decoration: TextDecoration.none,
                        ),
                  ),
                )),
              ],
            )),
      ),
    );
  }
}
