import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/page_loader.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../constants/index.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final String? description;
  const VideoPlayerWidget(
      {super.key, required this.videoUrl, this.title, this.description});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  bool _isVideoInitialized = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _videoController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown
        ],
        autoPlay: false,
        looping: false,
        showOptions: false,
        allowedScreenSleep: false,
        allowFullScreen: true,
      );
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      setState(() {
        _isError = true;
      });
    }
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200.w,
            width: 1.sw,
            child: Center(
              child: _isError
                  ? Text(AppLocalizations.of(context)!.mStaticErrorMessage,
                      style: TextStyle(color: AppColors.greys))
                  : _isVideoInitialized
                      ? Chewie(controller: _chewieController)
                      : PageLoader(),
            ),
          ),
          SizedBox(
            height: 16.h,
          ),
          Text(
            widget.title ?? '',
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          SizedBox(
            height: 8.h,
          ),
          Text(
            widget.description ?? '',
            style: GoogleFonts.lato(fontSize: 14.sp),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
