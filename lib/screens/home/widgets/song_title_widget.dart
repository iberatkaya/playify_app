import 'package:flutter/material.dart';

import 'package:playify_app/utilities/utils.dart';

class SongTitleWidget extends StatelessWidget {
  final String songTitle;

  const SongTitleWidget({
    Key? key,
    required this.songTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      color: themeModeColor(
          MediaQuery.of(context).platformBrightness, Colors.black),
      child: Text(
        songTitle,
        style: TextStyle(
            color: themeModeColor(
                MediaQuery.of(context).platformBrightness, Colors.white),
            fontWeight: FontWeight.w700,
            fontSize: 18),
      ),
    );
  }
}
