import 'package:flutter/material.dart';
import 'package:playify/playify.dart';

class RecentMusicContainer extends StatelessWidget {
  final SongInfo songInfo;

  const RecentMusicContainer({Key key, @required this.songInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Later Uncomment These Properties
    final image = songInfo.album.coverArt;
    final title = songInfo.album.title;
    final singer = songInfo.artist.name;

    return Container(
      width: 50,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: Image.memory(image).image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
