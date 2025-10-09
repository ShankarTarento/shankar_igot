import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_chat_bot_response.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/internet_search_response.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/services/igot_ai_services.dart';

class IgotAiRepository {
  static Future<Message> searchIgotPlatform({required String query}) async {
    try {
      //return Message(isErrorMessage: true);
      final response = await IgotAiServices.searchIgotPlatform(query);

      if (response.statusCode != 200) {
        debugPrint('Failed to load data. Status code: ${response.statusCode}');
        return Message(isErrorMessage: true);
      }

      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes));

      final aiResponse = AiChatBotResponse.fromJson(data);

      return Message(aiChatBotResponse: aiResponse);
    } catch (e, stackTrace) {
      debugPrint('Error fetching chatbot data: $e\n$stackTrace');
      return Message(isErrorMessage: true);
    }
  }

  static Future<Message> getDataFromInternet({required String query}) async {
    try {
      final response = await IgotAiServices.fetchChatbotResponse(query: query);

      if (response != null && response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));

        final searchResponse = InternetSearchResponse.fromJson(data);

        return Message(internetSearchResponse: searchResponse);
      } else {
        return Message(isErrorMessage: true);
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching data from internet: $e\n$stackTrace');
      return Message(isErrorMessage: true);
    }
  }

  static Future<String?> submitFeedback({
    required String queryId,
    required bool isLiked,
    required String rating,
    required String feedback,
  }) async {
    try {
      final response = await IgotAiServices.submitFeedback(
        isLiked: isLiked,
        queryId: queryId,
        rating: rating,
        feedback: feedback,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        return data['status'];
      }
    } catch (e, stackTrace) {
      debugPrint('Error submitting feedback: $e\n$stackTrace');
    }
    return null;
  }
}
