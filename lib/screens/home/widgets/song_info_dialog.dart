import 'package:flutter/material.dart';
import 'package:playify/playify.dart';

class SongInfoDialog extends StatelessWidget {
  final SongInformation? songInformation;

  const SongInfoDialog({
    Key? key,
    this.songInformation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"))
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
          fontWeight: FontWeight.w400, fontSize: 16, color: Colors.black),
      title: Container(
        child: Text(
          songInformation?.song.title ?? "",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Album: " + (songInformation?.album.title ?? ""),
            style: TextStyle(color: Colors.black),
          ),
          Text(
            "Artist: " + (songInformation?.artist.name ?? ""),
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
