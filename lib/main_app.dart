import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/classes/settings.dart';
import 'package:playify_app/redux/actions/settings/action.dart';
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
  bool? intro;

  @override
  initState() {
    super.initState();
    getSettings().then((_) => setStatusBarColor()
        .then((_) => showIntro())
        .then((_) => setState(() => loading = false)));
  }

  Future<void> showIntro() async {
    try {
      var res = await SharedPreferences.getInstance();
      bool? show = res.getBool("showIntro");
      print("show: $show");
      if (show != null && show) {
        setState(() {
          intro = true;
        });
        await res.setBool("showIntro", false);
      } else {
        setState(() {
          intro = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getSettings() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      String? settingsJson = prefs.getString("settings");
      if (settingsJson == null) return;
      Settings mysettings = Settings.parseJson(settingsJson);
      store.dispatch(setSettingsAction(mysettings));
    } catch (e) {
      print(e);
    }
  }

  Future<void> setStatusBarColor() async {
    try {
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (intro != null && intro!) {
      return Scaffold(
          body: Container(
        padding: EdgeInsets.only(top: AppBar().preferredSize.height),
        child: IntroductionScreen(
            next: TextButton(
              child: Text("Next"),
              onPressed: () {},
            ),
            pages: [
              PageViewModel(
                image: Image.asset("assets/images/intro/1.png"),
                body:
                    "Start listening music with the best music player available!",
                title: "Welcome To Playify",
              ),
              PageViewModel(
                image: Image.asset("assets/images/intro/2.png"),
                body:
                    "The background color animation will change based on the song you listen. Click or swipe the album cover in any direction to interact!",
                title: "Help",
              ),
            ],
            done: Text(
              "Done",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onDone: () {
              setState(() {
                intro = false;
              });
            }),
      ));
    }

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: (loading || intro == null)
            ? [Container()]
            : [HomeScreen(), StatisticsScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (currentIndex) => setState(() {
          index = currentIndex;
        }),
        showSelectedLabels: false,
        selectedItemColor: themeModeColor(
            MediaQuery.of(context).platformBrightness, Colors.white),
        unselectedItemColor: themeModeColor(
            MediaQuery.of(context).platformBrightness, Colors.white38),
        showUnselectedLabels: false,
        backgroundColor: Colors.deepPurple[300],
        items: [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(
              Icons.play_circle_outline,
              size: 32,
            ),
          ),
          BottomNavigationBarItem(
            label: "Stats",
            icon: Icon(
              Icons.data_usage,
              size: 32,
            ),
          ),
          BottomNavigationBarItem(
            label: "Profile",
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
