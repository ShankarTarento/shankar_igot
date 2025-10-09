import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/helper/ai_chat_bot_helper.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_chat_bot_response.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_response_card/widgets/ai_response_container.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_response_card/widgets/collection_container.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RetrievedChunkCard extends StatelessWidget {
  final RetrievedChunk data;
  final Function({required RetrievedChunk data, required BuildContext context})
      onTap;

  const RetrievedChunkCard(
      {super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    switch (data.mimeType) {
      case EMimeTypes.mp4:
        return _buildVideoCard(context);
      case EMimeTypes.pdf:
        return _buildPdfCard(context);
      case EMimeTypes.collection:
        return _buildCollectionCard(context);
      default:
        return const SizedBox();
    }
  }

  Widget _buildVideoCard(BuildContext context) {
    return AiResponseContainer(
      data: data,
      icon: _buildVideoIcon(),
      pageDetails: _buildVideoDetails(context),
      copyToClipboard: () => _copyLink(data.artifactUrl, context),
      onTap: () => onTap(data: data, context: context),
    );
  }

  Widget _buildPdfCard(BuildContext context) {
    return AiResponseContainer(
      data: data,
      icon: _buildPdfIcon(),
      pageDetails: _buildPdfDetails(context),
      copyToClipboard: () => _copyLink(data.artifactUrl, context),
      onTap: () => onTap(data: data, context: context),
    );
  }

  Widget _buildCollectionCard(BuildContext context) {
    return CollectionContainer(
      data: data,
      onTap: onTap,
      copyToClipboard: () => _copyLink(data.artifactUrl, context),
    );
  }

  Widget _buildVideoIcon() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blue127,
        borderRadius: BorderRadius.circular(4).r,
      ),
      height: 50.w,
      width: 65.w,
      child: Icon(
        Icons.play_circle_outline_outlined,
        size: 30.sp,
        color: AppColors.darkBlue,
      ),
    );
  }

  Widget _buildVideoDetails(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.access_time, color: Colors.white, size: 14),
        const SizedBox(width: 2),
        Text(
          AiChatBotHelper.getDurationRange(
            int.parse(data.contentStart ?? "0"),
            int.parse(data.contentEnd ?? "0"),
          ),
          style: GoogleFonts.lato(fontSize: 10, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPdfIcon() {
    return ImageWidget(
      imageUrl: 'assets/img/blue_pdf.png',
      height: 65.w,
      width: 60.w,
      boxFit: BoxFit.cover,
    );
  }

  Widget _buildPdfDetails(BuildContext context) {
    return data.contentStart != null && data.contentStart!.trim().isNotEmpty
        ? Row(
            children: [
              Icon(Icons.insert_drive_file_sharp,
                  color: Colors.white, size: 14.sp),
              SizedBox(width: 2.w),
              Text(
                "${data.contentStart} -${data.contentEnd} page",
                style: GoogleFonts.lato(fontSize: 10.sp, color: Colors.white),
              ),
            ],
          )
        : const SizedBox();
  }

  void _copyLink(String link, BuildContext context) {
    Clipboard.setData(ClipboardData(text: link));
    Helper.showSnackBarMessage(
      context: context,
      text: AppLocalizations.of(context)!.mContentSharePageLinkCopied,
      bgColor: AppColors.darkBlue,
    );
  }
}
