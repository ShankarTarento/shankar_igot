import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../respositories/index.dart';
import '../../../../../widgets/_common/user_image_widget.dart';

class ProfileImageWidget extends StatelessWidget {
  final MemoryImage? image;
  final String profileImageUrl;
  final String firstName;
  final String surname;
  final double height;
  final double width;

  const ProfileImageWidget(
      {Key? key,
      this.image,
      this.profileImageUrl = '',
      this.firstName = '',
      this.surname = '', this.height = 0.2, this.width =0.2})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return image != null
        ? Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(200).r,
              child: Image(
                image: image!,
                height: height.sw,
                width: width.sw,
                fit: BoxFit.fitWidth,
              ),
            ),
          ])
        : Consumer<ProfileRepository>(builder: (context, profileRepository, _) {
            return Stack(children: [
              UserImageWidget(
                imgUrl: profileImageUrl,
                errorText: firstName + surname,
                errorImageColor: AppColors.deepBlue,
                errorTextFontSize: 24.sp,
                height: height.sw,
                width: width.sw,
                fit: BoxFit.contain,
              ),
            ]);
          });
  }
}
