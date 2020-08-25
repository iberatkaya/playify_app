import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/classes/settings.dart';
import 'package:playify_app/components/itemTile.dart';
import 'package:playify_app/redux/music/action.dart';
import 'package:playify_app/redux/settings/action.dart';
import 'package:playify_app/redux/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String Function(int) fontSizeToString = (int i) {
    if (i == 15) return "Smallest";
    if (i == 16)
      return "Small";
    else if (i == 17)
      return "Medium";
    else if (i == 18)
      return "Large";
    else
      return "Largest";
  };
  int Function(String) stringToFontSize = (String i) {
    if (i == "Smallest")
      return 15;
    else if (i == "Small")
      return 16;
    else if (i == "Medium")
      return 17;
    else if (i == "Large")
      return 18;
    else
      return 19;
  };
  bool scanning = false;

  Map<String, dynamic> songToMap(Song song) => {
        "albumTitle": song.albumTitle,
        "artistName": song.artistName,
        "discNumber": song.discNumber,
        "duration": song.duration,
        "iOSSongID": song.iOSSongID,
        "isExplicit": song.isExplicit,
        "playCount": song.playCount,
        "title": song.title,
        "trackNumber": song.trackNumber,
      };

  Map<String, dynamic> albumToMap(Album album) => {
        "albumTrackCount": album.albumTrackCount,
        "artistName": album.artistName,
        "diskCount": album.diskCount,
        "songs": album.songs.map((element) => songToMap(element)).toList(),
        "title": album.title,
      };

  Map<String, dynamic> artistToMap(Artist artist) =>
      {"name": artist.name, "album": artist.albums.map((e) => albumToMap(e)).toList()};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Settings"),
      ),
      body: StoreProvider(
        store: store,
        child: Container(
          child: StoreConnector<AppState, Settings>(
              converter: (appstate) => appstate.state.settings,
              builder: (storeContext, settings) {
                return ListView(
                  children: [
                    ListTile(
                      title: Text(
                        "Font Size",
                        style: TextStyle(fontSize: settings.listTileFontSize.toDouble()),
                      ),
                      trailing: DropdownButton<String>(
                        value: fontSizeToString(settings.listTileFontSize),
                        items: ["Smallest", "Small", "Medium", "Large", "Largest"]
                            .map((i) => DropdownMenuItem(
                                  child: Text(i),
                                  value: i,
                                ))
                            .toList(),
                        onChanged: (val) async {
                          try {
                            var newsettings = Settings.copy(settings);
                            newsettings.listTileFontSize = stringToFontSize(val);
                            store.dispatch(setSettingsAction(newsettings));
                            var prefs = await SharedPreferences.getInstance();
                            prefs.setString("settings", newsettings.toJson());
                          } catch (e) {
                            print(e);
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Artist Statistics Number",
                        style: TextStyle(fontSize: settings.listTileFontSize.toDouble()),
                      ),
                      trailing: DropdownButton<int>(
                        value: settings.statisticNumberArtist,
                        items: [6, 8, 10, 12]
                            .map((i) => DropdownMenuItem(
                                  child: Text(i.toString()),
                                  value: i,
                                ))
                            .toList(),
                        onChanged: (val) async {
                          try {
                            var newsettings = Settings.copy(settings);
                            newsettings.statisticNumberArtist = val;
                            store.dispatch(setSettingsAction(newsettings));
                            var prefs = await SharedPreferences.getInstance();
                            prefs.setString("settings", newsettings.toJson());
                          } catch (e) {
                            print(e);
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Album Statistics Number",
                        style: TextStyle(fontSize: settings.listTileFontSize.toDouble()),
                      ),
                      trailing: DropdownButton<int>(
                        value: settings.statisticNumberAlbum,
                        items: [6, 8, 10, 12]
                            .map((i) => DropdownMenuItem(
                                  child: Text(i.toString()),
                                  value: i,
                                ))
                            .toList(),
                        onChanged: (val) async {
                          try {
                            var newsettings = Settings.copy(settings);
                            newsettings.statisticNumberAlbum = val;
                            store.dispatch(setSettingsAction(newsettings));
                            var prefs = await SharedPreferences.getInstance();
                            prefs.setString("settings", newsettings.toJson());
                          } catch (e) {
                            print(e);
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Song Statistics Number",
                        style: TextStyle(fontSize: settings.listTileFontSize.toDouble()),
                      ),
                      trailing: DropdownButton<int>(
                        value: settings.statisticNumberSong,
                        items: [4, 6, 8]
                            .map((i) => DropdownMenuItem(
                                  child: Text(i.toString()),
                                  value: i,
                                ))
                            .toList(),
                        onChanged: (val) async {
                          try {
                            var newsettings = Settings.copy(settings);
                            newsettings.statisticNumberSong = val;
                            store.dispatch(setSettingsAction(newsettings));
                            var prefs = await SharedPreferences.getInstance();
                            prefs.setString("settings", newsettings.toJson());
                          } catch (e) {
                            print(e);
                          }
                        },
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
