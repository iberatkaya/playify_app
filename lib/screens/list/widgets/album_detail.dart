import 'dart:math';

import 'package:flutter/material.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/screens/widgets/item_tile.dart';

import 'package:playify_app/redux/utility/utility.dart';
import 'package:playify_app/utilities/utils.dart';
import 'package:playify_app/utilities/extensions.dart';

class AlbumDetail extends StatefulWidget {
  final Album album;
  final List<Artist> artists;
  final Color color;
  final bool fetchAllAlbumSongs;

  AlbumDetail({
    required this.album,
    required this.color,
    required this.fetchAllAlbumSongs,
    required this.artists,
  });

  @override
  _AlbumDetailState createState() => _AlbumDetailState();
}

class _AlbumDetailState extends State<AlbumDetail> {
  List<Song> songs = [];

  @override
  void initState() {
    super.initState();
    if (widget.fetchAllAlbumSongs) {
      for (var i = 0; i < widget.artists.length; i++) {
        for (var j = 0; j < widget.artists[i].albums.length; j++) {
          if (widget.artists[i].albums[j].title == widget.album.title) {
            for (var k = 0; k < widget.artists[i].albums[j].songs.length; k++) {
              widget.artists[i].albums[j].songs.forEach((element) {
                var songExists = false;
                for (var song in songs) {
                  if (song.title == element.title &&
                      song.duration == element.duration) songExists = true;
                }
                if (!songExists) songs.add(element.copy());
              });
            }
          }
        }
      }
    } else {
      songs = [...widget.album.songs];
    }
    setState(() {
      songs.sort((a, b) =>
          (a.trackNumber - b.trackNumber) +
          songs.length * (a.discNumber - b.discNumber));
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          actions: [
            IconButton(
              color: Colors.purple[500],
              onPressed: () async {
                try {
                  var playify = Playify();
                  final songIDs = songs.map((e) => e.songID).toList();

                  await playify.setQueue(
                    songIDs: songIDs,
                    startID: songIDs.first,
                    startPlaying: true,
                  );
                  updateRecentSongs(songs[0]);
                  //Navigator.of(context).popUntil((route) => route.isFirst);
                } catch (e) {
                  print(e);
                }
              },
              icon: Icon(Icons.play_circle_filled),
              iconSize: 32,
            ),
          ],
          backgroundColor: widget.color,
          stretch: true,
          leading: Container(),
          expandedHeight: MediaQuery.of(context).size.height * 0.32,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(bottom: 6),
            stretchModes: [StretchMode.zoomBackground],
            title: Container(
              decoration: BoxDecoration(
                  color: themeModeColor(
                    MediaQuery.of(context).platformBrightness,
                    Colors.black87,
                  ),
                  borderRadius: BorderRadius.circular(4)),
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                    text: substring(widget.album.title, 35) + "\n",
                    style: TextStyle(
                      fontSize: 12,
                      color: themeModeColor(
                        MediaQuery.of(context).platformBrightness,
                        Colors.white,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: substring(widget.album.artistName, 30) +
                        ((widget.album.songs[0].releaseDate
                                    .microsecondsSinceEpoch !=
                                0)
                            ? " - "
                            : ""),
                    style: TextStyle(
                      fontSize: 9,
                      color: themeModeColor(
                        MediaQuery.of(context).platformBrightness,
                        Colors.white,
                      ),
                    ),
                  ),
                  if (songs[0].releaseDate.microsecondsSinceEpoch != 0)
                    TextSpan(
                      text: songs[0].releaseDate.year.toString(),
                      style: TextStyle(
                        fontSize: 9,
                        color: themeModeColor(
                          MediaQuery.of(context).platformBrightness,
                          Colors.grey.shade500,
                        ),
                      ),
                    ),
                ]),
              ),
            ),
            centerTitle: true,
            background: widget.album.coverArt != null
                ? Image.memory(widget.album.coverArt!)
                : AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      color: themeModeColor(
                          MediaQuery.of(context).platformBrightness,
                          Colors.black12),
                      alignment: Alignment.center,
                      child: ClipRRect(
                        child: Text(
                          widget.album.title.substring(0, 2).toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((sliverContext, index) {
            final int itemIndex = index ~/ 2;
            if (index.isOdd) {
              return Divider(height: 0, color: Colors.grey);
            }
            return ItemTile(
              title: songs[itemIndex].title,
              songID: songs[itemIndex].songID,
              icon: Text(songs[itemIndex].trackNumber.toString()),
              padding: EdgeInsets.symmetric(vertical: 4),
              fn: () async {
                try {
                  var playify = Playify();
                  await playify.setQueue(
                    songIDs: songs.map((e) => e.songID).toList(),
                    startPlaying: true,
                    startID: songs[itemIndex].songID,
                  );
                  await updateRecentSongs(songs[itemIndex]);

                  Navigator.of(context).popUntil((route) => route.isFirst);
                } catch (e) {
                  print(e);
                }
              },
            );
          }, childCount: max(0, songs.length * 2 - 1)),
        )
      ],
    );
  }
}
