class InternetSearchResponse {
  final String queryId;
  final String query;
  final String answer;
  final List<Result> results;

  InternetSearchResponse({
    required this.queryId,
    required this.query,
    required this.answer,
    required this.results,
  });

  factory InternetSearchResponse.fromJson(Map<String, dynamic> json) {
    return InternetSearchResponse(
      queryId: json['query_id'] as String,
      query: json['query'] as String,
      answer: json['answer'] as String,
      results: (json['results'] as List)
          .map((item) => Result.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'query_id': queryId,
        'query': query,
        'answer': answer,
        'results': results.map((r) => r.toJson()).toList(),
      };
}

class Result {
  final String title;
  final String snippet;
  final String url;
  final String sourceName;

  Result({
    required this.title,
    required this.snippet,
    required this.url,
    required this.sourceName,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      title: json['title'] as String,
      snippet: json['snippet'] as String,
      url: json['url'] as String,
      sourceName: json['source_name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'snippet': snippet,
        'url': url,
        'source_name': sourceName,
      };
}
