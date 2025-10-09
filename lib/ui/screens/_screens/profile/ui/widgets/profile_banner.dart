import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../util/index.dart';
import '../../../../../skeleton/index.dart';
import '../../model/photo_render_status_model.dart';
import '../../utils/profile_constants.dart';
import '../../view_model/profile_banner_view_model.dart';
import '../../view_model/profile_top_section_view_model.dart';
import 'photo_render_option.dart';

class ProfileBanner extends StatefulWidget {
  final String? bannerImage;
  final bool isMyProfile;
  final VoidCallback updateBasicProfile;

  const ProfileBanner(
      {super.key,
      this.bannerImage,
      this.isMyProfile = true,
      required this.updateBasicProfile});
  @override
  State<ProfileBanner> createState() => _ProfileBannerState();
}

class _ProfileBannerState extends State<ProfileBanner> {
  ValueNotifier<String?> selectedBanner = ValueNotifier(null);
  @override
  void initState() {
    super.initState();
    if (widget.bannerImage != null && widget.bannerImage!.isNotEmpty) {
      selectedBanner.value = widget.bannerImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ValueListenableBuilder(
          valueListenable: selectedBanner,
          builder: (context, bannerImage, child) {
            return bannerImage != null
                ? CachedNetworkImage(
                    fit: BoxFit.fill,
                    height: 0.2.sh,
                    width: 1.0.sw,
                    imageUrl: bannerImage,
                    placeholder: (context, url) => ContainerSkeleton(
                          height: 0.2.sh,
                          width: 1.0.sw,
                          radius: 4,
                        ),
                    errorWidget: (context, url, error) => EmptyBanner())
                : EmptyBanner();
          }),
      widget.isMyProfile
          ? Positioned(
              right: 16.w,
              child: InkWell(
                onTap: () => photoOptions(context),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 16).r,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(63).r,
                    child: Container(
                      color: AppColors.greys60,
                      padding: EdgeInsets.all(4).r,
                      child: Icon(Icons.edit,
                          size: 16.sp, color: AppColors.appBarBackground),
                    ),
                  ),
                ),
              ))
          : Center()
    ]);
  }

  Container EmptyBanner() {
    return Container(
        color: AppColors.appBarBackground,
        child: CachedNetworkImage(
            height: 0.2.sh,
            fit: BoxFit.fill,
            width: 1.sw,
            color: AppColors.greys87,
            imageUrl: ApiUrl.baseUrl +
                '/assets/mobile_app/assets/provider_background.png',
            placeholder: (context, url) => ContainerSkeleton(
                  height: 0.2.sh,
                  width: 1.sw,
                ),
            errorWidget: (context, url, error) => Container(
                height: 0.2.sh,
                width: 1.sw,
                color: AppColors.appBarBackground)));
  }

  Future photoOptions(contextMain) {
    return showModalBottomSheet(
        context: context,
        builder: (context) => PhotoRenderOption(
              parentContext: contextMain,
              cropShape: CustomCropShape.Ratio,
              imageFormat: ImageFormat.profileBanner,
              callBackOnImage: (PhotoRenderStatusModel response) async {
                if (response.image != null) {
                  File imageFile = await ProfileBannerViewModel().memoryImageToFile(
                      response.image!,
                      '${response.fileName ?? 'banner_image${DateTime.now().microsecondsSinceEpoch}'}.${response.format}');

                  double imageSize = await ProfileTopSectionViewModel()
                      .imageSizeInMb(imageFile);
                  if (imageSize <= ImageMaxSizeInMB.profileBanner) {
                    String? imageUrl = await ProfileBannerViewModel()
                        .uploadBanner(imageFile, contextMain);
                    if (imageUrl != null) {
                      selectedBanner.value = imageUrl;
                      widget.updateBasicProfile();
                    }
                  } else {
                    Helper.showToastMessage(contextMain,
                        message: AppLocalizations.of(contextMain)!
                            .mProfileProfileImageError(
                                ImageMaxSizeInMB.profileBanner));
                  }
                } else if (response.changePhoto) {
                  await photoOptions(contextMain);
                } else if (response.deletePhoto) {
                  bool response =
                      await ProfileBannerViewModel().deleteBanner(contextMain);
                  if (response) {
                    selectedBanner.value = null;
                    widget.updateBasicProfile();
                  }
                }
              },
            ));
  }
}
