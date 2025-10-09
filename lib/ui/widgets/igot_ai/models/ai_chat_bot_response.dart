import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/internet_search_response.dart';

class Message {
  final String? userMessage;
  final AiChatBotResponse? aiChatBotResponse;
  final InternetSearchResponse? internetSearchResponse;
  final bool isErrorMessage;
  final bool? isLiked;

  Message({
    this.aiChatBotResponse,
    this.userMessage,
    this.internetSearchResponse,
    this.isLiked,
    this.isErrorMessage = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      userMessage: json['userMessage'],
      aiChatBotResponse: json['aiChatBotResponse'] != null
          ? AiChatBotResponse.fromJson(json['aiChatBotResponse'])
          : null,
      internetSearchResponse: json['internetSearchResponse'] != null
          ? InternetSearchResponse.fromJson(json['internetSearchResponse'])
          : null,
      isLiked: json['isLiked'],
      isErrorMessage: json['isErrorMessage'] ?? false,
    );
  }

  Message copyWith({
    String? userMessage,
    AiChatBotResponse? aiChatBotResponse,
    InternetSearchResponse? internetSearchResponse,
    bool? isErrorMessage,
    bool? isLiked,
  }) {
    return Message(
      userMessage: userMessage ?? this.userMessage,
      aiChatBotResponse: aiChatBotResponse ?? this.aiChatBotResponse,
      internetSearchResponse:
          internetSearchResponse ?? this.internetSearchResponse,
      isErrorMessage: isErrorMessage ?? this.isErrorMessage,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class AiChatBotResponse {
  final String answer;
  final List<RetrievedChunk> retrievedChunks;
  final String queryId;

  AiChatBotResponse({
    required this.answer,
    required this.retrievedChunks,
    required this.queryId,
  });

  factory AiChatBotResponse.fromJson(Map json) {
    final chunks = json['RetrievedChunks'] ?? json['retrievedChunks'] ?? [];

    return AiChatBotResponse(
      answer: json['answer'] ?? '',
      queryId: json['query_id'] ?? '',
      retrievedChunks: (chunks is List)
          ? chunks.map((e) => RetrievedChunk.fromJson(e)).toList()
          : [],
    );
  }

  AiChatBotResponse copyWith({
    String? answer,
    List<RetrievedChunk>? retrievedChunks,
    bool? showSearchButton,
    String? queryId,
  }) {
    return AiChatBotResponse(
      queryId: queryId ?? this.queryId,
      answer: answer ?? this.answer,
      retrievedChunks: retrievedChunks ?? this.retrievedChunks,
    );
  }
}

class RetrievedChunk {
  final String identifier;
  final String name;
  final String description;
  final String contentType;
  final String artifactUrl;
  final String mimeType;
  final String? contentStart;
  final String? contentEnd;

  RetrievedChunk({
    required this.identifier,
    required this.name,
    required this.description,
    required this.contentType,
    required this.artifactUrl,
    required this.mimeType,
    this.contentStart,
    this.contentEnd,
  });

  factory RetrievedChunk.fromJson(Map<String, dynamic> json) {
    return RetrievedChunk(
      identifier: json['Identifier'] ?? '',
      name: json['Name'] ?? '',
      description: json['Description'] ?? '',
      contentType: json['ContentType'] ?? '',
      artifactUrl: json['ArtifactURL'] ?? '',
      mimeType: json['mimeType'] ?? json['MimeType'] ?? '',
      contentStart: json['ContentStart']?.toString() ??
          json['contentStart']?.toString() ??
          '',
      contentEnd: json['ContentEnd']?.toString() ?? '',
    );
  }
}
