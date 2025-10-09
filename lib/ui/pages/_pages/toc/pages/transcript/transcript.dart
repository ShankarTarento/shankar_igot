import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/transcription_data_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/transcript/repository/transcript_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/transcript/widgets/transcript_dropdown.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/transcript/widgets/transcript_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/transcript/widgets/transcription_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Transcript extends StatefulWidget {
  final Function(int) startAt;
  final String resourceId;

  const Transcript(
      {super.key, required this.startAt, required this.resourceId});

  @override
  State<Transcript> createState() => _TranscriptState();
}

class _TranscriptState extends State<Transcript> {
  late SubtitleUrl _selectedSubtitle;
  late Future<TranscriptionResponse?> transcriptionDataFuture;
  @override
  void initState() {
    getTranscriptionData();
    super.initState();
  }

  void getTranscriptionData() async {
    transcriptionDataFuture =
        TranscriptRepository.getSubtitleAndTranscriptionData(
      resourceId: widget.resourceId,
    );

    // Wait for the future to resolve
    final transcriptionData = await transcriptionDataFuture;

    if (transcriptionData != null) {
      List<SubtitleUrl> subtitles = transcriptionData.subtitleUrls;

      // Set the selected subtitle
      _selectedSubtitle = getDefaultSubtitle(subtitles);

      // If this is in a StatefulWidget, don't forget to call setState
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0).r,
      child: FutureBuilder<TranscriptionResponse?>(
          future: transcriptionDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return TranscriptSkeleton();
            }
            if (snapshot.data != null) {
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12).r,
                    decoration: BoxDecoration(
                      color: AppColors.learnerTipsColor2,
                      borderRadius: BorderRadius.circular(8).r,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.mTranscriptDisclaimer,
                      style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 12.w),
                  TranscriptDropdown(
                    initialSubtitle: _selectedSubtitle,
                    subtitleUrls: snapshot.data!.subtitleUrls,
                    onSelected: (SubtitleUrl selected) {
                      setState(() {
                        _selectedSubtitle = selected;
                      });
                    },
                  ),
                  SizedBox(height: 12.w),
                  TranscriptionView(
                    startAt: widget.startAt,
                    subtitleUrl: _selectedSubtitle,
                  )
                ],
              );
            }
            return Center(
                child: Padding(
              padding: EdgeInsets.only(top: 70.0).r,
              child: Text(AppLocalizations.of(context)!.mNoTranscriptAvailable,
                  style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500)),
            ));
          }),
    );
  }

  SubtitleUrl getDefaultSubtitle(List<SubtitleUrl> subtitles) {
    try {
      return subtitles.firstWhere(
        (subtitle) => subtitle.language.toLowerCase().contains('english'),
      );
    } catch (_) {
      try {
        return subtitles.firstWhere(
          (subtitle) => subtitle.language.toLowerCase().contains('hindi'),
        );
      } catch (_) {
        return subtitles[0];
      }
    }
  }
}
