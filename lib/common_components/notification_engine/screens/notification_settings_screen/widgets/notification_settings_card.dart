import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class NotificationSettingsCard extends StatefulWidget {
  final String title;
  final String description;
  final bool isEnabled;
  final Function(bool) onChanged;
  const NotificationSettingsCard({
    super.key,
    required this.title,
    required this.description,
    this.isEnabled = false,
    required this.onChanged,
  });

  @override
  State<NotificationSettingsCard> createState() => _NotificationSettingsCard();
}

class _NotificationSettingsCard extends State<NotificationSettingsCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.circular(8).r,
      ),
      padding: EdgeInsets.all(16).r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.lato(
                    fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6.h),
              Text(
                widget.description,
                style: GoogleFonts.lato(
                    fontSize: 14.sp, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          Switch(
              value: widget.isEnabled,
              activeColor: AppColors.darkBlue,
              onChanged: (bool value) {
                  widget.onChanged(value);
              })
        ],
      ),
    );
  }
}
