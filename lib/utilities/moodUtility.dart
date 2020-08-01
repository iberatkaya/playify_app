import 'package:playify_app/components/profile/moodList.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Moods => As String
/// Happy
/// Sad
/// Energetic
/// Sleepy
/// Joyful
Future<void> saveMood(String moodAsText) async {
  final instance = await SharedPreferences.getInstance();
  await instance.setString("Mood", "$moodAsText");
}

///
/// Returns Current Mood
///
Future<dynamic> getMood() async {
  final instance = await SharedPreferences.getInstance();
  String mood = instance.getString("Mood");
  return stringMoodToClass(mood);
}

/// This Function takes String Returns Mood Class that includes icon, moodText, color...
dynamic stringMoodToClass(String mood) {
  if (mood == "Happy") {
    return HappyMood();
  }
  if (mood == "Sad") {
    return SadMood();
  }
  if (mood == "Energetic") {
    return EnergeticMood();
  }
  if (mood == "Sleepy") {
    return SleepyMood();
  }
  if (mood == "Joyful") {
    return JoyfulMood();
  } else {
    return HappyMood();
  }
}
