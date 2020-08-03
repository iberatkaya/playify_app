import 'package:flutter/material.dart';

abstract class Mood {
  final String moodText;
  final Color moodTextColor;
  final Icon moodIcon;

  Mood({
    @required this.moodIcon,
    @required this.moodTextColor,
    @required this.moodText,
  });
}
