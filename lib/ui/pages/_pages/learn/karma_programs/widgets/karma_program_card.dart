import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../models/_models/playlist_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../skeleton/index.dart';

class KarmaProgramCard extends StatefulWidget {
  final PlayList karmaProgram;
  const KarmaProgramCard({Key? key, required this.karmaProgram})
      : super(key: key);

  @override
  State<KarmaProgramCard> createState() => _KarmaProgramCardState();
}

class _KarmaProgramCardState extends State<KarmaProgramCard> {
  @override
  void initState() {
    randomInt = Random().nextInt(AppColors.karmaProgramCardBg.length);
    super.initState();
  }

  int? randomInt;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 245.w,
      height: 220.w,
      decoration: BoxDecoration(
          color: AppColors.darkBlue, borderRadius: BorderRadius.circular(8).r),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(50, 30).w,
                topRight: Radius.elliptical(50, 30).w),
            child: widget.karmaProgram.imgUrl != null
                ? CachedNetworkImage(
                    height: 135.w,
                    width: double.infinity.w,
                    fit: BoxFit.cover,
                    imageUrl: widget.karmaProgram.imgUrl!,
                    placeholder: (context, url) => Container(
                          height: 230.w,
                          width: 1.sw,
                          color: AppColors.appBarBackground,
                          child: ContainerSkeleton(
                            height: 135.w,
                            radius: 0.r,
                          ),
                        ),
                    errorWidget: (context, url, error) => Image.asset(
                          'assets/img/image_placeholder.jpg',
                          width: double.infinity.w,
                          height: 135.w,
                          fit: BoxFit.cover,
                        ))
                : Image.asset(
                    'assets/img/image_placeholder.jpg',
                    width: double.infinity.w,
                    height: 135.w,
                    fit: BoxFit.cover,
                  ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(16).w,
                decoration: BoxDecoration(
                    color: AppColors.karmaProgramCardBg[randomInt ?? 0],
                    borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8))
                        .r),
                width: double.infinity.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.karmaProgram.title.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                          color: AppColors.appBarBackground,
                          fontSize: 16.0.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8.w),
                    Text(
                        '${widget.karmaProgram.childrens != null ? widget.karmaProgram.childrens!.length : 0} ${AppLocalizations.of(context)!.mHomeCardPrograms}',
                        style: GoogleFonts.lato(
                            color: AppColors.appBarBackground,
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
