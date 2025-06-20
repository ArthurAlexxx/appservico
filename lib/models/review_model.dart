class Review {
  final String author;
  final String comment;
  final int rating;
  final DateTime date;

  Review({
    required this.author,
    required this.comment,
    required this.rating,
    required this.date,
  });

  // Para salvar em banco de dados (ex: Firebase)
  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'comment': comment,
      'rating': rating,
      'date': date.toIso8601String(),
    };
  }

  // Para recuperar do banco de dados
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      author: map['author'] ?? '',
      comment: map['comment'] ?? '',
      rating: map['rating'] ?? 0,
      date: DateTime.parse(map['date']),
    );
  }
}
