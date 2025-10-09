import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/page_loader.dart';
import '../data_models/tips_model.dart';

class TipsDisplayCard extends StatefulWidget {
  final Function()? closeFunction;
  final List<TipsModel> tips;
  const TipsDisplayCard({Key? key, this.closeFunction, required this.tips})
      : super(key: key);

  @override
  State<TipsDisplayCard> createState() => _TipsDisplayCardState();
}

class _TipsDisplayCardState extends State<TipsDisplayCard> {
  int randomNumber = Random().nextInt(13);

  @override
  Widget build(BuildContext context) {
    return widget.tips.isNotEmpty
        ? Stack(
            children: [
              Container(
                width: 1.sw,
                margin: EdgeInsets.only(left: 16, right: 16).r,
                padding: EdgeInsets.all(16).r,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.learnerTipsColor1),
                    borderRadius: BorderRadius.circular(8).r,
                    color: AppColors.learnerTipsColor2),
                child: Row(children: [
                  SizedBox(
                      height: 52.w,
                      width: 52.w,
                      child: CachedNetworkImage(
                          imageUrl: widget.tips[randomNumber].imagePath,
                          fit: BoxFit.contain,
                          placeholder: (context, url) {
                            return Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: PageLoader(),
                            );
                          },
                          errorWidget: (context, obj, stack) => Image.asset(
                                'assets/img/image_placeholder.jpg',
                                width: double.infinity.w,
                                height: 139.w,
                                fit: BoxFit.contain,
                              ))),
                  SizedBox(
                    width: 16.w,
                  ),
                  Flexible(
                    child: Text(
                      widget.tips[randomNumber].tip.getText(context),
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w400, fontSize: 14.sp),
                    ),
                  )
                ]),
              ),
              widget.closeFunction != null
                  ? Positioned(
                      right: 6.w,
                      top: -8.w,
                      child: IconButton(
                          onPressed: () {
                            widget.closeFunction!();
                          },
                          icon: Icon(
                            Icons.close,
                            size: 16,
                          )))
                  : SizedBox()
            ],
          )
        : SizedBox();
  }
}
