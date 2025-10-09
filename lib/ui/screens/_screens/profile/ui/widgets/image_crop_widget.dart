import 'dart:io';
import 'dart:ui';

import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../constants/index.dart';
import '../../model/photo_render_status_model.dart';

class ImageCropWidget extends StatefulWidget {
  final String imagePath;
  final CustomCropShape cropShape;
  final CustomImageFit imageFit;

  const ImageCropWidget(
      {super.key,
      required this.imagePath,
      this.cropShape = CustomCropShape.Square,
      this.imageFit = CustomImageFit.fillCropSpace});

  @override
  State<ImageCropWidget> createState() => _ImageCropWidgetState();
}

class _ImageCropWidgetState extends State<ImageCropWidget> {
  final CustomImageCropController cropController = CustomImageCropController();
  double _radius = 4;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 24).r,
          color: AppColors.appBarBackground,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16).r,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)!.mProfileEditCoverPhoto,
                        style: Theme.of(context).textTheme.titleLarge),
                    InkWell(
                        onTap: cropController.reset,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30).r,
                          child: Icon(Icons.close,
                              size: 20.sp, color: AppColors.greys60),
                        ))
                  ],
                ),
              ),
              Expanded(
                child: CustomImageCrop(
                  cropController: cropController,
                  image: FileImage(File(widget.imagePath)),
                  cropPercentage: 1.0,
                  shape: widget.cropShape,
                  ratio: widget.cropShape == CustomCropShape.Ratio
                      ? Ratio(width: 1.0.sw, height: 0.4.sw)
                      : null,
                  canRotate: true,
                  canMove: true,
                  canScale: true,
                  borderRadius:
                      widget.cropShape == CustomCropShape.Ratio ? _radius : 0,
                  customProgressIndicator: const CupertinoActivityIndicator(),
                  outlineColor: AppColors.appBarBackground,
                  imageFit: widget.imageFit,
                  imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8).r,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BottomButtonWidget(context,
                        AppLocalizations.of(context)!.mProfileDeletePhoto,
                        color: AppColors.negativeLight,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(color: AppColors.negativeLight),
                        onTap: () {
                      Navigator.of(context)
                          .pop(PhotoRenderStatusModel(deletePhoto: true));
                    }),
                    BottomButtonWidget(context,
                        AppLocalizations.of(context)!.mProfileChangePhoto,
                        icon: Icons.image_outlined, onTap: () {
                      Navigator.of(context)
                          .pop(PhotoRenderStatusModel(changePhoto: true));
                    }),
                    BottomButtonWidget(context,
                        AppLocalizations.of(context)!.mProfileSavePhoto,
                        icon: Icons.done, onTap: () async {
                      final image = await cropController.onCropImage();
                      if (image != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context)
                              .pop(PhotoRenderStatusModel(image: image));
                        });
                      }
                    }),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  InkWell BottomButtonWidget(BuildContext context, String text,
      {Color? color,
      TextStyle? style,
      required VoidCallback onTap,
      IconData? icon}) {
    return InkWell(
        onTap: () => onTap(),
        child: Column(children: [
          Icon(icon ?? Icons.delete,
              color: color ?? AppColors.darkBlue, size: 16.sp),
          Text(text, style: style ?? Theme.of(context).textTheme.headlineMedium)
        ]));
  }
}
