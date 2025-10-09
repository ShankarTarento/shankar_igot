import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_chat_bot_response.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_response_card/ai_response_card.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/error_message_card.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/internet_search_card/internet_search_card.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/message_card.dart';

class MessageScreen extends StatefulWidget {
  final List<Message> messages;
  final Function(Message) onFeedbackChanged;
  final Function({required RetrievedChunk data, required BuildContext context})
      onTap;
  final Function()? searchInternet;
  final Function() retrySearch;

  const MessageScreen({
    super.key,
    required this.messages,
    required this.onTap,
    this.searchInternet,
    required this.retrySearch,
    required this.onFeedbackChanged,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 60.w),
        ...widget.messages
            .map((message) => _buildMessageWidget(message))
            .toList(),
      ],
    );
  }

  Widget _buildMessageWidget(Message message) {
    if (message.userMessage != null) {
      return _buildRightAlignedWidget(
        MessageCard(message: message.userMessage!),
      );
    }

    if (message.isErrorMessage) {
      return ErrorMessageCard(
        onRetry: widget.retrySearch,
      );
    }

    if (message.aiChatBotResponse != null) {
      return AiResponseCard(
        onFeedbackChanged: widget.onFeedbackChanged,
        searchInternet: widget.searchInternet,
        onTap: widget.onTap,
        response: message,
      );
    }

    if (message.internetSearchResponse != null) {
      return _buildRightAlignedWidget(
        InternetSearchResponseCard(
          response: message,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildRightAlignedWidget(Widget child) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: child,
      ),
    );
  }
}
