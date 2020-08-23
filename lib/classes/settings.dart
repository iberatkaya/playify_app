import 'dart:convert';

import 'package:flutter/material.dart';

class Settings {
  int listTileFontSize;
  int statisticNumberArtist;
  int statisticNumberAlbum;
  int statisticNumberSong;
  Color lightThemeColor;

  static Settings copy(Settings settings) {
    return Settings(
        lightThemeColor: settings.lightThemeColor,
        listTileFontSize: settings.listTileFontSize,
        statisticNumberAlbum: settings.statisticNumberAlbum,
        statisticNumberSong: settings.statisticNumberSong,
        statisticNumberArtist: settings.statisticNumberArtist);
  }

  Map<String, dynamic> toMap() {
    return {
      "lightThemeColor": this.lightThemeColor.value,
      "listTileFontSize": this.listTileFontSize,
      "statisticNumberAlbum": this.statisticNumberAlbum,
      "statisticNumberSong": this.statisticNumberSong,
      "statisticNumberArtist": this.statisticNumberArtist
    };
  }

  String toJson() {
    return json.encode(this.toMap());
  }

  static Settings parseJson(String myjson) {
    return parseMap(json.decode(myjson));
  }

  static Settings parseMap(Map<String, dynamic> map) {
    return Settings(
        lightThemeColor: Color(map["lightThemeColor"] as int),
        listTileFontSize: map["listTileFontSize"],
        statisticNumberAlbum: map["statisticNumberAlbum"],
        statisticNumberArtist: map["statisticNumberArtist"],
        statisticNumberSong: map["statisticNumberSong"]);
  }

  Settings(
      {this.lightThemeColor = Colors.blue,
      this.listTileFontSize = 17,
      this.statisticNumberArtist = 10,
      this.statisticNumberAlbum = 10,
      this.statisticNumberSong = 4});
}
