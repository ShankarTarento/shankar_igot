import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/index.dart';

class ShowFlashLightWidget extends StatelessWidget {
  final bool isFlashOn;
  final VoidCallback onFlashClicled;

  ShowFlashLightWidget(
    this.isFlashOn,
    this.onFlashClicled, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: SizedBox(
          height: 80.w,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                    onPressed: null,
                    iconSize: 34.r,
                    icon: isFlashOn
                        ? const Icon(Icons.flash_off, color: AppColors.grey)
                        : const Icon(Icons.flash_on, color: AppColors.grey)),
                isFlashOn
                    ? Text(AppLocalizations.of(context)!.mStaticOffFlash)
                    : Text(AppLocalizations.of(context)!.mStaticOnFlash),
              ],
            ),
          ),
        ),
        onTap: onFlashClicled);
  }
}
