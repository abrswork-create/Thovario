import 'package:flutter/cupertino.dart';

/// Represents a distinct emotional state or reflection mood in Thovario.
class Mood {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const Mood({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  static const Mood calm = Mood(
    key: 'calm',
    label: 'Calm',
    icon: CupertinoIcons.sparkles,
    color: Color(0xFF2DD4BF), // Soft Teal
  );

  static const Mood grateful = Mood(
    key: 'grateful',
    label: 'Grateful',
    icon: CupertinoIcons.heart_fill,
    color: Color(0xFFFBBF24), // Warm Amber
  );

  static const Mood reflective = Mood(
    key: 'reflective',
    label: 'Reflective',
    icon: CupertinoIcons.moon_stars_fill,
    color: Color(0xFFA78BFA), // Lavender Purple
  );

  static const Mood inspired = Mood(
    key: 'inspired',
    label: 'Inspired',
    icon: CupertinoIcons.lightbulb_fill,
    color: Color(0xFFF97316), // Vivid Amber/Orange
  );

  static const Mood hopeful = Mood(
    key: 'hopeful',
    label: 'Hopeful',
    icon: CupertinoIcons.leaf_arrow_circlepath,
    color: Color(0xFF34D399), // Emerald
  );

  static const Mood challenging = Mood(
    key: 'challenging',
    label: 'Challenging',
    icon: CupertinoIcons.cloud_rain_fill,
    color: Color(0xFF64748B), // Slate Blue
  );

  static const List<Mood> all = [
    reflective,
    calm,
    grateful,
    inspired,
    hopeful,
    challenging,
  ];

  static Mood fromKey(String? key) {
    if (key == null) return reflective;
    for (final mood in all) {
      if (mood.key.toLowerCase() == key.toLowerCase()) {
        return mood;
      }
    }
    return reflective;
  }
}
