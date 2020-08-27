import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/classes/settings.dart';
import 'package:playify_app/redux/music/action.dart';
import 'package:playify_app/redux/settings/action.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/utilities/jsonify.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool updatingLibrary = false;
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

  Future<void> updateLibrary() async {
    try {
      setState(() {
        updatingLibrary = true;
      });
      int desiredWidth =
          ((MediaQuery.of(context).size.width / 2) < 400) ? (MediaQuery.of(context).size.width ~/ 2) : 400;
      var playify = Playify();
      var res = await playify.getAllSongs(coverArtSize: desiredWidth);
      List<Map<String, dynamic>> artistsMap = res.map((e) => artistToMap(e)).toList();
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString("artists", json.encode(artistsMap));
      store.dispatch(setMusicLibraryAction(res));
      setState(() {
        updatingLibrary = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        updatingLibrary = false;
      });
    }
  }

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
                        "Scan Library",
                        style: TextStyle(fontSize: settings.listTileFontSize.toDouble()),
                      ),
                      trailing: updatingLibrary ? CircularProgressIndicator() : null,
                      onTap: () async {
                        await updateLibrary();
                      },
                    ),
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
