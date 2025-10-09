import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../util/index.dart';
import '../../model/photo_render_status_model.dart';
import '../../view_model/profile_top_section_view_model.dart';
import 'image_crop_widget.dart';

class PhotoRenderOption extends StatelessWidget {
  final BuildContext parentContext;
  final Function(PhotoRenderStatusModel)? callBackOnImage;
  final CustomCropShape cropShape;
  final CustomImageFit imageFit;
  final List<String> imageFormat;

  const PhotoRenderOption(
      {super.key,
      required this.parentContext,
      this.callBackOnImage,
      this.cropShape = CustomCropShape.Square,
      this.imageFit = CustomImageFit.fillCropSpace,
      required this.imageFormat});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 80.0).r,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0).w,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop(true);
                _getImage(ImageSource.camera, parentContext);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.photo_camera, color: AppColors.darkBlue),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0).r,
                    child: Text(
                        AppLocalizations.of(parentContext)!.mStaticTakeAPicture,
                        style: Theme.of(parentContext)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0).r,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop(true);
                _getImage(ImageSource.gallery, parentContext);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.photo, color: AppColors.darkBlue),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0).r,
                    child: Text(
                        AppLocalizations.of(parentContext)!.mStaticGoToFiles,
                        style: Theme.of(parentContext)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getImage(ImageSource source, BuildContext parentContext) async {
    try {
      final picker = ImagePicker();
      XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        if (ProfileTopSectionViewModel()
            .isValidImageFormat(image, imageFormat)) {
          PhotoRenderStatusModel statusResponse = await Navigator.push(
            parentContext,
            MaterialPageRoute(
              builder: (context) => ImageCropWidget(
                imagePath: image.path,
                cropShape: cropShape,
                imageFit: imageFit,
              ),
            ),
          );
          if (callBackOnImage != null) {
            if(!statusResponse.deletePhoto &&!statusResponse.changePhoto){
              statusResponse.format =
                ProfileTopSectionViewModel().getFormat(image);
                statusResponse.fileName =
                ProfileTopSectionViewModel().getFileName(image);
            }
            callBackOnImage!(statusResponse);
          }
        } else {
          Helper.showToastMessage(parentContext,
              message: AppLocalizations.of(parentContext)!
                  .mProfileInvalidFileFormat);
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
