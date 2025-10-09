import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/transcription_data_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/transcript/model/transcript_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/transcript/repository/transcript_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/transcript/widgets/transcript_skeleton.dart';
import 'package:provider/provider.dart';

class TranscriptionView extends StatefulWidget {
  final SubtitleUrl subtitleUrl;
  final Function(int) startAt;

  const TranscriptionView({
    super.key,
    required this.subtitleUrl,
    required this.startAt,
  });

  @override
  State<TranscriptionView> createState() => _TranscriptionViewState();
}

class _TranscriptionViewState extends State<TranscriptionView> {
  late Future<List<VttCaption>> _vttCaptionsFuture;

  @override
  void initState() {
    super.initState();
    _vttCaptionsFuture =
        TranscriptRepository().fetchAndParseWebVtt(widget.subtitleUrl.uri);
  }

  @override
  void didUpdateWidget(covariant TranscriptionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subtitleUrl != widget.subtitleUrl) {
      _loadCaptions();
    }
  }

  void _loadCaptions() {
    _vttCaptionsFuture =
        TranscriptRepository().fetchAndParseWebVtt(widget.subtitleUrl.uri);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentSecond = context.watch<TranscriptRepository>().currentSecond;
    final currentTime = Duration(seconds: currentSecond.floor());

    return FutureBuilder<List<VttCaption>>(
      future: _vttCaptionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: TranscriptSkeleton());
        }

        if (snapshot.data == null ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return Center(
              child: Padding(
            padding: EdgeInsets.only(top: 70.0).r,
            child: Text('No transcript available'),
          ));
        }

        final captions = snapshot.data!;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: captions.map((caption) {
              final isActive =
                  currentTime >= caption.start && currentTime <= caption.end;
              return _buildCaptionRow(caption, isActive);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCaptionRow(VttCaption caption, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimestamp(caption),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              caption.text,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
                backgroundColor: isActive ? Colors.yellow : Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(VttCaption caption) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildClickableTime(caption.start),
        const Text(' - '),
        _buildClickableTime(caption.end),
      ],
    );
  }

  Widget _buildClickableTime(Duration time) {
    return InkWell(
      onTap: () => widget.startAt(time.inSeconds),
      child: Text(
        _formatDuration(time),
        style: GoogleFonts.lato(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.darkBlue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final time = duration.toString().split('.').first;
    return time;
  }
}
