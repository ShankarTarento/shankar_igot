import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/app_details_service.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class AppUpgradeStrip extends StatefulWidget {
  const AppUpgradeStrip({super.key});

  @override
  State<AppUpgradeStrip> createState() => _AppUpgradeStripState();
}

class _AppUpgradeStripState extends State<AppUpgradeStrip> {
  final _storage = FlutterSecureStorage();
  late Future<AppCheckerResult?> _updateCheckFuture;

  @override
  void initState() {
    super.initState();
    _updateCheckFuture = _checkAppUpdateStatus();
  }

  Future<AppCheckerResult?> _checkAppUpdateStatus() async {
    String? showAppUpdateStrip =
        await _storage.read(key: Storage.showAppUpateStrip);

    if (showAppUpdateStrip == "true") {
      final result = await AppVersionChecker().checkUpdate(context);
      return result;
    }
    return null;
  }

  Future<void> _closeStrip() async {
    await _storage.write(key: Storage.showAppUpateStrip, value: "false");
    setState(() {
      _updateCheckFuture = Future.value(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!(AppConfiguration.appUpdateModel?.optionalUpdate?.enabled ?? true))
      return SizedBox.shrink();
    return FutureBuilder<AppCheckerResult?>(
      future: _updateCheckFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        } else if (snapshot.hasData && snapshot.data!.canUpdate) {
          final result = snapshot.data!;
          return Container(
            padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8).r,
            width: 1.sw,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.darkBlue,
                  AppColors.blue2,
                  AppColors.primaryThree,
                ],
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                    width: 0.6.sw,
                    child: Wrap(
                      children: [
                        Text(
                          AppConfiguration.appUpdateModel?.optionalUpdate
                                  ?.updateMessage ??
                              "New Version Of App Available",
                          style: TextStyle(
                              color: AppColors.appBarBackground,
                              fontSize: 14.sp),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    )),
                Spacer(),
                if (AppConfiguration
                        .appUpdateModel?.optionalUpdate?.enableUpdateButton ??
                    false)
                  SizedBox(
                    height: 28.w,
                    width: 72.w,
                    child: ElevatedButton(
                      onPressed: () {
                        Helper.doLaunchUrl(url: result.appURL);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOne,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0).r,
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      ),
                      child: Text(
                        AppConfiguration
                                .appUpdateModel?.optionalUpdate?.buttonText ??
                            "Update",
                        style: GoogleFonts.lato(fontSize: 12.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                if (AppConfiguration
                        .appUpdateModel?.optionalUpdate?.enableCloseButton ??
                    false)
                  SizedBox(width: 8),
                if (AppConfiguration
                        .appUpdateModel?.optionalUpdate?.enableCloseButton ??
                    false)
                  InkWell(
                    onTap: _closeStrip,
                    child: Icon(
                      Icons.close,
                      color: AppColors.appBarBackground,
                      size: 24.w,
                    ),
                  ),
              ],
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
