class AIConfigFlags {
  final bool iGOTAI;
  final bool aiTutor;
  final bool transcription;
  final bool useResourceId;
  AIConfigFlags({
    required this.iGOTAI,
    required this.aiTutor,
    required this.transcription,
    required this.useResourceId,
  });

  factory AIConfigFlags.fromJson(Map<String, dynamic> json) {
    return AIConfigFlags(
      iGOTAI: json['iGOTAI'] ?? false,
      aiTutor: json['aiTutor'] ?? false,
      transcription: json['transcription'] ?? false,
      useResourceId: json['useResourceId'] ?? true,
    );
  }
}
