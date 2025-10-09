import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/constants/color_constants.dart';
import '../../../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../../../util/helper.dart';
import '../../../../skeleton/widgets/container_skeleton.dart';

class CommentProfileImageWidget extends StatelessWidget {
  final String? profilePic;
  final String name;
  final Color errorImageColor;
  final double iconSize;
  CommentProfileImageWidget(
      {Key? key,
      this.profilePic,
      required this.name,
      required this.errorImageColor,
      required this.iconSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _profileImageWidget();
  }

  Widget _profileImageWidget() {
    return Container(
        height: iconSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(100.w)),
        ),
        child: (profilePic != null)
            ? ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(100),
                ),
                child: CachedNetworkImage(
                    height: iconSize,
                    width: iconSize,
                    fit: BoxFit.contain,
                    imageUrl:
                        Helper.convertGCPImageUrl(profilePic.toString().trim()),
                    placeholder: (context, url) => Container(
                          decoration: BoxDecoration(
                              color: ModuleColors.grey04,
                              borderRadius: BorderRadius.circular(0)),
                          child: ContainerSkeleton(
                            width: iconSize,
                            height: iconSize,
                            radius: 0,
                          ),
                        ),
                    errorWidget: (context, url, error) =>
                        _imageErrorWidget(name: name, iconSize: iconSize)),
              )
            : _imageErrorWidget(name: name, iconSize: iconSize));
  }

  Widget _imageErrorWidget({required String name, required double iconSize}) {
    return ClipRRect(
      borderRadius: BorderRadius.all(
        Radius.circular(100.w),
      ),
      child: Container(
        width: iconSize,
        height: iconSize,
        child: Container(
          decoration: BoxDecoration(
            color: errorImageColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              Helper.getInitialsNew(name),
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
