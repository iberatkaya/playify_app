import 'package:flutter/material.dart';
import 'package:playify/playify.dart';

class RecentMusicContainer extends StatelessWidget {
  final SongInfo songInfo;

  const RecentMusicContainer({Key key, @required this.songInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Later Uncomment These Properties
    // final image = songInfo.album.coverArt;
    // final title = songInfo.album.title;
    // final singer = songInfo.artist.name;

    return Container(
      width: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
            image: NetworkImage(
                "https://m.media-amazon.com/images/I/81mZP6Ud5dL._SS500_.jpg"),
            fit: BoxFit.cover),
      ),
    );
  }
}
