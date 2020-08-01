import 'package:flutter/material.dart';
import 'package:playify_app/icons/playify_icon_icons.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  TextStyle listTileTextStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 18);

  Widget item(String title, IconData icon, Function fn) {
    return Container(
      child: ListTile(
        title: Text(
          title,
          style: listTileTextStyle,
        ),
        leading: Icon(
          icon,
          size: 24,
        ),
        onTap: fn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            Divider(),
            item("Artists", PlayifyIcon.artist, () {}),
            Divider(),
            item("Albums", PlayifyIcon.album, () {}),
            Divider(),
            item("Songs", PlayifyIcon.song, () {}),
            Divider(),
          ],
        ),
      ),
    );
  }
}
