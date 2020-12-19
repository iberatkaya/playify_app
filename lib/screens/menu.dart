import 'package:flutter/material.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/screens/widgets/item_tile.dart';
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
      appBar: AppBar(
        elevation: 0,
        title: Text("Menu"),
      ),
      body: Container(
        child: ListView(
          children: [
            ItemTile(
                title: "Artists",
                icon: Icon(
                  PlayifyIcon.artist,
                  size: 24,
                ),
                padding: EdgeInsets.only(top: 4),
                addLeadingSpace: true,
                brightness: MediaQuery.of(context).platformBrightness,
                fn: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ListScreen(listType: MusicListType.artists)));
                }),
            Divider(),
            ItemTile(
                title: "Albums",
                icon: Icon(
                  PlayifyIcon.album,
                  size: 24,
                ),
                addLeadingSpace: true,
                brightness: MediaQuery.of(context).platformBrightness,
                fn: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ListScreen(listType: MusicListType.albums)));
                }),
            Divider(),
            ItemTile(
                title: "Songs",
                icon: Icon(
                  PlayifyIcon.song,
                  size: 24,
                ),
                addLeadingSpace: true,
                brightness: MediaQuery.of(context).platformBrightness,
                fn: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ListScreen(listType: MusicListType.songs)));
                }),
            Divider(),
            ItemTile(
                title: "Playlists",
                icon: Icon(
                  Icons.playlist_play,
                  size: 24,
                ),
                addLeadingSpace: true,
                brightness: MediaQuery.of(context).platformBrightness,
                fn: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ListScreen(
                            listType: MusicListType.playlists,
                            playlists: store.state.playlists,
                          )));
                }),
            Divider(),
          ],
        ),
      ),
    );
  }
}
