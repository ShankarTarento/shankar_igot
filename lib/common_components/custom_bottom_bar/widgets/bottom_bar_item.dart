import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';

class BottomBarItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isActive;
  const BottomBarItem({
    super.key,
    required this.title,
    required this.imageUrl,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 8.w),
        Stack(
          children: [
            ImageWidget(
              height: 24.w,
              width: 24.w,
              boxFit: BoxFit.contain,
              imageUrl: imageUrl,
            ),
            isActive
                ? Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : SizedBox(),
          ],
        ),
        SizedBox(height: 2.w),
        Text(
          title,
          style: GoogleFonts.lato(fontSize: 10.sp, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
