import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class AddMediaWidget extends StatefulWidget {
  final BuildContext parentContext;
  final Function(Map<String, dynamic>) uploadCallback;
  final bool enableImageUpload;
  final bool enableVideoUpload;
  final bool enableFileUpload;
  final bool allowAllMedia;
  const AddMediaWidget(
      {Key? key,
      required this.parentContext,
      required this.uploadCallback,
      required this.enableImageUpload,
      required this.enableVideoUpload,
      required this.enableFileUpload,
      this.allowAllMedia = true})
      : super(key: key);

  @override
  State<AddMediaWidget> createState() => _AddMediaWidgetState();
}

class _AddMediaWidgetState extends State<AddMediaWidget> {
  ValueNotifier<bool> _inProcess = ValueNotifier(false);
  late MediaSource selectedMediaType;

  Future<dynamic> _getMedia(MediaSource source) async {
    final picker = ImagePicker();
    _inProcess.value = true;

    XFile? media;
    if (source == MediaSource.image) {
      /// Pick image
      media = await picker.pickImage(source: ImageSource.gallery);
    } else if (source == MediaSource.video) {
      /// Pick video
      media = await picker.pickVideo(source: ImageSource.gallery);
    } else if (source == MediaSource.file) {
      /// pick file
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx'],
          compressionQuality: 50,
          allowMultiple: false,
        );
        if (result != null) {
          media = XFile(result.files.single.path!);
        }
      } catch (e) {
        Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context)?.mStaticErrorMessage ?? '',
            bgColor: AppColors.negativeLight);
      }
    }

    /// If media is selected
    if (media != null) {
      final file = File(media.path);
      final fileSizeInBytes = await file.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      /// Set file size limits
      double maxSizeInMB;
      if (source == MediaSource.file) {
        maxSizeInMB = maxFileSizeInMB;
      } else {
        maxSizeInMB = maxMediaSizeInMB;
      }

      if (fileSizeInMB > maxSizeInMB) {
        _inProcess.value = false;
        Helper.showSnackBarMessage(
          context: context,
          text: (source == MediaSource.file)
              ? "${AppLocalizations.of(context)!.mDiscussionFileSizeError(maxFileSizeInMB)}"
              : "${AppLocalizations.of(context)!.mDiscussionMediaSizeError(maxMediaSizeInMB)}",
          bgColor: AppColors.negativeLight,
        );
        return;
      }

      widget.uploadCallback(
          {"filetype": selectedMediaType, "file": File(media.path)});
      _inProcess.value = false;
    } else {
      _inProcess.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return (widget.allowAllMedia) ? allMedial() : imageMedia();
  }

  Widget allMedial() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        imageMedia(),
        // _uploadButtonView(
        //     icon: Icon(
        //       Icons.video_collection_outlined,
        //       size: 24.w,
        //       color: widget.enableVideoUpload ? Color.fromRGBO(132, 88, 255, 1) : Color.fromRGBO(132, 88, 255, 1).withValues(alpha: 0.3),
        //     ),
        //     onTap: () {
        //       if (widget.enableVideoUpload) {
        //         FocusScope.of(context).unfocus();
        //         selectedMediaType = MediaSource.video;
        //         _getMedia(MediaSource.video);
        //       }
        //     }
        // ),
        _uploadButtonView(
            icon: Icon(
              Icons.description_outlined,
              size: 24.w,
              color: widget.enableFileUpload
                  ? Color.fromRGBO(132, 88, 255, 1)
                  : Color.fromRGBO(132, 88, 255, 1).withValues(alpha: 0.3),
            ),
            onTap: () {
              if (widget.enableFileUpload) {
                FocusScope.of(context).unfocus();
                selectedMediaType = MediaSource.file;
                _getMedia(MediaSource.file);
              }
            }),
      ],
    );
  }

  Widget imageMedia() {
    return _uploadButtonView(
        icon: Icon(
          Icons.image_outlined,
          size: 24.w,
          color: widget.enableImageUpload
              ? Color.fromRGBO(132, 88, 255, 1)
              : Color.fromRGBO(132, 88, 255, 1).withValues(alpha: 0.3),
        ),
        onTap: () {
          if (widget.enableImageUpload) {
            FocusScope.of(context).unfocus();
            selectedMediaType = MediaSource.image;
            _getMedia(MediaSource.image);
          }
        });
  }

  Widget _uploadButtonView({required Widget icon, required Function onTap}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8).r,
      child: InkWell(
          onTap: () {
            onTap();
          },
          child: icon),
    );
  }
}
