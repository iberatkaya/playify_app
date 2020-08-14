import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/components/profile/itemTile.dart';
import 'package:playify_app/redux/store.dart';

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
        title: Text(listTypeTitle()),
      ),
      body: StoreProvider(
        store: store,
        child: Container(
          child: StoreConnector<AppState, List<Artist>>(
              converter: (appstate) => appstate.state.artists,
              builder: (BuildContext storeContext, List<Artist> artists) {
                if (widget.listType == MusicListType.artists) {
                  var myartists = [...artists];
                  myartists.sort((a, b) => a.name[0].compareTo(b.name[0]));
                  return ListView.builder(
                      itemCount: myartists.length,
                      itemBuilder: (BuildContext listContext, int index) {
                        return ItemTile(
                            title: myartists[index].name,
                            icon: myartists[index].albums[0].coverArt,
                            fn: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ListScreen(
                                      listType: MusicListType.artist,
                                      artist: myartists[index],
                                    ))));
                      });
                } else if (widget.listType == MusicListType.albums) {
                  List<Album> albums = [];
                  for (var i = 0; i < artists.length; i++) {
                    for (var j = 0; j < artists[i].albums.length; j++) {
                      albums.add(artists[i].albums[j]);
                    }
                  }
                  albums.sort((a, b) => a.title[0].compareTo(b.title[0]));
                  return ListView.builder(
                      itemCount: albums.length,
                      itemBuilder: (BuildContext listContext, int index) {
                        return ItemTile(
                            title: albums[index].title,
                            icon: albums[index].coverArt,
                            fn: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ListScreen(
                                      listType: MusicListType.album,
                                      album: albums[index],
                                    ))));
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
                  songs.sort((a, b) => a.title[0].compareTo(b.title[0]));
                  return ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (BuildContext listContext, int index) {
                        var iconArt = artists
                            .firstWhere((element) => element.name == songs[index].artistName)
                            .albums
                            .firstWhere((element) => element.title == songs[index].albumTitle)
                            .coverArt;
                        return ItemTile(
                            title: songs[index].title,
                            icon: iconArt,
                            fn: () async {
                              try {
                                var playify = Playify();
                                await playify.setQueue(
                                    songIDs: songs.sublist(index).map((e) => e.iOSSongID).toList());
                                Navigator.of(context).popUntil((route) => route.isFirst);
                                ;
                              } catch (e) {
                                print(e);
                              }
                            });
                      });
                } else if (widget.listType == MusicListType.artist) {
                  return ListView.builder(
                      itemCount: widget.artist.albums.length,
                      itemBuilder: (BuildContext listContext, int index) {
                        return ItemTile(
                            title: widget.artist.albums[index].title,
                            icon: widget.artist.albums[index].coverArt,
                            fn: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ListScreen(
                                      listType: MusicListType.album,
                                      album: widget.artist.albums[index],
                                    ))));
                      });
                } else if (widget.listType == MusicListType.album) {
                  return ListView.builder(
                      itemCount: widget.album.songs.length,
                      itemBuilder: (BuildContext listContext, int index) {
                        return ItemTile(
                            title: widget.album.songs[index].title,
                            icon: widget.album.coverArt,
                            fn: () async {
                              try {
                                var playify = Playify();
                                await playify.setQueue(
                                    songIDs:
                                        widget.album.songs.sublist(index).map((e) => e.iOSSongID).toList());
                                Navigator.of(context).popUntil((route) => route.isFirst);
                                ;
                              } catch (e) {
                                print(e);
                              }
                            });
                      });
                }
              }),
        ),
      ),
    );
  }
}
