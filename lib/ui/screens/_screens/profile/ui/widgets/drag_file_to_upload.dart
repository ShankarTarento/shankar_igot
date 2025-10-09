import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';

import '../../../../../../constants/index.dart';
import '../../../../../widgets/_discussion_hub/screens/discussion/add_discussion/_models/media_upload_model.dart';
import '../../view_model/profile_achievement_view_model.dart';

class DragFileToUpload extends StatefulWidget {
  final String? documentUrl;
  final String? documentName;
  final Function(MediaUploadModel?) uploadCallback;
  final bool enabled;
  const DragFileToUpload(
      {Key? key,
      this.documentUrl,
      this.documentName,
      required this.uploadCallback,
      required this.enabled})
      : super(key: key);

  @override
  State<DragFileToUpload> createState() => _DragFileToUploadState();
}

class _DragFileToUploadState extends State<DragFileToUpload> {
  ValueNotifier<MediaUploadModel?> selectedFile =
      ValueNotifier<MediaUploadModel?>(null);
  @override
  void initState() {
    super.initState();
    if (widget.documentUrl != null && widget.documentUrl!.isNotEmpty) {
      selectedFile.value = MediaUploadModel(
          fileUrl: widget.documentUrl,
          fileName: widget.documentName,
          isUploaded: true,
          isErrorFile: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: selectedFile,
        builder: (context, file, child) {
          return file == null
              ? InkWell(
                  onTap: widget.enabled
                      ? () async {
                          File? file = await ProfileAchievementViewModel()
                              .getMedia(context);
                          selectedFile.value = file != null
                              ? MediaUploadModel(
                                  file: file,
                                  isUploaded: false,
                                  isErrorFile: false)
                              : null;
                          widget.uploadCallback(selectedFile.value);
                        }
                      : null,
                  child: Container(
                    color: widget.enabled
                        ? AppColors.darkBlue.withValues(alpha: 0.04)
                        : AppColors.grey08,
                    child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: Radius.circular(8),
                        color: widget.enabled
                            ? AppColors.darkBlue
                            : AppColors.grey24,
                        dashPattern: [4, 4],
                        strokeWidth: 1,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8).r,
                        child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload,
                                  color: widget.enabled
                                      ? AppColors.darkBlue
                                      : AppColors.grey24,
                                  size: 24.w,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                    AppLocalizations.of(context)!
                                        .mProfileDragFileToUpload,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(
                                          fontSize: 12.sp,
                                          color: widget.enabled
                                              ? AppColors.darkBlue
                                              : AppColors.grey24,
                                        )),
                              ],
                            ))),
                  ))
              : _imageView(file);
        });
  }

  Widget _imageView(MediaUploadModel media) {
    return Container(
      width: 0.7.sw,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 0.7.sw,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8).r,
            decoration: BoxDecoration(
              color: AppColors.darkBlue.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (media.isUploaded)
                    ? MicroSiteImageView(
                        imgUrl: media.fileUrl ?? '',
                        height: 40.w,
                        width: 70.w,
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        media.file!,
                        height: 40.w,
                        width: 70.w,
                        fit: BoxFit.contain,
                      ),
                SizedBox(width: 8.w),
                SizedBox(
                  width: 0.4.sw,
                  child: Text(
                      media.isUploaded
                          ? media.fileName != null
                              ? media.fileName!
                              : ''
                          : media.file!.path.split('/').last,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: AppColors.deepBlue,
                          )),
                )
              ],
            ),
          ),
          Positioned(
              top: -12,
              right: -24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(63).r,
                child: InkWell(
                  onTap: () {
                    selectedFile.value = null;
                    widget.uploadCallback(null);
                  },
                  child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 24).r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.negativeLight,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20.sp,
                        color: AppColors.appBarBackground,
                      )),
                ),
              ))
        ],
      ),
    );
  }
}
