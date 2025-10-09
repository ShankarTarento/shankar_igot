import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/resource_details_screen/widgets/custom_pdf_viewer.dart';
import 'package:igot_ui_components/ui/widgets/resource_details_screen/widgets/custom_video_player.dart';
import 'package:igot_ui_components/utils/fade_route.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_resource_details.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/widgets/custom_youtube_player.dart';

class ResourcePlayer extends StatefulWidget {
  final ResourceDetails resourceDetails;
  final int? startAt;

  const ResourcePlayer({
    super.key,
    required this.resourceDetails,
    this.startAt,
  });

  @override
  State<ResourcePlayer> createState() => _ResourcePlayerState();
}

class _ResourcePlayerState extends State<ResourcePlayer> {
  @override
  Widget build(BuildContext context) {
    return _buildPlayer();
  }

  Widget _buildPlayer() {
    final mimeType = widget.resourceDetails.mimeType ?? '';

    switch (mimeType) {
      case EMimeTypes.youtubeLink:
      case EMimeTypes.externalLink:
        return _buildYoutubeLinkPlayer();

      case EMimeTypes.mp4:
        return CustomVideoPlayer(
          startVideoAt: widget.startAt,
          isAudio: false,
          videoUrl: widget.resourceDetails.artifactUrl ?? '',
        );

      case EMimeTypes.pdf:
        return _buildPdfPlayer();

      case EMimeTypes.mp3:
        return CustomVideoPlayer(
          isAudio: true,
          videoUrl: widget.resourceDetails.artifactUrl ?? '',
        );

      default:
        return const Center();
    }
  }

  Widget _buildYoutubeLinkPlayer() {
    return Container(
      height: 215.w,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8).r,
        color: Colors.black,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Open Youtube",
            style: GoogleFonts.lato(
              color: ModuleColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              letterSpacing: 0.25,
            ),
          ),
          SizedBox(height: 12.h),
          _buildOpenButton(
            iconAsset: 'assets/img/link.svg',
            iconColor: ModuleColors.greys87,
            text: "Open",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomYoutubePlayer(
                    updateContentProgress: (_) {},
                    url: widget.resourceDetails.artifactUrl ?? '',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPdfPlayer() {
    return Container(
      height: 215.w,
      width: 1.sw,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8).r,
        color: Colors.black,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Open PDF",
            style: GoogleFonts.lato(
              color: ModuleColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              letterSpacing: 0.25,
            ),
          ),
          SizedBox(height: 12.h),
          _buildOpenButton(
            iconAsset: 'assets/img/pdf.svg',
            iconColor: ModuleColors.greys87,
            text: "Open",
            onTap: () {
              Navigator.push(
                context,
                FadeRoute(
                  page: CustomPdfPlayer(
                    initialPage: widget.startAt,
                    pdfUrl: widget.resourceDetails.artifactUrl ?? '',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOpenButton({
    required String iconAsset,
    required Color iconColor,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6).r,
        decoration: BoxDecoration(
          color: ModuleColors.orangeTourText,
          borderRadius: BorderRadius.circular(63).r,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconAsset,
              package: "igot_ui_components",
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              height: 24.r,
              width: 24.r,
            ),
            SizedBox(width: 6.w),
            Text(
              text,
              style: GoogleFonts.lato(
                color: ModuleColors.profilebgGrey,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                letterSpacing: 0.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
