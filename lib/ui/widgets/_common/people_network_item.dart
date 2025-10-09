import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:igot_ui_components/utils/fade_route.dart';
import 'package:karmayogi_mobile/respositories/_respositories/network_respository.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/network/network_profile.dart';
import 'package:provider/provider.dart';
import '../../../constants/index.dart';
import '../../../models/index.dart';
import '../../../util/helper.dart';

class PeopleNetworkItem extends StatefulWidget {
  final Suggestion suggestion;
  final ValueChanged<String> parentAction1;
  final parentAction2;
  final List<dynamic>? requestedConnections;
  final double? cardWidth;
  final VoidCallback? doCallTelemetry;
  final Function(bool) updateViewCallBack;

  const PeopleNetworkItem(
      {Key? key,
      required this.suggestion,
      required this.parentAction1,
      this.parentAction2,
      this.requestedConnections,
      this.cardWidth,
      this.doCallTelemetry,
      required this.updateViewCallBack})
      : super(key: key);

  @override
  State<PeopleNetworkItem> createState() => _PeopleNetworkItemState();
}

class _PeopleNetworkItemState extends State<PeopleNetworkItem> {
  @override
  void initState() {
    randomNumber = Random().nextInt(AppColors.networkBg.length);
    super.initState();
  }

  int randomNumber = 0;
  @override
  Widget build(BuildContext context) {
    bool isConnectionNotRequested = (!(widget.requestedConnections
            ?.any((element) => element['id'] == widget.suggestion.id) ??
        false));
    return InkWell(
        onTap: () {
          if (widget.doCallTelemetry != null) {
            widget.doCallTelemetry!();
          }
          Navigator.push(
            context,
            FadeRoute(
              page: ChangeNotifierProvider<NetworkRespository>(
                create: (context) => NetworkRespository(),
                child: NetworkProfile(
                  profileId: widget.suggestion.id,
                  connectionStatus: isConnectionNotRequested
                      ? UserConnectionStatus.Connect
                      : UserConnectionStatus.Pending,
                ),
              ),
            ),
          );
        },
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
                margin:
                    EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 32).r,
                width: widget.cardWidth ?? 161.0.w,
                height: 196.w,
                decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey08,
                      blurRadius: 6.0.r,
                      spreadRadius: 0.r,
                      offset: Offset(
                        3,
                        3,
                      ),
                    ),
                  ],
                  border: Border.all(color: AppColors.grey08),
                  borderRadius: BorderRadius.circular(8).r,
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 50, 20, 0).r,
                        child: Text(
                          (Helper.capitalizeFirstLetter(
                                      widget.suggestion.firstName) +
                                  ' ' +
                                  Helper.capitalizeFirstLetter(
                                      widget.suggestion.lastName))
                              .toString()
                              .trim(),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                height: 1.0.w,
                                letterSpacing: 0.25.r,
                              ),
                        ),
                      ),
                      if (widget.suggestion.designation.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0).r,
                          child: Text(
                            Helper().capitalizeFirstCharacter(
                                widget.suggestion.designation),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.sp,
                                  height: 1.429.w,
                                  letterSpacing: 0.25.r,
                                ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0).r,
                        child: Text(
                          widget.suggestion.department,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                                height: 1.429.w,
                                letterSpacing: 0.25.r,
                              ),
                        ),
                      ),
                      Container(
                        width: double.infinity.w,
                        padding: const EdgeInsets.only(
                                top: 2, bottom: 2, left: 10, right: 10)
                            .r,
                        child: OutlinedButton(
                          onPressed: () {
                            if ((!widget.requestedConnections!.any((element) =>
                                element['id'] == widget.suggestion.id))) {
                              widget.parentAction1(widget.suggestion.id);
                              widget.parentAction2(widget.suggestion.id,
                                  subType:
                                      TelemetrySubType.suggestedConnections,
                                  primaryCategory: TelemetryObjectType.user,
                                  clickId: TelemetryIdentifier.cardContent);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            splashFactory: (widget.requestedConnections!.any(
                                    (element) =>
                                        element['id'] == widget.suggestion.id))
                                ? NoSplash.splashFactory
                                : null,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20).r,
                                side: BorderSide(color: AppColors.grey16)),
                          ),
                          child: isConnectionNotRequested
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: SvgPicture.asset(
                                        'assets/img/connect_icon.svg',
                                        width: 18.0.w,
                                        height: 18.0.w,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    SizedBox(
                                      width: 70.w,
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .mStaticConnect,
                                        style: GoogleFonts.lato(
                                            color: AppColors.darkBlue,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                )
                              : Text(
                                  AppLocalizations.of(context)!
                                      .mStaticConnectionRequestSent,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                      color: AppColors.grey40,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      )
                    ])),
            Positioned(
                top: 10,
                child: Center(
                  child: widget.suggestion.profileImageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(63).r,
                          child: Container(
                            height: 64.w,
                            width: 48.w,
                            color: AppColors.grey04,
                            child: Image(
                              height: 48.w,
                              width: 48.w,
                              fit: BoxFit.fitWidth,
                              image: NetworkImage(
                                  widget.suggestion.profileImageUrl),
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 48.w,
                                width: 48.w,
                                color: AppColors.grey04,
                              ),
                            ),
                          ))
                      : (widget.suggestion.photo != ''
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4).r,
                              child: Image.memory(
                                  Helper.getByteImage(widget.suggestion.photo)))
                          : CircleAvatar(
                              radius: 32.r,
                              backgroundColor:
                                  AppColors.networkBg[randomNumber],
                              child: Text(
                                Helper.getInitials(
                                    widget.suggestion.firstName.trim() +
                                        ' ' +
                                        widget.suggestion.lastName.trim()),
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(
                                      fontFamily:
                                          GoogleFonts.montserrat().fontFamily,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20.sp,
                                      letterSpacing: 0.12.r,
                                    ),
                              ),
                            )),
                )),
          ],
        ));
  }
}
