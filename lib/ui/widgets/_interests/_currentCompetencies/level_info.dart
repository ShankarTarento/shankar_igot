import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/_constants/color_constants.dart';

class LevelInfo extends StatelessWidget {
  final levelDetails;
  const LevelInfo({Key? key, this.levelDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(16).r,
      content: SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < levelDetails.length; i++)
              (Container(
                margin: const EdgeInsets.fromLTRB(1, 1, 1, 8).r,
                decoration: BoxDecoration(
                    border: Border.all(
                  color: AppColors.grey16,
                )),
                child: ExpansionTile(
                  expandedAlignment: Alignment.topLeft,
                  collapsedBackgroundColor: AppColors.appBarBackground,
                  backgroundColor: AppColors.appBarBackground,
                  childrenPadding:
                      EdgeInsets.only(bottom: 16, left: 16, right: 16).r,
                  onExpansionChanged: (value) async {},
                  tilePadding: EdgeInsets.only(left: 16, right: 16).r,
                  title: Text(
                    levelDetails[i]['level'],
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          height: 1.5.w,
                          letterSpacing: 0.25.r,
                        ),
                  ),
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        levelDetails[i]['name'],
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              height: 1.5.w,
                              letterSpacing: 0.25.r,
                            ),
                      ),
                    ),
                    SizedBox(
                      height: 16.w,
                    ),
                    Text(
                      levelDetails[i]['description'],
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            height: 1.5.w,
                            letterSpacing: 0.25.r,
                          ),
                    ),
                  ],
                ),
              ))
          ],
        ),
      ),
    );
  }
}
