import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_chat_bot_response.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_bot_icon.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_response_feedback.dart';

class InternetSearchResponseCard extends StatefulWidget {
  final Message response;

  const InternetSearchResponseCard({super.key, required this.response});

  @override
  State<InternetSearchResponseCard> createState() =>
      _InternetSearchResponseCardState();
}

class _InternetSearchResponseCardState extends State<InternetSearchResponseCard>
    with TickerProviderStateMixin {
  bool isExpanded = false;

  static const int _maxPreviewLines = 5;
  static const int _showMoreThreshold = 200;
  static const Duration _animationDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiBotIcon(),
          SizedBox(width: 8.w),
          Column(
            children: [
              _buildMessageBubble(context),
              AiResponseFeedback(
                onFeedbackChanged: (value) {},
                message: widget.response,
                isInternetResponse: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    final showShowMore = widget.response.internetSearchResponse!.answer.length >
        _showMoreThreshold;
    return Container(
      constraints: BoxConstraints(maxWidth: 0.65.sw),
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.blue209,
        borderRadius: BorderRadius.only(
          topLeft: Radius.zero,
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ).r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            child: Text(
              widget.response.internetSearchResponse!.answer,
              maxLines: isExpanded ? null : _maxPreviewLines,
              overflow:
                  isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                color: Colors.black,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
          if (showShowMore) ...[
            SizedBox(height: 8.h),
            _buildShowMoreLess(context),
          ],
        ],
      ),
    );
  }

  Widget _buildShowMoreLess(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: Text(
        isExpanded
            ? localizations.mStaticShowLess
            : localizations.mStaticShowMore,
        style: TextStyle(
          decoration: TextDecoration.underline,
          color: AppColors.darkBlue,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
