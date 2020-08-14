import 'package:flutter/material.dart';
import 'package:playify_app/components/profile/itemTile.dart';
import 'package:playify_app/icons/playify_icon_icons.dart';
import 'package:playify_app/screens/list.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            Divider(),
            ItemTile(
                title: "Artists",
                icon: Icon(
                  PlayifyIcon.artist,
                  size: 18,
                ),
                fn: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ListScreen(listType: MusicListType.artists)));
                }),
            Divider(),
            ItemTile(
                title: "Albums",
                icon: Icon(PlayifyIcon.album, size: 18),
                fn: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ListScreen(listType: MusicListType.albums)));
                }),
            Divider(),
            ItemTile(
                title: "Songs",
                icon: Icon(PlayifyIcon.song, size: 18),
                fn: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ListScreen(listType: MusicListType.songs)));
                }),
            Divider(),
          ],
        ),
      ),
    );
  }
}
