import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/screens/list/widgets/albums_list.dart';
import 'package:playify_app/screens/list/widgets/artist_detail.dart';
import 'package:playify_app/screens/list/widgets/artists_list.dart';
import 'package:playify_app/screens/list/widgets/album_detail.dart';
import 'package:playify_app/screens/list/widgets/playlists_list.dart';
import 'package:playify_app/screens/list/widgets/all_songs_list.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/screens/list/widgets/songs_list.dart';

enum MusicListType {
  artists,
  albums,
  allSongs,
  artist,
  album,
  playlists,
  playlist
}

class ListScreen extends StatefulWidget {
  final MusicListType listType;

  ///Use if an album's content will be displayed.
  final Album? album;

  ///Use if an artist's content will be displayed.
  final Artist? artist;

  ///Use if a playlist's content will be displayed.
  final List<Playlist>? playlists;

  ///Use if a playlist will be displayed.
  final Playlist? playlist;

  ///Use if all songs of the album will be fetched.
  final bool fetchAllAlbumSongs;

  const ListScreen({
    required this.listType,
    this.album,
    this.artist,
    this.playlists,
    this.playlist,
    this.fetchAllAlbumSongs = false,
  });
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  Color color = Colors.grey.shade50;

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
      final coverArt = widget.album?.coverArt;
      if (coverArt != null) {
        var paletteGenerator = await PaletteGenerator.fromImageProvider(
          Image.memory(coverArt).image,
          maximumColorCount: 5,
        );
        if (paletteGenerator.colors.toList().length > 0) {
          Color tempColor = paletteGenerator.colors.toList()[0];
          var rnd = Random();
          const randomness = 8;
          Color newColor = Color.fromRGBO(
            boundTo0and255(tempColor.red +
                rnd.nextInt(randomness) * (rnd.nextBool() ? 1 : -1)),
            boundTo0and255(tempColor.green +
                rnd.nextInt(randomness) * (rnd.nextBool() ? 1 : -1)),
            boundTo0and255(tempColor.blue +
                rnd.nextInt(randomness) * (rnd.nextBool() ? 1 : -1)),
            0.5,
          );
          setState(() {
            color = newColor;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  String? listTypeTitle() {
    if (widget.listType == MusicListType.albums) {
      return "Albums";
    } else if (widget.listType == MusicListType.artists) {
      return "Artists";
    } else if (widget.listType == MusicListType.allSongs) {
      return "Songs";
    } else if (widget.listType == MusicListType.playlist) {
      return widget.playlist?.title;
    } else if (widget.listType == MusicListType.album) {
      return widget.album?.title;
    } else if (widget.listType == MusicListType.artist) {
      return widget.artist?.name;
    } else if (widget.listType == MusicListType.playlists) {
      return "Playlists";
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.listType == MusicListType.artist && widget.artist == null)
      throw "Artist cannot be null";
    else if (widget.listType == MusicListType.album && widget.album == null)
      throw "Album cannot be null";
    else if (widget.listType == MusicListType.playlists &&
        widget.playlists == null)
      throw "Playlist cannot be null";
    else if (widget.listType == MusicListType.playlist &&
        widget.playlist == null) throw "Playlist cannot be null";
    if (widget.listType == MusicListType.album) {
      updateBackgroundColor();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(listTypeTitle() ?? ""),
      ),
      body: Container(
        child: StoreProvider(
          store: store,
          child: StoreConnector<AppState, List<Artist>>(
              converter: (appstate) => appstate.state.artists,
              builder: (BuildContext storeContext, List<Artist> artists) {
                if (widget.listType == MusicListType.artists) {
                  return ArtistsList(artists: artists);
                } else if (widget.listType == MusicListType.albums) {
                  return AlbumsList(artists: artists);
                } else if (widget.listType == MusicListType.allSongs) {
                  return AllSongsList(artists: artists);
                } else if (widget.listType == MusicListType.artist &&
                    widget.artist != null) {
                  return ArtistDetail(albums: widget.artist!.albums);
                } else if (widget.listType == MusicListType.album &&
                    widget.album != null) {
                  return AlbumDetail(
                    album: widget.album!,
                    artists: artists,
                    color: color,
                    fetchAllAlbumSongs: widget.fetchAllAlbumSongs,
                  );
                } else if (widget.listType == MusicListType.playlists &&
                    widget.playlists != null) {
                  return PlaylistsList(
                    playlists: widget.playlists!,
                  );
                } else if (widget.listType == MusicListType.playlist &&
                    widget.playlist != null) {
                  return SongsList(
                    songs: widget.playlist!.songs,
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
