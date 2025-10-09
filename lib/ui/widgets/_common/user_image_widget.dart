import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/constants/color_constants.dart';
import '../../../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../../../util/helper.dart';
import '../../skeleton/widgets/container_skeleton.dart';


class UserImageWidget extends StatelessWidget {
  final String imgUrl;
  final String errorText;
  final Color errorImageColor;
  final double errorTextFontSize;
  final double height;
  final double width;
  final BoxFit? fit;
  final BorderRadiusGeometry? borderRadius;
  UserImageWidget({
    Key? key,
    this.imgUrl = '',
    required this.errorText,
    required this.errorImageColor,
    required this.errorTextFontSize,
    required this.height,
    required this.width,
    this.fit,
    this.borderRadius
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return _profileImageWidget();
  }

  Widget _profileImageWidget() {
    return Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(100.w)),
        ),
        child: (imgUrl.isNotEmpty )
            ? ClipRRect(
                borderRadius:
                    borderRadius ?? BorderRadius.all(Radius.circular(100)),
                child: CachedNetworkImage(
                    height: height,
                    width: width,
                    fit: fit ?? BoxFit.contain,
                    imageUrl:
                        Helper.convertGCPImageUrl(imgUrl.toString().trim()),
                    placeholder: (context, url) => Container(
                          decoration: BoxDecoration(
                              color: ModuleColors.grey04,
                              borderRadius: BorderRadius.circular(0)),
                          child: ContainerSkeleton(
                            width: width,
                            height: height,
                            radius: 0,
                          ),
                        ),
                    errorWidget: (context, url, error) => _imageErrorWidget()),
              )
            : _imageErrorWidget());
  }

  Widget _imageErrorWidget() {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(100.w),),
      child: Container(
        width:  width,
        height:  height,
        child: Container(
          decoration: BoxDecoration(
            color: errorImageColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              Helper.getInitialsNew(errorText),
              style: GoogleFonts.lato(
                  color: AppColors.avatarText,
                  fontWeight: FontWeight.w600,
                  fontSize: errorTextFontSize),
            ),
          ),
        ),
      ),
    );
  }
}
