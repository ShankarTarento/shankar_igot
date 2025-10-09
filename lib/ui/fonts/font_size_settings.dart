import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/fonts/font_size_provider.dart';
import 'package:provider/provider.dart';

import '../../constants/index.dart';

class FontSettings extends StatefulWidget {
  const FontSettings({Key? key}) : super(key: key);

  @override
  State<FontSettings> createState() => _FontSettingsState();
}

class _FontSettingsState extends State<FontSettings> {
  @override
  Widget build(BuildContext context) {
    final fontSizeProvider =
        Provider.of<FontSizeProvider>(context, listen: true);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
      ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 5),
      child: Column(
        children: [
          Text(
            "Change text size",
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  height: 1.5,
                  letterSpacing: 0.25,
                ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 90.0),
            child: Column(
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: !fontSizeProvider.smallButtonEnabled
                          ? () {
                              fontSizeProvider.smallFontSize();
                            }
                          : null,
                      child: Text("Small"),
                    ),
                    TextButton(
                      onPressed: !fontSizeProvider.mediumButtonEnabled
                          ? () {
                              fontSizeProvider.mediumFontSize();
                            }
                          : null,
                      child: Text("Default"),
                    ),
                    TextButton(
                      onPressed: !fontSizeProvider.largeButtonEnabled
                          ? () {
                              fontSizeProvider.largeFontSize();
                            }
                          : null,
                      child: Text("Large"),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "Small",
                            style: GoogleFonts.lato(fontSize: 15),
                          ),
                          Text(
                            "Default",
                            style: GoogleFonts.lato(fontSize: 20),
                          ),
                          Text(
                            "Large",
                            style: GoogleFonts.lato(fontSize: 30),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
