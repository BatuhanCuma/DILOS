class SessionTags {
  const SessionTags({
    required this.mood,
    required this.topics,
    required this.energy,
  });

  final String mood;        // 'positive' | 'neutral' | 'negative' | 'anxious' | 'sad' | 'excited'
  final List<String> topics; // ['work', 'relationships', 'health', ...]
  final String energy;      // 'low' | 'medium' | 'high'

  factory SessionTags.fromJson(Map<String, dynamic> json) => SessionTags(
        mood: json['mood'] as String? ?? 'neutral',
        topics: (json['topics'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        energy: json['energy'] as String? ?? 'medium',
      );

  Map<String, dynamic> toJson() => {
        'mood': mood,
        'topics': topics,
        'energy': energy,
      };

  static const SessionTags fallback = SessionTags(
    mood: 'neutral',
    topics: [],
    energy: 'medium',
  );
}
