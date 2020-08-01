import 'package:flutter/material.dart';
import 'package:playify_app/screens/home.dart';
import 'package:playify_app/screens/profile.dart';

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
      body: mainAppBodySwitch(index),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (currentIndex) => setState(() {
          index = currentIndex;
        }),
        showSelectedLabels: false,
        selectedItemColor: Colors.indigo.shade600,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            title: Text("Home"),
            icon: Icon(
              Icons.play_circle_outline,
            ),
          ),
          BottomNavigationBarItem(
            title: Text("Stats"),
            icon: Icon(
              Icons.data_usage,
            ),
          ),
          BottomNavigationBarItem(
            title: Text("Profile"),
            icon: Icon(
              Icons.account_circle,
            ),
          ),
        ],
      ),
    );
  }
}
