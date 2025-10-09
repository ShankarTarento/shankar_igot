import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/feedback_overlay_card.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_chat_bot_response.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/repository/igot_ai_repository.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class AiResponseFeedback extends StatefulWidget {
  final bool isInternetResponse;
  final Message message;
  final ValueChanged<Message> onFeedbackChanged;

  const AiResponseFeedback({
    super.key,
    this.isInternetResponse = false,
    required this.message,
    required this.onFeedbackChanged,
  });

  @override
  State<AiResponseFeedback> createState() => _AiResponseFeedbackState();
}

class _AiResponseFeedbackState extends State<AiResponseFeedback> {
  bool isThumbsUpSelected = false;
  bool isThumbsDownSelected = false;
  bool isSubmitting = false;

  final gradient = const LinearGradient(
    colors: [AppColors.primaryOne, AppColors.darkBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    isThumbsUpSelected = widget.message.isLiked == true;
    isThumbsDownSelected = widget.message.isLiked == false;
  }

  Future<void> _submitFeedback({
    required String feedback,
    required bool isLiked,
    String rating = "5",
  }) async {
    final status = await IgotAiRepository.submitFeedback(
      feedback: feedback,
      queryId: widget.message.aiChatBotResponse?.queryId ?? '',
      isLiked: isLiked,
      rating: rating,
    );

    if (status?.toLowerCase() == "success") {
      Helper.showSnackBarMessage(
        context: context,
        text: AppLocalizations.of(context)!.mFeedbackSubmitted,
        bgColor: AppColors.darkBlue,
      );
    }
  }

  Future<void> _handleThumbsUp() async {
    setState(() => isSubmitting = true);
    await _submitFeedback(feedback: "accurate", isLiked: true, rating: "5");

    widget.onFeedbackChanged(widget.message.copyWith(isLiked: true));

    setState(() {
      isSubmitting = false;
      isThumbsUpSelected = true;
      isThumbsDownSelected = false;
    });
  }

  void _handleThumbsDown() {
    setState(() => isSubmitting = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildFeedbackDialog(pcontext: context),
    );
  }

  AlertDialog _buildFeedbackDialog({required BuildContext pcontext}) {
    final controller = TextEditingController();
    bool isLocalSubmitting = false;

    return AlertDialog(
      content: SizedBox(
        height: 260.h,
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> _handleSubmit() async {
              Navigator.pop(context);

              setStateDialog(() => isLocalSubmitting = true);
              await _submitFeedback(
                feedback: controller.text,
                isLiked: false,
                rating: "0",
              );
              widget.onFeedbackChanged(widget.message.copyWith(isLiked: false));
              if (mounted) {
                setState(() {
                  isThumbsDownSelected = true;
                  isThumbsUpSelected = false;
                  isSubmitting = false;
                });
              }
            }

            return isLocalSubmitting
                ? const Center(child: CircularProgressIndicator())
                : FeedbackOverlayCard(
                    title: AppLocalizations.of(pcontext)!
                        .mIgotAIFeedbackIsImportant,
                    submitText: AppLocalizations.of(pcontext)!.mStaticSubmit,
                    cancelText: AppLocalizations.of(pcontext)!.mStaticCancel,
                    textFieldHint:
                        AppLocalizations.of(pcontext)!.mIgotAIEnterFeedback,
                    isVisible: true,
                    color: Colors.white,
                    submitBtnColor: AppColors.darkBlue,
                    submitTextColor: Colors.white,
                    cancelBtnColor: AppColors.darkBlue,
                    borderColor: Colors.black,
                    titleColor: AppColors.greys87,
                    margin: 0,
                    textAlign: TextAlign.left,
                    submitPressed: (_) => _handleSubmit(),
                    cancelPressed: () {
                      isSubmitting = false;
                      setState(() {});
                      Navigator.pop(context);
                    },
                  );
          },
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required bool isSelected,
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        isSelected ? selectedIcon : unselectedIcon,
        size: 16.sp,
        color: isSelected ? selectedColor : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageText = widget.isInternetResponse
        ? AppLocalizations.of(context)!.mInternetMessage
        : AppLocalizations.of(context)!.mAiGeneratedMessage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset("assets/img/ai_loader.png", height: 24.w, width: 24.w),
        SizedBox(width: 8.w),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => gradient.createShader(bounds),
          child: Text(
            messageText,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 8.w),
        if (isSubmitting)
          SizedBox(
            height: 16.sp,
            width: 16.sp,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        else ...[
          _buildIconButton(
            isSelected: isThumbsUpSelected,
            selectedIcon: Icons.thumb_up_alt,
            unselectedIcon: Icons.thumb_up_alt_outlined,
            selectedColor: Colors.green,
            onTap: _handleThumbsUp,
          ),
          SizedBox(width: 16.w),
          _buildIconButton(
            isSelected: isThumbsDownSelected,
            selectedIcon: Icons.thumb_down_alt,
            unselectedIcon: Icons.thumb_down_alt_outlined,
            selectedColor: Colors.red,
            onTap: _handleThumbsDown,
          ),
        ],
      ],
    );
  }
}
