import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/settings_repository.dart';
import 'package:provider/provider.dart';

class FontSlider extends StatefulWidget {
  const FontSlider({super.key});

  @override
  State<FontSlider> createState() => _FontSliderState();
}

class _FontSliderState extends State<FontSlider> {
  final _storage = FlutterSecureStorage();

  double _currentSliderValue = 1.0;

  @override
  void initState() {
    super.initState();
    setDefaultFont();
  }

  Future<void> setDefaultFont() async {
    String? fontSize = await _storage.read(key: Storage.fontSize);
    if (fontSize != null) {
      setState(() {
        _currentSliderValue = double.parse(fontSize);
      });
    } else {
      _currentSliderValue = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.w,
      width: 1.sw,
      child: Row(
        children: [
          Text(
            'A',
            style: GoogleFonts.lato(fontSize: 14.sp),
          ),
          Expanded(
            child: Slider(
              activeColor: AppColors.darkBlue,
              value: _currentSliderValue,
              max: 1.2,
              min: 0.9,
              divisions: 3,
              onChangeEnd: (value) {
                setState(() {
                  _currentSliderValue = value;
                  Provider.of<SettingsRepository>(context, listen: false)
                      .setFontSize(size: value);
                });
              },
              onChanged: (v) {},
            ),
          ),
          Text(
            'A',
            style: GoogleFonts.lato(fontSize: 24.sp),
          ),
        ],
      ),
    );
  }
}
