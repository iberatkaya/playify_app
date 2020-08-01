import 'package:flutter/material.dart';
import 'package:playify_app/classes/mood.dart';

/// Mood List
/// Happy, Sad, Sleepy, Energetic, Joyful, Crazy

class HappyMood extends Mood {

  static const Color iconColor = Colors.amberAccent;
  static const Color color = Colors.amber;
  static const Icon icon = Icon(
    Icons.mood,
    color: iconColor,
  );
  static const String text = "Happy";

  @override
  HappyMood()
      : super(
          moodText: text,
          moodTextColor: color,
          moodIcon: icon,
        );
}

class SadMood extends Mood {
  static const Icon icon = Icon(Icons.mood_bad);
  static const Color color = Colors.amber;
  static const String text = "Sad";

  @override
  SadMood()
      : super(
          moodText: text,
          moodTextColor: color,
          moodIcon: icon,
        );
}
