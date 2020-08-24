import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:playify_app/classes/mood.dart';

// Mood List
// Happy, Sad, Sleepy, Energetic, Joyful

class HappyMood extends Mood {
  static const String text = "Happy";
  static Color iconColor = Colors.amberAccent;
  static Color color = Colors.amber;
  static Icon icon = Icon(
    Icons.mood,
    color: iconColor,
    size: 32,
  );

  @override
  HappyMood()
      : super(
          moodText: text,
          moodTextColor: color,
          moodIcon: icon,
        );
}

class SadMood extends Mood {
  static Color iconColor = Colors.blue.shade700;
  static Color color = Colors.blue.shade500;
  static String text = "Sad";
  static Icon icon = Icon(
    Icons.mood_bad,
    color: iconColor,
    size: 32,
  );

  @override
  SadMood()
      : super(
          moodText: text,
          moodTextColor: color,
          moodIcon: icon,
        );
}

class EnergeticMood extends Mood {
  static Color iconColor = Colors.green.shade700;
  static Color color = Colors.green;
  static String text = "High Energy";
  static Icon icon = Icon(
    Icons.battery_charging_full,
    color: iconColor,
    size: 32,
  );

  @override
  EnergeticMood()
      : super(
          moodText: text,
          moodTextColor: color,
          moodIcon: icon,
        );
}

class SleepyMood extends Mood {
  static Color iconColor = Colors.blueGrey.shade700;
  static Color color = Colors.blueGrey;
  static String text = "Sleepy";
  static Icon icon = Icon(
    FontAwesomeIcons.bed,
    color: iconColor,
    size: 32,
  );

  @override
  SleepyMood()
      : super(
          moodText: text,
          moodTextColor: color,
          moodIcon: icon,
        );
}

class JoyfulMood extends Mood {
  static Color iconColor = Colors.red.shade500;
  static Color color = Colors.redAccent;
  static String text = "Joyful";
  static Icon icon = Icon(
    Icons.insert_emoticon,
    color: iconColor,
    size: 32,
  );

  @override
  JoyfulMood()
      : super(
          moodText: text,
          moodTextColor: color,
          moodIcon: icon,
        );
}
