import 'package:flutter/material.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/utilities/utils.dart';

import '../list.dart';
import '../../widgets/grid_item_tile.dart';

class ArtistDetail extends StatefulWidget {
  final List<Album> albums;

  const ArtistDetail({required this.albums});
  @override
  _ArtistDetailState createState() => _ArtistDetailState();
}

class _ArtistDetailState extends State<ArtistDetail> {
  late List<Album> sortedAlbums;
  @override
  void initState() {
    super.initState();
    sortedAlbums = [...widget.albums];
    setState(() {
      sortedAlbums.sort((a, b) =>
          -1 *
          (a.songs[0].releaseDate.millisecondsSinceEpoch -
              b.songs[0].releaseDate.millisecondsSinceEpoch));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: themeModeColor(
                  MediaQuery.of(context).platformBrightness,
                  Colors.purple.shade400,
                ),
                onPressed: () async {
                  try {
                    var playify = Playify();
                    List<String> songIDs = sortedAlbums
                        .map((e) => e.songs.map((e) => e.iOSSongID).toList())
                        .toList()
                        .expand((element) => element)
                        .toList();
                    await playify.setQueue(
                        songIDs: songIDs, startID: songIDs.first);
                  } catch (e) {
                    print(e);
                  }
                },
                child: Text(
                  "Play All",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(child: Divider()),
        Expanded(
          flex: 50,
          child: GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: sortedAlbums.length,
              padding: EdgeInsets.symmetric(vertical: 6),
              itemBuilder: (BuildContext listContext, int index) {
                return GridItemTile(
                  title: sortedAlbums[index].title,
                  subtitle: sortedAlbums[index]
                              .songs[0]
                              .releaseDate
                              .millisecondsSinceEpoch ==
                          0
                      ? null
                      : sortedAlbums[index]
                          .songs[0]
                          .releaseDate
                          .year
                          .toString(),
                  padding: EdgeInsets.only(bottom: 12),
                  icon: sortedAlbums[index].coverArt != null
                      ? Image.memory(sortedAlbums[index].coverArt!)
                      : null,
                  fn: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ListScreen(
                        listType: MusicListType.album,
                        album: sortedAlbums[index],
                      ),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
