class Activity {
  final String emoji;
  final String title;
  final String duration;
  final String description;

  const Activity({
    required this.emoji,
    required this.title,
    required this.duration,
    required this.description,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        emoji: (json['emoji'] as String?) ?? '🎮',
        title: (json['title'] as String?) ?? '',
        duration: (json['duration'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
      );
}
