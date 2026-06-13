class HeartCard {
  final String question;
  final String groupType;
  final String? followUp;

  const HeartCard({
    required this.question,
    required this.groupType,
    this.followUp,
  });

  factory HeartCard.fromJson(Map<String, dynamic> json) => HeartCard(
        question: (json['question'] as String?) ?? '',
        groupType: (json['groupType'] as String?) ?? 'mixed',
        followUp: json['followUp'] as String?,
      );

  HeartCard withFollowUp(String? fu) =>
      HeartCard(question: question, groupType: groupType, followUp: fu);
}
