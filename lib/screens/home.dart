import 'dart:async';
import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/classes/recentPlayedSong.dart';
import 'package:playify_app/components/transitionbackground.dart';
import 'package:playify_app/constant/animationAmount.dart';
import 'package:playify_app/redux/music/action.dart';
import 'package:playify_app/redux/recentplayedsongs/action.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/screens/menu.dart';
import 'package:playify_app/screens/profile.dart';
import 'package:playify_app/utilities/animation/backgroundColorFromAlbum.dart';
import 'package:playify_app/utilities/jsonify.dart';
import 'package:playify_app/utilities/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  AnimationController _controllerRight;
  AnimationController _controllerLeft;
  Animation<Offset> _animationOffsetRight;
  Animation<Offset> _animationOffsetLeft;
  Animation animation; // Fading Animation
  AnimationController animationController; // Fading Animation Controller
  PermissionStatus permissionStatus = PermissionStatus.undetermined;
  bool updatedLibrary = false;

  SongInfo currentSong;

  Playify playify = Playify();

  bool playing = false;

  bool changing = false;
  int currentTime = 0;

  Timer timer;

  double spaceRatioPlayerAndTop = 0.12;
  double topBarContainerHeightRatio = 0.25;

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
    _controllerRight = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _animationOffsetRight = Tween<Offset>(begin: Offset(0, 0), end: Offset(0.25, 0)).animate(CurvedAnimation(
      parent: _controllerRight,
      curve: Curves.fastOutSlowIn,
    ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controllerRight.reverse();
        }
      });
    _controllerLeft = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _animationOffsetLeft = Tween<Offset>(begin: Offset(0, 0), end: Offset(-0.25, 0)).animate(CurvedAnimation(
      parent: _controllerLeft,
      curve: Curves.fastOutSlowIn,
    ))
      ..addStatusListener((status) {
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
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  Future<void> fetchLibraryFromSP() async {
    try {
      setState(() {
        updatedLibrary = false;
      });
      //final stopwatch = Stopwatch()..start();
      var prefs = await SharedPreferences.getInstance();
      var res = prefs.getString("artists");
      if (res == null) {
        await updateLibrary();
      }
      List<dynamic> artistsMap = json.decode(res);
      List<Artist> artists = List<Artist>.from(artistsMap.map((e) => mapToArist(e)).toList());
      store.dispatch(setMusicLibraryAction(artists));
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

  Future<void> updateLibrary() async {
    try {
      //final stopwatch = Stopwatch()..start();
      var res = await playify.getAllSongs(coverArtSize: 400);
      List<Map<String, dynamic>> artistsMap = res.map((e) => artistToMap(e)).toList();
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString("artists", json.encode(artistsMap));
      store.dispatch(setMusicLibraryAction(res));
      //print('executed in ${stopwatch.elapsed.inMilliseconds}ms');
      setState(() {
        updatedLibrary = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        updatedLibrary = false;
      });
    }
  }

  ///Get recently played songs
  Future<void> getRecentSongs() async {
    var prefs = await SharedPreferences.getInstance();
    List<String> recentlist =
        prefs.getStringList("recentPlayed") != null ? prefs.getStringList("recentPlayed") : [];
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
          Playify myplayify = Playify();
          if (!changing) {
            var res = await myplayify.getPlaybackTime();
            setState(() {
              currentTime = res.truncate();
              playing = isplaying;
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
        var res = await playify.nowPlaying();
        setState(() {
          currentSong = res;
        });
        return;
      }
      //Check if the song is not the same, if not request a new version with a high res cover
      //This is done in order to speed up the periodic timer
      var res = await playify.nowPlaying(coverArtSize: 1);
      if (!isEqual(currentSong.song, res.song)) {
        res = await playify.nowPlaying();
        setState(() {
          currentSong = res;
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
    final _width = MediaQuery.of(context).size.width;
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
            Positioned.fill(
              child: Container(
                child: CircularProgressIndicator(),
                alignment: Alignment.center,
              ),
            )
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

    return Container(
      child: Stack(
        children: [
          TransitionBackground(
            opacity: animation,
            color1: Colors.indigo[400],
            color2: Colors.deepPurple[400],
          ),

          /// Top Container
          Container(
            height: _height * topBarContainerHeightRatio,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor, // The color should be checked!
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

          Container(
            padding: EdgeInsets.only(top: (_height * spaceRatioPlayerAndTop)),
            child: Column(
              children: <Widget>[
                Container(
                  child: Column(
                    children: [
                      IgnorePointer(
                        ignoring: changing,
                        child: SlideTransition(
                          position: _animationOffsetLeft,
                          child: SlideTransition(
                            position: _animationOffsetRight,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (updatedLibrary)
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (context) => MenuPage()));
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
                                        shape:
                                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        backgroundColor: Colors.white,
                                        titleTextStyle: TextStyle(
                                            fontWeight: FontWeight.w400, fontSize: 16, color: Colors.black),
                                        title: Container(
                                          child: Text(
                                            currentSong.song.title,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        content: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Album: " + currentSong.album.title,
                                              style: TextStyle(color: Colors.black),
                                            ),
                                            Text(
                                              "Artist: " + currentSong.artist.name,
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              onHorizontalDragEnd: (details) async {
                                try {
                                  setState(() {
                                    changing = true;
                                  });
                                  const int sensitivity = 300;
                                  if (details.primaryVelocity > sensitivity) {
                                    _controllerRight.forward();
                                    await playify.previous();
                                    setState(() {
                                      currentTime = 0;
                                    });
                                  } else if (details.primaryVelocity < -sensitivity) {
                                    _controllerLeft.forward();
                                    await playify.next();
                                    setState(() {
                                      currentTime = 0;
                                    });
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
                              child: Stack(children: [
                                if (currentSong != null)
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        shape: BoxShape.rectangle,
                                        image: currentSong.album.coverArt != null
                                            ? DecorationImage(
                                                image: Image.memory(currentSong.album.coverArt).image)
                                            : null,
                                        borderRadius: BorderRadius.circular(8)),
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    width: MediaQuery.of(context).size.height * 0.5,
                                  )
                                else
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[400], borderRadius: BorderRadius.circular(8)),
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    width: MediaQuery.of(context).size.height * 0.5,
                                  ),
                                if (currentSong != null)
                                  Positioned(
                                      left: 10,
                                      bottom: 35,
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        color: themeModeColor(
                                            MediaQuery.of(context).platformBrightness, Colors.black),
                                        child: Text(
                                            currentSong != null ? substring(currentSong.song.title, 25) : "",
                                            style: TextStyle(
                                                color: themeModeColor(
                                                    MediaQuery.of(context).platformBrightness, Colors.white),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18)),
                                      )),
                                if (currentSong != null)
                                  Positioned(
                                    left: 10,
                                    bottom: 10,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      color: themeModeColor(
                                          MediaQuery.of(context).platformBrightness, Colors.black),
                                      child: Column(
                                        children: [
                                          Text(
                                              currentSong != null
                                                  ? substring(currentSong.album.title, 25) +
                                                      " - " +
                                                      substring(currentSong.artist.name, 25)
                                                  : "",
                                              style: TextStyle(
                                                  color: themeModeColor(
                                                      MediaQuery.of(context).platformBrightness,
                                                      Colors.white),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                              ]),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  child: IgnorePointer(
                    ignoring: currentSong == null || changing,
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
                            divisions: currentSong != null ? currentSong.song.duration.toInt() : 100,
                            value: currentTime.toDouble(),
                            min: 0,
                            activeColor: Theme.of(context).primaryColor,
                            max: currentSong != null ? currentSong.song.duration : 99,
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
                                  currentTime = val.toInt();
                                });
                                //Set the selected time
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
                                  ? formatSongTime(currentSong.song.duration.truncate())
                                  : "00:00",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: IgnorePointer(
                          ignoring: changing,
                          child: GestureDetector(
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
                            child: Container(
                                decoration: BoxDecoration(
                                    color: themeModeColor(
                                        MediaQuery.of(context).platformBrightness, Colors.blue[100]),
                                    shape: BoxShape.circle),
                                padding: EdgeInsets.fromLTRB(12, 16, 16, 16),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                )),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: IgnorePointer(
                          ignoring: changing,
                          child: GestureDetector(
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
                            child: Container(
                                decoration: BoxDecoration(
                                    color: themeModeColor(
                                        MediaQuery.of(context).platformBrightness, Colors.blue[100]),
                                    shape: BoxShape.circle),
                                padding: EdgeInsets.all(16),
                                child: Icon(!playing ? Icons.play_arrow : Icons.pause)),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: IgnorePointer(
                          ignoring: changing,
                          child: GestureDetector(
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
                            child: Container(
                                decoration: BoxDecoration(
                                    color: themeModeColor(
                                        MediaQuery.of(context).platformBrightness, Colors.blue[100]),
                                    shape: BoxShape.circle),
                                padding: EdgeInsets.fromLTRB(16, 16, 12, 16),
                                child: Icon(Icons.arrow_forward_ios)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
