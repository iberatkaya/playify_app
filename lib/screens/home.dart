import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/classes/recent_played_song.dart';
import 'package:playify_app/redux/actions/current_song/action.dart';
import 'package:playify_app/redux/actions/music/action.dart';
import 'package:playify_app/redux/actions/recent_played_songs/action.dart';
import 'package:playify_app/redux/utility/utility.dart';
import 'package:playify_app/screens/widgets/control_button/control_button.dart';
import 'package:playify_app/screens/widgets/transition_background.dart';
import 'package:playify_app/constant/animation_amount.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/screens/list.dart';
import 'package:playify_app/screens/menu.dart';
import 'package:playify_app/screens/widgets/volume_slider/volume_slider.dart';
import 'package:playify_app/utilities/extensions.dart';
import 'package:playify_app/utilities/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  double _animationImageSize = 0.9;
  AnimationController _controllerRight;
  AnimationController _controllerLeft;
  Animation<Offset> _animationOffsetRight;
  Animation<Offset> _animationOffsetLeft;
  Animation animation; // Fading Animation
  AnimationController animationController; // Fading Animation Controller
  PermissionStatus permissionStatus = PermissionStatus.undetermined;
  bool updatedLibrary = false;
  Color firstColor = Colors.indigo[400];
  Color secondColor = Colors.deepPurple[400];

  SongInformation currentSong;

  Playify playify = Playify();

  bool playing = false;

  bool changing = false;
  bool seeking = false;

  int currentTime = 0;
  double volume = 0;
  Shuffle shuffle = Shuffle.off;
  Repeat repeat = Repeat.none;

  Timer timer;

  double spaceRatioPlayerAndTop = 0.12;
  double topBarContainerHeightRatio = 0.16;

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

    //Set the swipe right and left animation controllers. The offset determines how much left or right the animation will go, and the duration determines the speed of the animation
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

  Offset _tapPosition;

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
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

  Future<void> updateBackgroundColor() async {
    try {
      if (currentSong == null) return;
      var paletteGenerator = await PaletteGenerator.fromImageProvider(
        Image.memory(currentSong.album.coverArt).image,
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

  Future<void> fetchLibraryFromSP() async {
    try {
      setState(() {
        updatedLibrary = false;
      });
      var prefs = await SharedPreferences.getInstance();

      //Used to update the library on updates
      var update = prefs.getBool("update4");

      var artistsJson = prefs.getString("artists");
      var playlistsJson = prefs.getString("playlists");

      if (artistsJson == null || update == null) {
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

  Future<void> updateLibrary() async {
    try {
      //final stopwatch = Stopwatch()..start();
      int desiredWidth = ((MediaQuery.of(context).size.width / 2) < 400)
          ? (MediaQuery.of(context).size.width ~/ 2)
          : 400;
      await updateMusicLibrary(desiredWidth);
      //print('executed in ${stopwatch.elapsed.inMilliseconds}ms');
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

  ///Get recently played songs
  Future<void> getRecentSongs() async {
    var prefs = await SharedPreferences.getInstance();
    List<String> recentlist = prefs.getStringList("recentPlayed") != null
        ? prefs.getStringList("recentPlayed")
        : [];
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
  }

  ///Create an animation for the background
  void initAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 2,
      ),
    )..repeat(reverse: true);

    animation = Tween(
      begin: beginAmount,
      end: endAmount,
    ).animate(animationController);
  }

  void setTimer() {
    setState(() {
      //The event loop where the song and the playback time is checked
      timer = Timer.periodic(Duration(milliseconds: 350), (timer) async {
        try {
          //Check if the user is changing the time via the slider
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
              volume = myVolume * 100;
            });
          }
        } catch (e) {
          print(e);
        }
      });
    });
  }

  //Fetch info about the current playing song
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

      //Check if the song is not the same, if not request a new version with a high res cover
      //This is done in order to speed up the periodic timer
      if (!isEqual(currentSong.song, res.song)) {
        int desiredWidth = (MediaQuery.of(context).size.width.toInt() < 800)
            ? MediaQuery.of(context).size.width.toInt()
            : 800;

        res = await playify.nowPlaying(coverArtSize: desiredWidth);
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

  //Fetch if there is a song currently playing
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

    if (permissionStatus == PermissionStatus.undetermined) {
      return Container(
        child: Stack(
          children: [
            TransitionBackground(
              opacity: animation,
              color1: Colors.indigo[400],
              color2: Colors.deepPurple[400],
            ),
          ],
        ),
      );
    } else if (permissionStatus == PermissionStatus.denied) {
      return Container(
        child: Stack(
          children: [
            TransitionBackground(
              opacity: animation,
              color1: Colors.indigo[400],
              color2: Colors.deepPurple[400],
            ),
            Positioned.fill(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        "Permission was denied!",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                    FlatButton(
                        onPressed: () async {
                          await AppSettings.openAppSettings();
                          var perm = await Permission.mediaLibrary.request();
                          setState(() {
                            permissionStatus = perm;
                          });
                        },
                        color: Colors.purple[300],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Text("Give Permission"))
                  ],
                ),
                alignment: Alignment.center,
              ),
            ),
          ],
        ),
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
            Container(
              height: _height * topBarContainerHeightRatio,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .primaryColor, // The color should be checked!
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 3),
                    blurRadius: 3,
                    color: Colors.black26,
                  ),
                ],
              ),
              padding: EdgeInsets.only(top: _height * 0.05),
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Playify",
                    textScaleFactor: 1.5,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade100,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
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
                                          return AlertDialog(
                                            actions: [
                                              FlatButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("OK"))
                                            ],
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            backgroundColor: Colors.white,
                                            titleTextStyle: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                                color: Colors.black),
                                            title: Container(
                                              child: Text(
                                                currentSong.song.title,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                            content: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Album: " +
                                                      currentSong.album.title,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  "Artist: " +
                                                      currentSong.artist.name,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  onVerticalDragEnd: (details) async {
                                    try {
                                      if (currentSong == null) return;
                                      setState(() {
                                        changing = true;
                                      });
                                      const int sensitivity = 300;
                                      if (details.primaryVelocity >
                                          sensitivity) {
                                        var myalbum = artists
                                            .where((element) =>
                                                element.name ==
                                                currentSong.artist.name)
                                            .toList()
                                            .first
                                            .albums
                                            .where((element) =>
                                                element.title ==
                                                currentSong.album.title)
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
                                      } else if (details.primaryVelocity <
                                          -sensitivity) {
                                        var myartist = artists
                                            .where((element) =>
                                                element.name ==
                                                currentSong.artist.name)
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
                                      setState(() {
                                        changing = true;
                                      });
                                      const int sensitivity = 300;
                                      if (details.primaryVelocity >
                                          sensitivity) {
                                        _controllerRight.forward();
                                        await playify.previous();
                                      } else if (details.primaryVelocity <
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
                                      if (currentSong != null)
                                        AnimatedContainer(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              image:
                                                  currentSong.album.coverArt !=
                                                          null
                                                      ? DecorationImage(
                                                          image: Image.memory(
                                                                  currentSong
                                                                      .album
                                                                      .coverArt)
                                                              .image)
                                                      : null,
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          duration: Duration(milliseconds: 150),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              _animationImageSize,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              _animationImageSize,
                                        )
                                      else
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[400],
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          alignment: Alignment.center,
                                        ),
                                      if (currentSong != null)
                                        Positioned(
                                            left: 10,
                                            bottom: 35,
                                            child: Container(
                                              padding: EdgeInsets.all(4),
                                              color: themeModeColor(
                                                  MediaQuery.of(context)
                                                      .platformBrightness,
                                                  Colors.black),
                                              child: Text(
                                                  currentSong != null
                                                      ? substring(
                                                          currentSong
                                                              .song.title,
                                                          25)
                                                      : "",
                                                  style: TextStyle(
                                                      color: themeModeColor(
                                                          MediaQuery.of(context)
                                                              .platformBrightness,
                                                          Colors.white),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 18)),
                                            )),
                                      if (currentSong != null)
                                        Positioned(
                                          left: 10,
                                          bottom: 10,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            color: themeModeColor(
                                                MediaQuery.of(context)
                                                    .platformBrightness,
                                                Colors.black),
                                            child: Column(
                                              children: [
                                                Text(
                                                    currentSong != null
                                                        ? substring(
                                                                currentSong
                                                                    .album
                                                                    .title,
                                                                25) +
                                                            " - " +
                                                            substring(
                                                                currentSong
                                                                    .artist
                                                                    .name,
                                                                25)
                                                        : "",
                                                    style: TextStyle(
                                                        color: themeModeColor(
                                                            MediaQuery.of(
                                                                    context)
                                                                .platformBrightness,
                                                            Colors.white),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12)),
                                              ],
                                            ),
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
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              formatSongTime(currentTime),
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: Slider(
                            label: formatSongTime(currentTime),
                            divisions: currentSong != null
                                ? currentSong.song.duration.toInt()
                                : 100,
                            value: (currentSong != null)
                                ? ((currentTime.toDouble() <
                                        currentSong.song.duration)
                                    ? currentTime.toDouble()
                                    : 0)
                                : 0,
                            min: 0,
                            activeColor: Theme.of(context).primaryColor,
                            max: currentSong != null
                                ? currentSong.song.duration
                                : 99,
                            onChangeStart: (val) {
                              setState(() {
                                //While changing, cancel the timer so that the time doesn't jump while or right after changing the time
                                changing = true;
                                timer.cancel();
                              });
                            },
                            onChangeEnd: (val) async {
                              //Resart the timer
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
                                  //Set the selected time
                                  currentTime = val.toInt();
                                });
                              } catch (e) {
                                print(e);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              currentSong != null
                                  ? formatSongTime(
                                      currentSong.song.duration.truncate())
                                  : "00:00",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ControlButton(
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
                            padding: EdgeInsets.fromLTRB(24, 16, 16, 16),
                            icon: Icon(Icons.arrow_back_ios),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ControlButton(
                            onTap: () async {
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
                            padding: EdgeInsets.fromLTRB(14, 16, 16, 16),
                            icon:
                                Icon(!playing ? Icons.play_arrow : Icons.pause),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: ControlButton(
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
                            padding: EdgeInsets.fromLTRB(24, 16, 16, 16),
                            icon: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 24),
                    child: Row(
                      children: [
                        Spacer(),
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTapDown: _storePosition,
                            onTap: () async {
                              final RenderBox overlay = Overlay.of(context)
                                  .context
                                  .findRenderObject();

                              await showMenu(
                                context: context,
                                items: <PopupMenuEntry>[
                                  SliderEntry(
                                    defaultVolume: volume,
                                  ),
                                ],
                                position: RelativeRect.fromRect(
                                    _tapPosition & const Size(0, 0),
                                    Offset.zero & overlay.size),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: themeModeColor(
                                      MediaQuery.of(context).platformBrightness,
                                      Colors.blue[100]),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 3),
                                    child: Text("Volume"),
                                  ),
                                  Divider(
                                    height: 1,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.volume_up, size: 16),
                                        Text(
                                          volume.toStringAsFixed(0) + "%",
                                          style: TextStyle(fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        Expanded(
                          flex: 3,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: themeModeColor(
                                  MediaQuery.of(context).platformBrightness,
                                  Colors.blue[100]),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 3),
                                  child: Text("Shuffle"),
                                ),
                                Divider(
                                  height: 1,
                                ),
                                DropdownButton<Shuffle>(
                                  icon: Icon(Icons.shuffle, size: 16),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: themeModeColor(
                                          MediaQuery.of(context)
                                              .platformBrightness,
                                          Colors.black)),
                                  underline: Container(),
                                  items: <Shuffle>[...Shuffle.values]
                                      .map((Shuffle value) {
                                    return DropdownMenuItem<Shuffle>(
                                      value: value,
                                      child: Text(value.getValue()),
                                    );
                                  }).toList(),
                                  value: shuffle,
                                  onChanged: (val) async {
                                    try {
                                      setState(() {
                                        shuffle = val;
                                      });
                                      await playify.setShuffleMode(val);
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                        Expanded(
                          flex: 3,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: themeModeColor(
                                  MediaQuery.of(context).platformBrightness,
                                  Colors.blue[100]),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 3),
                                  child: Text("Repeat"),
                                ),
                                Divider(
                                  height: 1,
                                ),
                                DropdownButton<Repeat>(
                                  icon: Icon(Icons.repeat, size: 16),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: themeModeColor(
                                          MediaQuery.of(context)
                                              .platformBrightness,
                                          Colors.black)),
                                  underline: Container(),
                                  items: <Repeat>[...Repeat.values]
                                      .map((Repeat value) {
                                    return DropdownMenuItem<Repeat>(
                                      value: value,
                                      child: Text(value.getValue()),
                                    );
                                  }).toList(),
                                  value: repeat,
                                  onChanged: (val) async {
                                    try {
                                      setState(() {
                                        repeat = val;
                                      });
                                      await playify.setRepeatMode(val);
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
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
