import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BulletList extends StatelessWidget {
  final List<String> strings;
  final bool hasSubBullets;

  BulletList(this.strings, {this.hasSubBullets = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: strings.map((str) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasSubBullets ? '-' : '\u2022',
                style: TextStyle(
                  fontSize: 20.sp,
                  height: 1.25.w,
                ),
              ),
              SizedBox(
                width: 5.w,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    str,
                    textAlign: TextAlign.left,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          height: 1.5.w,
                          letterSpacing: 0.25.r,
                        ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
