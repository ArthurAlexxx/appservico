class Review {
  final String author;
  final String workerId;
  final String comment;
  final int rating;
  final DateTime date;

  Review({
    required this.author,
    required this.workerId,
    required this.comment,
    required this.rating,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'workerId': workerId,
      'comment': comment,
      'rating': rating,
      'date': date.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      author: map['author'] ?? '',
      workerId: map['workerId'] ?? '',
      comment: map['comment'] ?? '',
      rating: map['rating'] ?? 0,
      date: DateTime.parse(map['date']),
    );
  }
}
