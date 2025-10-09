import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../constants/_constants/color_constants.dart';
import '../../../../constants/_constants/storage_constants.dart';

class DisableLearnerTips extends StatefulWidget {
  const DisableLearnerTips({Key? key}) : super(key: key);

  @override
  _DisableLearnerTipsState createState() => _DisableLearnerTipsState();
}

class _DisableLearnerTipsState extends State<DisableLearnerTips> {
  bool _isVisible = true;

  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    getVisibility();
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
          _storage.write(key: Storage.enableLearnerTip, value: "false");
        });
      }
    });
  }

  Future<void> getVisibility() async {
    try {
      // Read visibility status from storage
      final value = await _storage.read(key: Storage.enableLearnerTip);
      if (value != null) {
        setState(() {
          _isVisible = jsonDecode(value);
        });
      }
    } catch (e) {
      print("Error fetching visibility status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isVisible
        ? Container(
            padding: EdgeInsets.all(16).w,
            margin: EdgeInsets.all(16).w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8).w,
              color: AppColors.tipsBackground,
              border: Border.all(color: AppColors.tipsBackground),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 0.6.sw,
                  child: Text(
                    AppLocalizations.of(context)!.mDisableTipsText,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      // Update visibility status and store in storage
                      _storage.write(
                          key: Storage.enableLearnerTip, value: "false");
                      _isVisible = false;
                    });
                  },
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          )
        : SizedBox();
  }
}
