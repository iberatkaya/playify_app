import 'package:flutter/material.dart';

import 'package:playify_app/utilities/utils.dart';

class SongSubtitleWidget extends StatelessWidget {
  final String albumTitle;
  final String artistName;
  const SongSubtitleWidget({
    Key? key,
    required this.albumTitle,
    required this.artistName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      color: themeModeColor(
          MediaQuery.of(context).platformBrightness, Colors.black),
      child: Column(
        children: [
          Text(
            substring(albumTitle, 25) + " - " + substring(artistName, 25),
            style: TextStyle(
                color: themeModeColor(
                    MediaQuery.of(context).platformBrightness, Colors.white),
                fontWeight: FontWeight.w500,
                fontSize: 12),
          ),
        ],
      ),
    );
  }
}
