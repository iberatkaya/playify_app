import 'package:flutter/material.dart';
import 'package:playify_app/MainApp.dart';

void main() {
  runApp(PlayifyApp());
}

class PlayifyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Playify',
      theme: ThemeData.light().copyWith(
          dividerTheme: DividerThemeData(color: Colors.black54),
          iconTheme: IconThemeData(color: Colors.black)),
      darkTheme: ThemeData.dark().copyWith(
          dividerTheme: DividerThemeData(color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
          textTheme: TextTheme(
              bodyText2: TextStyle(color: Colors.white),
              bodyText1: TextStyle(color: Colors.white),
              headline1: TextStyle(color: Colors.white),
              headline2: TextStyle(color: Colors.white),
              headline3: TextStyle(color: Colors.white),
              headline4: TextStyle(color: Colors.white))),
      home: MainApp(),
    );
  }
}
