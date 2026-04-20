class SessionQuestion {
  const SessionQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.category,
  });

  final String id;
  final String text;
  final String type;
  final String category;

  factory SessionQuestion.fromJson(Map<String, dynamic> json) =>
      SessionQuestion(
        id: json['id'] as String,
        text: json['text'] as String,
        type: json['type'] as String,
        category: json['category'] as String,
      );
}
