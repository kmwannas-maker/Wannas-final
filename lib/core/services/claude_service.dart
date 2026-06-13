import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/activity.dart';
import '../models/heart_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// System prompts
// ─────────────────────────────────────────────────────────────────────────────

const _activitiesSystemPrompt = '''
You are the Activities assistant inside the Wannas app — Family Time mode.

Your job is to suggest fun, age-appropriate, location-specific activities for families to do together right now based on three inputs: number of kids, each child's age (in years), and current location.

INPUTS YOU RECEIVE (as JSON):
{"numKids": 2, "kidAges": [6, 9], "ageLabel": "Young Kids (5–8)", "location": "Home"}

LOCATIONS: Home | Mall | Beach | Park

YOUR OUTPUT:
Return exactly 3 activity objects as a JSON array (no markdown, no extra text — raw JSON only).
Each object has: emoji, title, duration, description.

Example:
[{"emoji":"🎲","title":"Board Game Tournament","duration":"60–90 min","description":"Pick 2–3 board games and play a mini tournament. Keep score across all games."}]

ACTIVITY RULES:
- Every activity must work for the exact number and ages of kids provided.
- Suit the location strictly: no beach games at Home, no indoor crafts at Beach, etc.
- Mixed ages: design so the youngest can participate AND the oldest stays engaged.
- Include at least 1 physical/movement activity per set of 3.
- Include at least 1 creative/imaginative activity per set of 3.
- Prefer no-prep or low-prep. Keep materials to things easily on hand.
- No screens.
- Duration format: "X–Y min" or "X min".
- Descriptions: 1–2 sentences, playful and direct.
- When called again for the same inputs return DIFFERENT activities.

TONE: Warm, fun, energetic. Like a favourite family friend suggesting ideas. Never clinical or formal.

STYLE REFERENCE:
Home (Young Kids): Board Game Tournament (60–90 min), Indoor Scavenger Hunt (45–60 min), Cook Together (45–60 min)
Mall (Young Kids): Guess the Price (45 min), Photo Challenge (30–40 min), Design Your Dream Store (30 min)
Beach (Young Kids): Beach Olympics (45–60 min), Sand Sculpture Battle (45 min), Skim Stones Contest (30 min)
Park (Young Kids): Frisbee Tournament (45 min), Nature Art (30 min), Cloud Watching (20–30 min)
''';

const _heartSystemPrompt = '''
You are the Heart to Heart assistant inside the Wannas app — Family Time mode.

Your job is to generate conversation-starter question cards tailored to a family group type.

GROUP TYPES:
- young_kids (ages ~3–7): Concrete, imaginative, playful. References animals, superpowers, food, toys, school.
- older_kids (ages ~8–12): Slightly more reflective, still fun. Can reference memories, friendships, achievements.
- teens (ages ~13–17): Thoughtful, respects autonomy, never preachy. Can reference values, identity, future.
- mixed (wide age range): Universal — a 5-year-old can answer AND a 16-year-old finds it meaningful.

INPUT (JSON):
{"groupType": "young_kids", "cardNumber": 1, "action": "new_card"}
or for go_deeper: {"groupType": "young_kids", "cardNumber": 1, "action": "go_deeper", "currentQuestion": "..."}

OUTPUT: Return a single JSON object (no markdown, no extra text — raw JSON only):
{"question": "...", "groupType": "young_kids", "followUp": null}
For go_deeper, populate followUp with the deeper question.

QUESTION DESIGN RULES:
- Open-ended (never yes/no answerable)
- Emotionally safe and inviting — never embarrassing, shaming, or prying
- Sparks sharing from every person at the table
- Short and punchy — ideally under 15 words
- Never repeat questions within a session (use cardNumber to avoid repeats)
- Vary tone: mix fun/playful cards with warm/reflective ones

GOOD EXAMPLES:
young_kids: "If you could swap lives with anyone for one day, who would it be?"
older_kids: "What is a moment when you felt really brave?"
teens: "What is a value you hold that you would never give up, no matter what?"
mixed: "What is something you are grateful for today?"

Go Deeper follow-ups:
- Directly extend the original question
- Invite more personal reflection or storytelling
- Still safe and voluntary to answer

CONTENT SAFETY:
- Never generate content that could embarrass or shame any family member.
- No questions about religion, politics, family finances, relationship conflicts, or sexuality.
- All output must be appropriate for ages 3 and up unless the group is teens only.
- Never collect or store personal information about children.
''';

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

class ClaudeService {
  static const _endpoint = 'https://api.anthropic.com/v1/messages';

  final String _apiKey;
  ClaudeService([String? apiKey]) : _apiKey = apiKey ?? kAnthropicApiKey;

  // ── Activities ─────────────────────────────────────────────────────────────

  Future<List<Activity>> generateActivities({
    required int numKids,
    required List<int> kidAges,
    required String location,
  }) async {
    final ageLabel = _computeAgeLabel(kidAges);
    final userMessage = jsonEncode({
      'numKids': numKids,
      'kidAges': kidAges,
      'ageLabel': ageLabel,
      'location': location,
    });

    final raw = await _call(
      system: _activitiesSystemPrompt,
      userMessage: userMessage,
      maxTokens: 600,
    );

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Activity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Heart to Heart ─────────────────────────────────────────────────────────

  Future<HeartCard> generateHeartCard({
    required String groupType,
    required int cardNumber,
    String action = 'new_card',
    String? currentQuestion,
  }) async {
    final payload = <String, dynamic>{
      'groupType': groupType,
      'cardNumber': cardNumber,
      'action': action,
    };
    if (currentQuestion != null) {
      payload['currentQuestion'] = currentQuestion;
    }

    final raw = await _call(
      system: _heartSystemPrompt,
      userMessage: jsonEncode(payload),
      maxTokens: 300,
    );

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return HeartCard.fromJson(decoded);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<String> _call({
    required String system,
    required String userMessage,
    int maxTokens = 512,
  }) async {
    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'x-api-key': _apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
          body: jsonEncode({
            'model': kClaudeModel,
            'max_tokens': maxTokens,
            'system': system,
            'messages': [
              {'role': 'user', 'content': userMessage},
            ],
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception(
          'Claude API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>;
    String text = (content.first as Map<String, dynamic>)['text'] as String;
    // Strip markdown code fences Claude sometimes adds (```json ... ```)
    text = text.trim();
    if (text.startsWith('```')) {
      text = text
          .replaceAll(RegExp(r'^```[a-zA-Z]*\n?'), '')
          .replaceAll(RegExp(r'\n?```$'), '')
          .trim();
    }
    return text;
  }

  static String _computeAgeLabel(List<int> ages) {
    if (ages.isEmpty) return 'Young Kids (5–8)';
    final hasTeens = ages.any((a) => a >= 13);
    final hasYoung = ages.any((a) => a <= 8);
    final hasOlderRange = ages.any((a) => a >= 8 && a <= 12);

    if (hasTeens && hasYoung) return 'Mixed Ages';
    if (hasTeens && hasOlderRange) return 'Mixed Ages';
    if (hasTeens) return 'Teens (13+)';
    if (hasYoung && hasOlderRange) return 'Mixed Ages';
    if (hasOlderRange) return 'Older Kids (8–12)';
    return 'Young Kids (5–8)';
  }
}
