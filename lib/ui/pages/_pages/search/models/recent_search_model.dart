class RecentSearchModel {
  final List<String> searchCategory;
  final String userId;
  final String nlpSearchQuery;
  final String searchQuery;
  final int? timestamp;

  RecentSearchModel({
    required this.searchCategory,
    required this.userId,
    required this.nlpSearchQuery,
    required this.searchQuery,
    this.timestamp,
  });

  factory RecentSearchModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchModel(
        searchCategory: (json['search_category'] as List?)
                ?.map((e) => e?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList() ??
            [],
        userId: json['user_id']?.toString() ?? '',
        nlpSearchQuery: json['nlp_search_query']?.toString() ?? '',
        searchQuery: json['search_query']?.toString() ?? '',
        timestamp: json['timestamp'] == null
            ? null
            : (json['timestamp'] is int
                ? json['timestamp']
                : int.tryParse(json['timestamp']?.toString() ?? '')));
  }

  Map<String, dynamic> toJson() {
    return {
      'search_category': searchCategory,
      'user_id': userId,
      'nlp_search_query': nlpSearchQuery,
      'search_query': searchQuery,
      'timestamp': timestamp,
    };
  }
}
