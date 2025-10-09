import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/theme/theme_manager.dart';
import 'package:provider/provider.dart';

class ThemeChange extends StatefulWidget {
  const ThemeChange({Key? key}) : super(key: key);

  @override
  State<ThemeChange> createState() => _ThemeState();
}

class _ThemeState extends State<ThemeChange> {
  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return InkWell(
      child: Container(
        child: Row(
          children: [
            Divider(
              thickness: 2,
              color: AppColors.greys87,
            ),
            Switch(
              value: themeManager.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeManager.toggleTheme(value);
              },
              activeColor: AppColors.customBlue,
            ),
            Text(
              "Dark mode",
              style: GoogleFonts.lato(
                color: AppColors.greys87,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                height: 1.5.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
