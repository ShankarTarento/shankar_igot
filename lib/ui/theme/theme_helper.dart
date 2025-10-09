import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/fonts/font_styles.dart';

import '../../constants/_constants/color_constants.dart';

ThemeData igotlightTheme() {
  return ThemeData(
    useMaterial3: false,
    appBarTheme: AppBarTheme(
        color: AppColors.appBarBackground, foregroundColor: AppColors.greys),
    dividerColor: Colors.transparent,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    primaryColor: AppColors.appBarBackground,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.darkBlue,
      selectionColor: AppColors.darkBlue,
      selectionHandleColor: AppColors.darkBlue,
    ),
    brightness: Brightness.light,
    textTheme: TextTheme(
      headlineLarge: AppFonts.lat24w7,
      headlineMedium: AppFonts.lat14w7,
      headlineSmall: AppFonts.lat16w7,
      titleLarge: AppFonts.lat16w6,
      titleMedium: AppFonts.lat16w4,
      titleSmall: AppFonts.lat14w7primaryBlue,
      bodyLarge: AppFonts.lat14w6,
      bodyMedium: AppFonts.lat14w4greys87,
      bodySmall: AppFonts.lat14w4primaryBlue,
      displayLarge: AppFonts.lat14w7greys87,
      displayMedium: AppFonts.lat14w7customBlue,
      displaySmall: AppFonts.lat14w7white,
      labelLarge: AppFonts.lat14w4grey40,
      labelMedium: AppFonts.lat12w4,
      labelSmall: AppFonts.lat10w4,
    ),
  );
}

//DarkTheme starts here
ThemeData igotdarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    textTheme: TextTheme(
        // headlineLarge: AppFonts.darklat24w7,
        // headlineMedium: AppFonts.darklat20w7,
        // headlineSmall: AppFonts.darklat16w7,
        // titleLarge: AppFonts.darklat16w6,
        // titleMedium: AppFonts.darklat16w4,
        // titleSmall: AppFonts.darklat14w7primaryBlue,
        // bodyLarge: AppFonts.darklat14w6,
        // bodyMedium: AppFonts.darklat14w4greys87,
        // bodySmall: AppFonts.darklat14w4primaryBlue,
        // displayLarge: AppFonts.darklat14w7greys87,
        // displayMedium: AppFonts.darklat14w7customBlue,
        // displaySmall: AppFonts.darklat14w7white,
        // labelLarge: AppFonts.darklat14w4grey40,
        // labelMedium: AppFonts.darklat12w4,
        // labelSmall: AppFonts.darklat10w4,
        ),
  );
}
