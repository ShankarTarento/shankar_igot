// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/constants/color_constants.dart';
import '../../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../../util/helper.dart';
import '../../../../../../skeleton/widgets/container_skeleton.dart';
import '../../../model/mdo_channel_data_model.dart';

class ChannelListItemWidget extends StatefulWidget {
  final Function() onTap;
  final MdoChannelDataModel cardData;
  ChannelListItemWidget({
    Key? key,
    required this.onTap,
    required this.cardData,
  }) : super(key: key);

  @override
  _ChannelListItemWidgetState createState() {
    return new _ChannelListItemWidgetState();
  }
}

class _ChannelListItemWidgetState extends State<ChannelListItemWidget> {

  Color? errorImageColor = AppColors.networkBg[
  Random().nextInt(AppColors.networkBg.length)];

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: widget.onTap,
        child: Container(
            height: 156.w,
            width: double.maxFinite,
            padding: EdgeInsets.all(4).w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12.w)),
              color: AppColors.blue127,
            ),
            child: Column(
              children: [
                _profileImageWidget(),
                Padding(
                    padding: EdgeInsets.only(top: 16).w,
                    child: Text(
                      widget.cardData.channel != null
                          ? widget.cardData.channel.toString().trim()
                          : '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                          color: AppColors.black,
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ))
              ],
            )));
  }

  Widget _profileImageWidget() {
    return Container(
        height: 86.w,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
          color: AppColors.appBarBackground,
        ),
        child: (widget.cardData.imgUrl != null)
            ? ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(0),
          ),
          child: CachedNetworkImage(
              height: 62.w,
              width: double.maxFinite,
              fit: BoxFit.contain,
              imageUrl: widget.cardData.imgUrl.toString().trim(),
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                    color: ModuleColors.grey04,
                    borderRadius: BorderRadius.circular(0)),
                child: ContainerSkeleton(
                  width: double.maxFinite,
                  height: 62.w,
                  radius: 0,
                ),
              ),
              errorWidget: (context, url, error) => _imageErrorWidget()
          ),
        )
            :  _imageErrorWidget()
    );
  }

  Widget _imageErrorWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.all(
        Radius.circular(100.w),
      ),
      child: Container(
        padding: EdgeInsets.all(2).w,
        child: Container(
          decoration: BoxDecoration(
            color: errorImageColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              Helper.getInitialsNew(
                  widget.cardData.channel != null
                      ? widget.cardData.channel.toString().trim()
                      : ''),
              style: GoogleFonts.lato(
                  color: AppColors.avatarText,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0.sp),
            ),
          ),
        ),
      ),
    );
  }
}
