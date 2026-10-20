import 'dart:convert';
import 'package:flutter/services.dart';

/// Service responsible for loading and deterministically selecting daily writing prompts.
class PromptService {
  static const List<String> _fallbackPrompts = [
    "What is something you never said because you thought it was too late?",
    "Write about a feeling you've been carrying silently this week.",
    "If you could send a letter to your past self without changing anything, what would it say?",
    "What is a boundary you wish you had set sooner?",
    "Describe a quiet moment from today that made you pause.",
    "What truth feels hardest to say out loud right now?",
    "Write down a hope you feel hesitant to admit to anyone.",
    "Who is someone you miss, and what part of them do you miss most?",
    "What weight are you ready to set down, even for just a few moments?",
    "What is something you need to hear today?",
  ];

  List<String>? _prompts;

  /// Loads prompts from asset file or returns cached/fallback list.
  Future<List<String>> loadPrompts() async {
    if (_prompts != null && _prompts!.isNotEmpty) {
      return _prompts!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/prompts/writing_prompts.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> list = data['prompts'] as List<dynamic>;
      _prompts = list.map((e) => e.toString()).toList();
    } catch (_) {
      _prompts = _fallbackPrompts;
    }
    return _prompts!;
  }

  /// Deterministically gets the prompt for a given date.
  /// The prompt remains identical throughout the entire calendar day.
  String getDailyPromptForDate(DateTime date, List<String> prompts) {
    if (prompts.isEmpty) return _fallbackPrompts.first;
    // Unique deterministic daily index using calendar date components
    final seed = date.year * 1000 + date.month * 31 + date.day;
    final index = seed % prompts.length;
    return prompts[index];
  }
}
