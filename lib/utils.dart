import 'package:playify/playify.dart';

bool isEqual(Song first, Song second) {
  return first.title == second.title &&
      first.albumTitle == second.albumTitle &&
      first.artistName == second.artistName;
}

Duration intToDuration(int totalSeconds) {
  int seconds = totalSeconds % 60;
  int minutes = (totalSeconds ~/ 60) % 60;
  int hours = totalSeconds ~/ 3600;
  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}

printDuration(Duration d) =>
    d.inHours != 0 ? d.toString().split('.').first.padLeft(8, "0") : d.toString().substring(2, 7);

formatSongTime(int seconds) {
  return printDuration(intToDuration(seconds));
}
