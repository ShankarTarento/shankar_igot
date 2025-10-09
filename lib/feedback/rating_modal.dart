
class Rating {
  final String userId;
  final double rating;

  Rating({
    required this.userId,
    required this.rating,
  });

  Map<String, Object> toMap() {
    return {
      'user_id': userId,
      'user_rating': rating,
    };
  }
}
