class SessionAnswer {
  const SessionAnswer({
    required this.questionId,
    required this.text,
    required this.inputType,
    required this.answeredAt,
  });

  final String questionId;
  final String text;
  final String inputType; // 'voice' | 'text'
  final DateTime answeredAt;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'text': text,
        'inputType': inputType,
        'answeredAt': answeredAt.toIso8601String(),
      };
}
