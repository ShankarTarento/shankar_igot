import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants/index.dart';

class AppColor {
  static const Color primary = Color(0xFFFF753F);
  static const Color secondary = Color(0xFF025BBF);
  static const Color accent1 = Color(0xFF32C759);
  static const Color accent2 = Color(0xFF025BBF);
  static const Color greyColorText = Color(0xFF808080);
}

Widget htmlText(String title) {
  return Column(
    children: [
      HtmlWidget(title,
          textStyle: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.greys,
          )),
      SizedBox(
        height: 4,
      ),
    ],
  );
}
