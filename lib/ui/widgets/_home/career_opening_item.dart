import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_moment/simple_moment.dart';
import './../../../models/_models/career_opening_model.dart';
import '../../../constants/index.dart';
import './../../../util/helper.dart';

class CareerOpeningItem extends StatelessWidget {
  final CareerOpening careerOpening;
  final dateNow = Moment.now();

  CareerOpeningItem(this.careerOpening);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        // onTap: () => Navigator.push(
        //       context,
        //       FadeRoute(page: ComingSoonScreen()),
        //     ),
        child: Card(
      color: AppColors.appBarBackground,
      margin: const EdgeInsets.only(left: 10).r,
      child: new Container(
        width: 300.0.w,
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey08),
            borderRadius: BorderRadius.all(Radius.circular(4)).r),
        // height: double.infinity,
        // padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
                width: double.infinity.w,
                padding: EdgeInsets.only(left: 16, top: 16, right: 16).r,
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 32.w,
                      width: 32.w,
                      decoration: BoxDecoration(
                        color: AppColors.avatarRed,
                        borderRadius:
                            BorderRadius.all(const Radius.circular(4.0)).r,
                      ),
                      child: Center(
                        child: Text(
                          Helper.getInitials(careerOpening.title),
                          style: TextStyle(color: AppColors.avatarText),
                        ),
                      ),
                    ),
                    Container(
                        // alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(left: 10).r,
                        width: 220.w,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                careerOpening.title,
                                maxLines: 2,
                                style: TextStyle(
                                  color: AppColors.greys87,
                                  fontSize: 12.0.sp,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5).r,
                                child: Text(
                                  (dateNow.from(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              careerOpening.timeStamp)))
                                      .toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.sp,
                                      ),
                                ),
                              )
                            ])),
                  ],
                )),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16).r,
              child: Text(
                careerOpening.description,
                maxLines: 2,
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      height: 1.429.w,
                    ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
