import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_tour/tour_video_progress_slider.dart';
import 'package:smooth_video_progress/smooth_video_progress.dart';
import 'package:video_player/video_player.dart';

class DiscussionVideoPlayer extends StatefulWidget {
  final String mediaUrl;
  final double height;
  final double width;
  DiscussionVideoPlayer({
    required this.mediaUrl,
    required this.height,
    required this.width,
  });
  @override
  DiscussionVideoPlayerState createState() => DiscussionVideoPlayerState();
}

class DiscussionVideoPlayerState extends State<DiscussionVideoPlayer> {
  late VideoPlayerController _videoController;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    initializeChewiePlayer();
  }

  Future<void> initializeChewiePlayer() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.mediaUrl),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: false,
      ),
    )..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _videoPlayerView();
  }

  Widget _videoPlayerView() {
    return GestureDetector(
      onTap: () {
        if (!_visible) resetVisibility();
      },
      child: Container(
          height: widget.height,
          width: widget.width,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: widget.height,
                  width: widget.width,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border:
                        Border.all(color: AppColors.appBarBackground, width: 1),
                    borderRadius: BorderRadius.circular(5).r,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5).r,
                    child: AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _videoController,
                  builder: (context, value, child) {
                    return GestureDetector(
                      onTap: () {
                        if (_videoController.value.isPlaying) {
                          _videoController.pause();
                        } else {
                          _videoController.play();
                        }
                        //update the variable again to hide action button
                        hideVisibilityAfterSomeTime();
                      },
                      child: Visibility(
                        visible: _visible || !_videoController.value.isPlaying,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Icon(
                          _videoController.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          color: AppColors.grey,
                          size: 50.0.sp,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 0.w,
                  child: Container(
                    width: widget.width - 32.w,
                    height: 22.w,
                    child: SmoothVideoProgress(
                      controller: _videoController,
                      builder: (context, position, duration, _) =>
                          VideoProgressSlider(
                        position: position,
                        duration: duration,
                        controller: _videoController,
                        swatch: AppColors.primaryThree,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  hideVisibilityAfterSomeTime() {
    Future.delayed(const Duration(seconds: 3), () {
      if (this.mounted) {
        setState(() {
          _visible = false; //update the variable to hide action button
        });
      }
    });
  }

  resetVisibility() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (this.mounted) {
        setState(() {
          _visible = true; //update the variable to show action button
        });
      }
    });
    //update the variable again to hide action button
    hideVisibilityAfterSomeTime();
  }
}
