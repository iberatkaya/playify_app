import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/classes/recentPlayedSong.dart';
import 'package:playify_app/components/itemTile.dart';
import 'package:playify_app/redux/music/action.dart';
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
                  return ListView.separated(
                      itemCount: albums.length,
                      padding: EdgeInsets.symmetric(vertical: 6),
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemBuilder: (BuildContext listContext, int index) {
                        return ItemTile(
                          title: albums[index].title,
                          icon: albums[index].coverArt != null ? Image.memory(albums[index].coverArt) : null,
                          subtitle: albums[index].artistName,
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
                                await playify.setQueue(
                                    songIDs: songs.map((e) => e.iOSSongID).toList(), startIndex: index);
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
                        return ItemTile(
                            title: widget.artist.albums[index].title,
                            brightness: MediaQuery.of(context).platformBrightness,
                            icon: widget.artist.albums[index].coverArt != null
                                ? Image.memory(widget.artist.albums[index].coverArt)
                                : null,
                            fn: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ListScreen(
                                      listType: MusicListType.album,
                                      album: widget.artist.albums[index],
                                    ))));
                      });
                } else if (widget.listType == MusicListType.album) {
                  return ListView.separated(
                      itemCount: widget.album.songs.length,
                      padding: EdgeInsets.symmetric(vertical: 6),
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemBuilder: (BuildContext listContext, int index) {
                        return ItemTile(
                            title: widget.album.songs[index].title,
                            icon: widget.album.coverArt != null ? Image.memory(widget.album.coverArt) : null,
                            brightness: MediaQuery.of(context).platformBrightness,
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
                      });
                } else {
                  return Container();
                }
              }),
        ),
      ),
    );
  }
}
