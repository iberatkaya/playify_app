import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/classes/settings.dart';
import 'package:playify_app/redux/music/action.dart';
import 'package:playify_app/redux/settings/action.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/screens/home.dart';
import 'package:playify_app/screens/profile.dart';
import 'package:playify_app/screens/statistics.dart';
import 'package:playify_app/utilities/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int index = 0;
  bool loading = true;
  Playify playify = Playify();

  @override
  initState() {
    super.initState();
    getSettings().then((_) => setStatusBarColor().then((_) => setState(() => loading = false)));
  }

  Future<void> getSettings() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      String settingsJson = prefs.getString("settings");
      if (settingsJson == null) return;
      Settings mysettings = Settings.parseJson(settingsJson);
      store.dispatch(setSettingsAction(mysettings));
    } catch (e) {
      print(e);
    }
  }

  Future<void> setStatusBarColor() async {
    try {
      await FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
      await FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: (loading) ? [Container()] : [HomeScreen(), StatisticsScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (currentIndex) => setState(() {
          index = currentIndex;
        }),
        showSelectedLabels: false,
        selectedItemColor: themeModeColor(MediaQuery.of(context).platformBrightness, Colors.white),
        unselectedItemColor: themeModeColor(MediaQuery.of(context).platformBrightness, Colors.white38),
        showUnselectedLabels: false,
        backgroundColor: Colors.deepPurple[300],
        items: [
          BottomNavigationBarItem(
            title: Text("Home"),
            icon: Icon(
              Icons.play_circle_outline,
              size: 32,
            ),
          ),
          BottomNavigationBarItem(
            title: Text("Stats"),
            icon: Icon(
              Icons.data_usage,
              size: 32,
            ),
          ),
          BottomNavigationBarItem(
            title: Text("Profile"),
            icon: Icon(
              Icons.account_circle,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
