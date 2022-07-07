import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:playify/playify.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:playify_app/classes/recent_played_song.dart';
import 'package:playify_app/constant/animation_amount.dart';
import 'package:playify_app/redux/actions/current_song/action.dart';
import 'package:playify_app/redux/actions/music/action.dart';
import 'package:playify_app/redux/actions/recent_played_songs/action.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/redux/utility/utility.dart';
import 'package:playify_app/screens/home/widgets/album_cover.dart';
import 'package:playify_app/screens/home/widgets/controls.dart';
import 'package:playify_app/screens/home/widgets/permission_denied_widget.dart';
import 'package:playify_app/screens/home/widgets/rounded_app_bar.dart';
import 'package:playify_app/screens/home/widgets/secondary_music_settings.dart';
import 'package:playify_app/screens/home/widgets/song_info_dialog.dart';
import 'package:playify_app/screens/home/widgets/song_subtitle_widget.dart';
import 'package:playify_app/screens/home/widgets/song_title_widget.dart';
import 'package:playify_app/screens/home/widgets/time_slider.dart';
import 'package:playify_app/screens/list/list.dart';
import 'package:playify_app/screens/menu/menu.dart';
import 'package:playify_app/screens/widgets/transition_background.dart';
import 'package:playify_app/utilities/extensions.dart';
import 'package:playify_app/utilities/utils.dart';

class HomeScreen extends StatefulWidget {
  final bool animationEnabled;

  const HomeScreen({
    Key? key,
    this.animationEnabled = true,
  }) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  double _animationImageSize = 0.9;
  late AnimationController _controllerRight;
  late AnimationController _controllerLeft;
  late Animation<Offset> _animationOffsetRight;
  late Animation<Offset> _animationOffsetLeft;
  Animation<double>? animation;
  late AnimationController animationController;
  PermissionStatus? permissionStatus;
  bool updatedLibrary = false;
  Color firstColor = Colors.indigo.shade400;
  Color secondColor = Colors.deepPurple.shade400;
  SongInformation? currentSong;
  Playify playify = Playify();
  bool playing = false;
  bool changing = false;
  bool seeking = false;
  int currentTime = 0;
  double volume = 0;
  Shuffle shuffle = Shuffle.off;
  Repeat repeat = Repeat.none;
  Timer? timer;
  double spaceRatioPlayerAndTop = 0.12;

  @override
  void initState() {
    super.initState();
    initAnimation();
    var perm = Permission.mediaLibrary.request();
    perm.then((value) {
      if (value == PermissionStatus.granted) {
        setTimer();
        fetchLibraryFromSP().then((value) => getRecentSongs());
      }
      setState(() {
        permissionStatus = value;
      });
    });

    //Set the swipe right and left animation controllers. The offset determines
    //how much left or right the animation will go, and the duration determines
    //the speed of the animation.
    _controllerRight =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _animationOffsetRight =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(0.25, 0)).animate(
      CurvedAnimation(
        parent: _controllerRight,
        curve: Curves.fastOutSlowIn,
      ),
    )..addStatusListener((status) {
            if (status == AnimationStatus.forward) {
              setState(() {
                changing = true;
              });
            } else if (status == AnimationStatus.completed) {
              _controllerRight.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _controllerRight.reverse();
              setState(() {
                changing = false;
              });
            }
          });
    _controllerLeft =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _animationOffsetLeft =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(-0.25, 0)).animate(
      CurvedAnimation(
        parent: _controllerLeft,
        curve: Curves.fastOutSlowIn,
      ),
    )..addStatusListener((status) {
            if (status == AnimationStatus.forward) {
              setState(() {
                changing = true;
              });
            } else if (status == AnimationStatus.completed) {
              _controllerLeft.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _controllerLeft.reverse();
              setState(() {
                changing = false;
              });
            }
          });
  }

  @override
  void dispose() {
    _controllerRight.dispose();
    _controllerLeft.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  int boundTo0and255(int val) {
    if (val > 255)
      return 255;
    else if (val < 0)
      return 0;
    else
      return val;
  }

  ///Update the background color based on the cover art.
  Future<void> updateBackgroundColor() async {
    try {
      if (currentSong == null && currentSong!.album.coverArt != null) return;
      var paletteGenerator = await PaletteGenerator.fromImageProvider(
        Image.memory(currentSong!.album.coverArt!).image,
        maximumColorCount: 5,
      );
      if (paletteGenerator.colors.toList().length > 0) {
        Color tempColor1 = paletteGenerator.colors.toList()[0].withOpacity(0.3);
        Color tempColor2 = paletteGenerator.colors.toList()[1].withOpacity(0.3);
        var rnd = Random();
        const randomness = 8;
        Color newColor1 = Color.fromRGBO(
          boundTo0and255(tempColor1.red +
              rnd.nextInt(randomness) * (rnd.nextBool() ? 1 : -1)),
          boundTo0and255(tempColor1.green +
              rnd.nextInt(randomness) * (rnd.nextBool() ? 1 : -1)),
          boundTo0and255(tempColor1.blue +
              rnd.nextInt(randomness) * (rnd.nextBool() ? 1 : -1)),
          1,
        );
        Color newColor2 = Color.fromRGBO(
          boundTo0and255(tempColor2.red +
              rnd.nextInt(randomness) * (rnd.nextBool() ? 1 : -1)),
          boundTo0and255(tempColor2.green +
              rnd.nextInt(randomness) * (rnd.nextBool() ? 1 : -1)),
          boundTo0and255(tempColor2.blue +
              rnd.nextInt(randomness) * (rnd.nextBool() ? 1 : -1)),
          1,
        );
        setState(() {
          firstColor = newColor1;
          secondColor = newColor2;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  ///Get the library from Shared Preferences.
  Future<void> fetchLibraryFromSP() async {
    try {
      setState(() {
        updatedLibrary = false;
      });
      var prefs = await SharedPreferences.getInstance();

      //Used to update the library on updates.
      var update = prefs.getBool("update4") ?? false;

      var artistsJson = prefs.getString("artists");
      var playlistsJson = prefs.getString("playlists");

      if (artistsJson == null || playlistsJson == null || update) {
        await prefs.setBool("update4", true);
        await updateLibrary();
      } else {
        List<dynamic> artistsMap = json.decode(artistsJson);
        List<Artist> artists = List<Artist>.from(
            artistsMap.map((e) => ArtistX.mapToArist(e)).toList());

        List<dynamic> playlistsMap = json.decode(playlistsJson);
        List<Playlist> playlists = List<Playlist>.from(
            playlistsMap.map((e) => PlaylistX.mapToPlaylist(e)).toList());

        store.dispatch(setMusicLibraryAction(artists, playlists));
      }
      setState(() {
        updatedLibrary = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        updatedLibrary = true;
      });
    }
  }

  ///Fetch and update the music library.
  Future<void> updateLibrary() async {
    try {
      int desiredWidth = ((MediaQuery.of(context).size.width / 2) < 400)
          ? (MediaQuery.of(context).size.width ~/ 2)
          : 400;
      await updateMusicLibrary(desiredWidth);

      setState(() {
        updatedLibrary = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        updatedLibrary = true;
      });
    }
  }

  ///Get recently played songs.
  Future<void> getRecentSongs() async {
    var prefs = await SharedPreferences.getInstance();
    List<String> recentlist = prefs.getStringList("recentPlayed") != null
        ? prefs.getStringList("recentPlayed")!
        : [];
    List<RecentPlayedSong> recentSongs = [];
    recentlist.forEach(
      (i) => store.state.artists.forEach(
        (j) => j.albums.forEach(
          (k) => k.songs.forEach((l) => (l.songID == i)
              ? recentSongs.add(RecentPlayedSong(
                  albumName: k.title,
                  songID: i,
                  coverArt: k.coverArt,
                  artistName: j.name,
                  songName: l.title,
                ))
              : null),
        ),
      ),
    );
    store.dispatch(setRecentPlayedSongsAction(recentSongs));
  }

  ///Create an animation for the background.
  void initAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 2,
      ),
    )..repeat(reverse: true);
    print("animation enabled: ${widget.animationEnabled}");
    if (widget.animationEnabled) {
      animation = Tween(
        begin: beginAmount,
        end: endAmount,
      ).animate(animationController);
    }
  }

  void setTimer() {
    //The event loop where the song and the playback time is checked.
    timer = Timer.periodic(Duration(milliseconds: 350), (timer) async {
      try {
        //Check if the user is changing the time via the slider.
        if (changing) return;
        await fetchCurrentSong();
        var isplaying = await isPlaying();
        shuffle = await playify.getShuffleMode();
        repeat = await playify.getRepeatMode();
        if (!changing) {
          var res = await playify.getPlaybackTime();
          var myVolume = await playify.getVolume();
          setState(() {
            currentTime = res.truncate();
            playing = isplaying;
            _animationImageSize = (isplaying) ? 0.9 : 0.86;
            if (myVolume != null) volume = myVolume * 100;
          });
        }
      } catch (e) {
        print(e);
      }
    });
  }

  ///Fetch info about the current playing song
  Future<void> fetchCurrentSong() async {
    try {
      if (currentSong == null) {
        int desiredWidth = (MediaQuery.of(context).size.width.toInt() < 800)
            ? MediaQuery.of(context).size.width.toInt()
            : 800;
        var res = await playify.nowPlaying(coverArtSize: desiredWidth);
        if (res != null) {
          store.dispatch(setCurrentSongAction(res.song));
        }
        setState(() {
          currentSong = res;
          updateBackgroundColor();
        });
        return;
      }
      var res = await playify.nowPlaying(coverArtSize: 1);

      if (res == null) {
        return;
      }

      //Check if the song is not the same, if not request a new version with a high res cover.
      //This is done in order to speed up the periodic timer.
      if (!isEqual(currentSong!.song, res.song)) {
        int desiredWidth = (MediaQuery.of(context).size.width.toInt() < 800)
            ? MediaQuery.of(context).size.width.toInt()
            : 800;

        res = await playify.nowPlaying(coverArtSize: desiredWidth);

        if (res == null) {
          return;
        }
        store.dispatch(setCurrentSongAction(res.song));

        setState(() {
          currentSong = res;
          updateBackgroundColor();
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        currentSong = null;
      });
    }
  }

  ///Fetch if there is a song currently playing.
  Future<bool> isPlaying() async {
    try {
      var res = await playify.isPlaying();
      return res;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

    if (permissionStatus == null) {
      return Container(
        child: Stack(
          children: [
            TransitionBackground(
              opacity: animation,
              color1: Colors.indigo.shade400,
              color2: Colors.deepPurple.shade400,
            ),
          ],
        ),
      );
    } else if (permissionStatus == PermissionStatus.denied) {
      return PermissionDeniedWidget(
        animation: animation,
        onPressed: () async {
          await AppSettings.openAppSettings();
          var perm = await Permission.mediaLibrary.request();
          setState(() {
            permissionStatus = perm;
          });
        },
      );
    }

    return StoreProvider(
      store: store,
      child: IgnorePointer(
        ignoring: changing || seeking,
        child: Stack(
          children: [
            TransitionBackground(
              opacity: animation,
              color1: firstColor,
              color2: secondColor,
            ),
            RoundedAppBar(),
            SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: (_height * spaceRatioPlayerAndTop)),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: [
                        SlideTransition(
                          position: _animationOffsetLeft,
                          child: SlideTransition(
                            position: _animationOffsetRight,
                            child: StoreConnector<AppState, List<Artist>>(
                              converter: (appstate) => appstate.state.artists,
                              builder: (storeContext, artists) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (updatedLibrary)
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MenuPage()));
                                  },
                                  onLongPress: () async {
                                    await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SongInfoDialog(
                                            songInformation: currentSong,
                                          );
                                        });
                                  },
                                  onVerticalDragEnd: (details) async {
                                    try {
                                      if (details.primaryVelocity == null)
                                        return;
                                      if (currentSong == null) return;
                                      setState(() {
                                        changing = true;
                                      });
                                      const int sensitivity = 300;
                                      if (details.primaryVelocity! >
                                          sensitivity) {
                                        var myalbum = artists
                                            .where((element) =>
                                                element.name ==
                                                currentSong!.artist.name)
                                            .toList()
                                            .first
                                            .albums
                                            .where((element) =>
                                                element.title ==
                                                currentSong!.album.title)
                                            .toList()
                                            .first;
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ListScreen(
                                                album: myalbum,
                                                listType: MusicListType.album,
                                                fetchAllAlbumSongs: true),
                                          ),
                                        );
                                      } else if (details.primaryVelocity! <
                                          -sensitivity) {
                                        var myartist = artists
                                            .where((element) =>
                                                element.name ==
                                                currentSong!.artist.name)
                                            .first
                                            .copy();

                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ListScreen(
                                              artist: myartist,
                                              listType: MusicListType.artist,
                                            ),
                                          ),
                                        );
                                      }
                                      setState(() {
                                        changing = false;
                                      });
                                    } catch (e) {
                                      print(e);
                                      setState(() {
                                        changing = false;
                                      });
                                    }
                                  },
                                  onHorizontalDragEnd: (details) async {
                                    try {
                                      if (details.primaryVelocity == null)
                                        return;
                                      setState(() {
                                        changing = true;
                                      });
                                      const int sensitivity = 300;
                                      if (details.primaryVelocity! >
                                          sensitivity) {
                                        _controllerRight.forward();
                                        await playify.previous();
                                      } else if (details.primaryVelocity! <
                                          -sensitivity) {
                                        _controllerLeft.forward();
                                        await playify.next();
                                      }
                                      setState(() {
                                        changing = false;
                                      });
                                    } catch (e) {
                                      print(e);
                                      setState(() {
                                        changing = false;
                                      });
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      AlbumCover(
                                        coverArt: currentSong?.album.coverArt,
                                        animationImageSize: _animationImageSize,
                                      ),
                                      if (currentSong != null)
                                        Positioned(
                                          left: 10,
                                          bottom: 35,
                                          child: SongTitleWidget(
                                            songTitle: currentSong!.song.title,
                                          ),
                                        ),
                                      if (currentSong != null)
                                        Positioned(
                                          left: 10,
                                          bottom: 10,
                                          child: SongSubtitleWidget(
                                            albumTitle:
                                                currentSong!.album.title,
                                            artistName:
                                                currentSong!.artist.name,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  TimeSlider(
                    currentTime: (currentSong != null)
                        ? ((currentTime < currentSong!.song.duration)
                            ? currentTime
                            : 0)
                        : 0,
                    duration: currentSong != null
                        ? currentSong!.song.duration.toInt()
                        : 100,
                    timeSliderParams: TimeSliderParams(
                      onChangeStart: (val) {
                        setState(() {
                          //While changing, cancel the timer so that the time
                          //doesn't jump while or right after changing the time.
                          changing = true;
                          timer?.cancel();
                        });
                      },
                      onChangeEnd: (val) async {
                        await playify.setPlaybackTime(val);
                        setTimer();
                        setState(() {
                          changing = false;
                        });
                      },
                      onChanged: (val) async {
                        try {
                          setState(() {
                            changing = true;
                            currentTime = val.toInt();
                          });
                        } catch (e) {
                          print(e);
                        }
                      },
                    ),
                  ),
                  Controls(
                    playing: playing,
                    arrowBackParams: ArrowBackParams(
                      onLongPressStart: (e) async {
                        try {
                          setState(() {
                            seeking = true;
                          });
                          await playify.seekBackward();
                        } catch (e) {
                          print(e);
                          setState(() {
                            seeking = false;
                          });
                        }
                      },
                      onLongPressEnd: (e) async {
                        try {
                          await playify.endSeeking();
                          setState(() {
                            seeking = false;
                          });
                        } catch (e) {
                          print(e);
                          setState(() {
                            seeking = false;
                          });
                        }
                      },
                      onTap: () async {
                        try {
                          setState(() {
                            changing = true;
                          });
                          _controllerRight.forward();
                          await playify.previous();
                          setState(() {
                            changing = false;
                            currentTime = 0;
                          });
                        } catch (e) {
                          print(e);
                        }
                      },
                    ),
                    arrowForwardParams: ArrowForwardParams(
                      onLongPressStart: (e) async {
                        try {
                          setState(() {
                            seeking = true;
                          });
                          await playify.seekForward();
                        } catch (e) {
                          print(e);
                          setState(() {
                            seeking = false;
                          });
                        }
                      },
                      onLongPressEnd: (e) async {
                        try {
                          await playify.endSeeking();
                          setState(() {
                            seeking = false;
                          });
                        } catch (e) {
                          print(e);
                          setState(() {
                            seeking = false;
                          });
                        }
                      },
                      onTap: () async {
                        try {
                          setState(() {
                            changing = true;
                          });
                          _controllerLeft.forward();
                          await playify.next();
                          setState(() {
                            changing = false;
                            currentTime = 0;
                          });
                        } catch (e) {
                          print(e);
                        }
                      },
                    ),
                    onPlayTap: () async {
                      try {
                        setState(() {
                          changing = true;
                        });
                        if (playing) {
                          await playify.pause();
                        } else {
                          await playify.play();
                        }
                        setState(() {
                          playing = !playing;
                          changing = false;
                        });
                      } catch (e) {
                        print(e);
                        setState(() {
                          changing = false;
                        });
                      }
                    },
                  ),
                  SecondaryMusicSettings(
                    volume: volume,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
