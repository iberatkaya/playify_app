import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:playify/playify.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [HomeScreen(), StatisticsScreen(), ProfileScreen()],
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
