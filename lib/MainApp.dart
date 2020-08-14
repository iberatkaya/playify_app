import 'package:flutter/material.dart';
import 'package:playify_app/screens/home.dart';
import 'package:playify_app/screens/profile.dart';
import 'package:playify_app/utilities/utils.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int index = 0;

  Widget mainAppBodySwitch(int _index) {
    if (_index == 0)
      return HomeScreen();
    else if (_index == 1)
      return HomeScreen();
    else if (_index == 2)
      return ProfilePage();
    else
      return HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [HomeScreen(), Container(), ProfilePage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (currentIndex) => setState(() {
          index = currentIndex;
        }),
        showSelectedLabels: false,
        selectedItemColor: themeModeColor(MediaQuery.of(context).platformBrightness, Colors.blue[900]),
        showUnselectedLabels: false,
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
