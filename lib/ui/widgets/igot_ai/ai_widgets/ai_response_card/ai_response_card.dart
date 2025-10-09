import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/helper/ai_chat_bot_helper.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_chat_bot_response.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_bot_icon.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_response_card/widgets/retrived_chunk_card.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_response_card/widgets/search_internet_card.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_response_feedback.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AiResponseCard extends StatefulWidget {
  final Message response;
  final ValueChanged<Message> onFeedbackChanged;

  final Function({required RetrievedChunk data, required BuildContext context})
      onTap;
  final Function()? searchInternet;

  const AiResponseCard(
      {super.key,
      required this.response,
      required this.onTap,
      required this.onFeedbackChanged,
      this.searchInternet});

  @override
  State<AiResponseCard> createState() => _AiResponseCardState();
}

class _AiResponseCardState extends State<AiResponseCard> {
  bool isExpanded = false;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResponseContainer(context),
              if (widget.response.aiChatBotResponse!.retrievedChunks.isEmpty &&
                  !widget.response.aiChatBotResponse!.answer
                      .toLowerCase()
                      .startsWith('welcome'))
                SearchInternetCard(
                  searchInternet: widget.searchInternet,
                ),
              ..._buildRetrievedChunks(context),
              if (!widget.response.aiChatBotResponse!.retrievedChunks.isEmpty)
                AiResponseFeedback(
                  onFeedbackChanged: widget.onFeedbackChanged,
                  message: widget.response,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponseContainer(BuildContext context) {
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
            duration: const Duration(milliseconds: 200),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.4,
                  color: Colors.black,
                ),
                children: AiChatBotHelper.parseMarkdownLite(
                    widget.response.aiChatBotResponse!.answer),
              ),
              maxLines: isExpanded ? null : 5,
              overflow: TextOverflow.fade,
            ),
          ),
          SizedBox(height: 8.h),
          if (widget.response.aiChatBotResponse!.answer.length > 200)
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(
                isExpanded
                    ? AppLocalizations.of(context)!.mStaticShowLess
                    : AppLocalizations.of(context)!.mStaticShowMore,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: AppColors.darkBlue,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildRetrievedChunks(BuildContext context) {
    return List.generate(
      widget.response.aiChatBotResponse!.retrievedChunks.length,
      (index) => RetrievedChunkCard(
        data: widget.response.aiChatBotResponse!.retrievedChunks[index],
        onTap: widget.onTap,
      ),
    );
  }
}
