import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/classes/recentPlayedSong.dart';
import 'package:playify_app/components/gridItemTile.dart';
import 'package:playify_app/components/itemTile.dart';
import 'package:playify_app/utilities/utils.dart';
import 'package:playify_app/redux/recentplayedsongs/action.dart';
import 'package:playify_app/redux/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MusicListType { artists, albums, songs, artist, album }

class ListScreen extends StatefulWidget {
  final MusicListType listType;

  ///Use if an album's content will be displayed
  final Album album;

  ///Use if an artist's content will be displayed
  final Artist artist;

  const ListScreen({Key key, @required this.listType, this.album, this.artist}) : super(key: key);
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  Color color = Colors.grey[50];

  updateRecentSongs(Song selectedSong) async {
    var prefs = await SharedPreferences.getInstance();
    List<String> recentlist =
        prefs.getStringList("recentPlayed") != null ? prefs.getStringList("recentPlayed") : [];
    recentlist.insert(0, selectedSong.iOSSongID);
    if (recentlist.length > 6) {
      recentlist.removeAt(recentlist.length - 1);
    }
    List<RecentPlayedSong> recentSongs = [];
    recentlist.forEach(
      (i) => store.state.artists.forEach(
        (j) => j.albums.forEach(
          (k) => k.songs.forEach((l) => (l.iOSSongID == i)
              ? recentSongs.add(RecentPlayedSong(
                  albumName: k.title,
                  iosSongId: i,
                  coverArt: k.coverArt,
                  artistName: j.name,
                  songName: l.title,
                ))
              : null),
        ),
      ),
    );
    store.dispatch(setRecentPlayedSongsAction(recentSongs));
    await prefs.setStringList("recentPlayed", recentlist);
  }

  int boundTo0and255(int val) {
    if (val > 255)
      return 255;
    else if (val < 0)
      return 0;
    else
      return val;
  }

  Future<void> updateBackgroundColor() async {
    try {
      var paletteGenerator = await PaletteGenerator.fromImageProvider(
        Image.memory(widget.album.coverArt).image,
        maximumColorCount: 1,
      );
      if (paletteGenerator.colors.toList().length > 0) {
        Color tempColor = paletteGenerator.colors.toList()[0];
        var rnd = Random();
        const randomness = 8;
        Color newColor = Color.fromRGBO(
          boundTo0and255(tempColor.red + rnd.nextInt(randomness) * (rnd.nextBool() ? 1 : -1)),
          boundTo0and255(tempColor.green + rnd.nextInt(randomness) * (rnd.nextBool() ? 1 : -1)),
          boundTo0and255(tempColor.blue + rnd.nextInt(randomness) * (rnd.nextBool() ? 1 : -1)),
          0.3,
        );
        setState(() {
          color = newColor;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  String listTypeTitle() {
    if (widget.listType == MusicListType.albums) {
      return "Albums";
    } else if (widget.listType == MusicListType.artists) {
      return "Artists";
    } else if (widget.listType == MusicListType.songs) {
      return "Songs";
    } else if (widget.listType == MusicListType.album) {
      return widget.album.title;
    } else if (widget.listType == MusicListType.artist) {
      return widget.artist.name;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.listType == MusicListType.artist && widget.artist == null)
      throw "Artist cannot be empty";
    else if (widget.listType == MusicListType.album && widget.album == null) throw "Artist cannot be empty";
    if (widget.listType == MusicListType.album) {
      updateBackgroundColor();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(listTypeTitle()),
      ),
      body: Container(
        child: StoreProvider(
          store: store,
          child: StoreConnector<AppState, List<Artist>>(
              converter: (appstate) => appstate.state.artists,
              builder: (BuildContext storeContext, List<Artist> artists) {
                if (widget.listType == MusicListType.artists) {
                  var myartists = [...artists];
                  myartists.sort((a, b) => a.name[0].toUpperCase().compareTo(b.name[0].toUpperCase()));
                  return ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      itemCount: myartists.length,
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemBuilder: (BuildContext listContext, int index) {
                        return ItemTile(
                          padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                          title: myartists[index].name,
                          brightness: MediaQuery.of(context).platformBrightness,
                          subtitle: myartists[index].albums.length.toString() +
                              ((myartists[index].albums.length == 1) ? " Album" : " Albums"),
                          icon: myartists[index].albums[0].coverArt != null
                              ? Image.memory(myartists[index].albums[0].coverArt)
                              : null,
                          fn: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ListScreen(
                                listType: MusicListType.artist,
                                artist: myartists[index],
                              ),
                            ),
                          ),
                        );
                      });
                } else if (widget.listType == MusicListType.albums) {
                  List<Album> albums = [];
                  for (var i = 0; i < artists.length; i++) {
                    for (var j = 0; j < artists[i].albums.length; j++) {
                      albums.add(artists[i].albums[j]);
                    }
                  }
                  albums.sort((a, b) => a.title[0].toUpperCase().compareTo(b.title[0].toUpperCase()));
                  return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                      itemCount: albums.length,
                      padding: EdgeInsets.symmetric(vertical: 6),
                      itemBuilder: (BuildContext listContext, int index) {
                        return GridItemTile(
                          title: albums[index].title,
                          padding: EdgeInsets.only(bottom: 12),
                          icon: albums[index].coverArt != null ? Image.memory(albums[index].coverArt) : null,
                          brightness: MediaQuery.of(context).platformBrightness,
                          fn: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ListScreen(
                                listType: MusicListType.album,
                                album: albums[index],
                              ),
                            ),
                          ),
                        );
                      });
                } else if (widget.listType == MusicListType.songs) {
                  List<Song> songs = [];
                  for (var i = 0; i < artists.length; i++) {
                    for (var j = 0; j < artists[i].albums.length; j++) {
                      for (var k = 0; k < artists[i].albums[j].songs.length; k++) {
                        songs.add(artists[i].albums[j].songs[k]);
                      }
                    }
                  }
                  songs.sort((a, b) => a.title[0].toUpperCase().compareTo(b.title[0].toUpperCase()));
                  return ListView.separated(
                      itemCount: songs.length,
                      padding: EdgeInsets.symmetric(vertical: 6),
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemBuilder: (BuildContext listContext, int index) {
                        var iconArt = artists
                            .firstWhere((element) => element.name == songs[index].artistName)
                            .albums
                            .firstWhere((element) => element.title == songs[index].albumTitle)
                            .coverArt;
                        return ItemTile(
                            title: songs[index].title,
                            icon: iconArt != null ? Image.memory(iconArt) : null,
                            brightness: MediaQuery.of(context).platformBrightness,
                            subtitle: songs[index].artistName,
                            fn: () async {
                              try {
                                var playify = Playify();
                                await playify.playItem(songID: songs[index].iOSSongID);
                                updateRecentSongs(songs[index]);
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              } catch (e) {
                                print(e);
                              }
                            });
                      });
                } else if (widget.listType == MusicListType.artist) {
                  return ListView.separated(
                      itemCount: widget.artist.albums.length,
                      padding: EdgeInsets.symmetric(vertical: 6),
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemBuilder: (BuildContext listContext, int index) {
                        List<Album> albums = [...widget.artist.albums];
                        albums.sort((a, b) => -1 * a.songs[0].releaseDate.compareTo(b.songs[0].releaseDate));
                        return ItemTile(
                          title: albums[index].title,
                          brightness: MediaQuery.of(context).platformBrightness,
                          icon: albums[index].coverArt != null ? Image.memory(albums[index].coverArt) : null,
                          subtitle: albums[index].songs[0].releaseDate.millisecondsSinceEpoch != 0
                              ? albums[index].songs[0].releaseDate.year.toString()
                              : null,
                          fn: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ListScreen(
                                listType: MusicListType.album,
                                album: albums[index],
                              ),
                            ),
                          ),
                        );
                      });
                } else if (widget.listType == MusicListType.album) {
                  return Center(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: color,
                          ),
                        ),
                        Expanded(
                          flex: 15,
                          child: Container(
                            color: color,
                            child: Row(
                              children: [
                                Spacer(flex: 1),
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: widget.album.coverArt != null
                                        ? Image.memory(widget.album.coverArt)
                                        : AspectRatio(
                                            aspectRatio: 1,
                                            child: Container(
                                              color: themeModeColor(
                                                  MediaQuery.of(context).platformBrightness, Colors.black12),
                                              alignment: Alignment.center,
                                              child: ClipRRect(
                                                child: Text(
                                                  widget.album.title.substring(0, 2).toUpperCase(),
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600,
                                                      color: themeModeColor(
                                                        MediaQuery.of(context).platformBrightness,
                                                        Colors.black,
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                Spacer(flex: 1),
                                Expanded(
                                  flex: 10,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 3),
                                        child: Text(
                                          widget.album.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 3),
                                        child: Text(
                                          widget.album.artistName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        widget.album.songs[0].releaseDate.year.toString(),
                                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                      )
                                    ],
                                  ),
                                ),
                                Spacer(flex: 1),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: color,
                            child: Divider(color: Colors.grey[300]),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            color: color,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FlatButton(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  color: Colors.purple[500],
                                  onPressed: () async {
                                    try {
                                      var playify = Playify();
                                      await playify.setQueue(
                                        songIDs: widget.album.songs.map((e) => e.iOSSongID).toList(),
                                        startIndex: 0,
                                      );
                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                  child: Text("Play",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: color,
                          ),
                        ),
                        Expanded(
                          flex: 40,
                          child: ListView.separated(
                              itemCount: widget.album.songs.length,
                              padding: EdgeInsets.symmetric(vertical: 6),
                              separatorBuilder: (context, index) {
                                return Divider();
                              },
                              itemBuilder: (BuildContext listContext, int index) {
                                return ItemTile(
                                    title: widget.album.songs[index].trackNumber.toString() +
                                        ". " +
                                        widget.album.songs[index].title,
                                    icon: widget.album.coverArt != null
                                        ? Image.memory(widget.album.coverArt)
                                        : null,
                                    brightness: MediaQuery.of(context).platformBrightness,
                                    hasLeadingIcon: false,
                                    fn: () async {
                                      try {
                                        var playify = Playify();
                                        await playify.setQueue(
                                            songIDs: widget.album.songs.map((e) => e.iOSSongID).toList(),
                                            startIndex: index);
                                        updateRecentSongs(widget.album.songs[index]);

                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                      } catch (e) {
                                        print(e);
                                      }
                                    });
                              }),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              }),
        ),
      ),
    );
  }
}
