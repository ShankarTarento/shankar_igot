import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_chat_bot_response.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_chat_bot_message_field.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_loading_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/message_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IgotAiTutor extends StatefulWidget {
  final Profile? profile;
  final TextEditingController controller;
  final ScrollController scrollController;
  final bool isLoading;
  final List<Message> messages;
  final Function() onSend;
  final Function(RetrievedChunk, BuildContext) onTapCard;
  final Function()? searchInternet;
  final Function(Message) onFeedbackChanged;
  final Function() retrySearch;

  const IgotAiTutor(
      {super.key,
      this.profile,
      required this.controller,
      required this.scrollController,
      required this.isLoading,
      required this.messages,
      required this.onTapCard,
      this.searchInternet,
      required this.onFeedbackChanged,
      required this.retrySearch,
      required this.onSend});

  @override
  State<IgotAiTutor> createState() => _IgotAiTutorState();
}

class _IgotAiTutorState extends State<IgotAiTutor> {
  String? selectedDropdownValue;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/igot_sarthi.png'),
          fit: BoxFit.fill,
          opacity: 0.07,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                  ).r,
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.messages.isEmpty
                            ? _buildWelcomeMessage()
                            : MessageScreen(
                                retrySearch: widget.retrySearch,
                                messages: widget.messages,
                                onTap: ({required context, required data}) {
                                  widget.onTapCard(data, context);
                                },
                                searchInternet: widget.searchInternet,
                                onFeedbackChanged: widget.onFeedbackChanged,
                              ),
                        if (widget.isLoading)
                          AiLoadingWidget(isloading: widget.isLoading),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 80.w),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AiChatBotMessageField(
              isLoading: widget.isLoading,
              controller: widget.controller,
              scrollController: widget.scrollController,
              sendMessage: widget.onSend,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 128.0).r,
      child: Center(
        child: SizedBox(
          width: 0.7.sw,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 0.1.sh),
              Text(
                '${AppLocalizations.of(context)!.mCommonHey} ${widget.profile?.firstName ?? ""}',
                style: GoogleFonts.lato(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.mAiTutorWelcomeText,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void didUpdateWidget(covariant IgotAiTutor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }
}
