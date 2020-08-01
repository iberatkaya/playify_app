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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: MainApp(),
    );
  }
}
