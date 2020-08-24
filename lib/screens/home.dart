import 'dart:async';
import 'package:flutter/material.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/components/transitionbackground.dart';
import 'package:playify_app/constant/animationAmount.dart';
import 'package:playify_app/screens/menu.dart';
import 'package:playify_app/utilities/animation/backgroundColorFromAlbum.dart';
import 'package:playify_app/utilities/utils.dart';

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

  SongInfo currentSong;

  Playify playify = Playify();

  bool playing = false;

  bool changing = false;
  int currentTime = 0;

  Timer timer;

  double spaceRatioPlayerAndTop = 0.15;
  double topBarContainerHeightRatio = 0.1;

  @override
  void initState() {
    super.initState();
    setTimer();
    initAnimation();

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
          //Don't check if the user is changing the time via the slider
          if (changing) return;
          var isplaying = await isPlaying();
          await fetchCurrentSong();
          Playify myplayify = Playify();
          if (isplaying == true && !changing) {
            var res = await myplayify.getPlaybackTime();
            setState(() {
              currentTime = res.truncate();
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
      var res = await playify.nowPlaying();
      if (currentSong == null) {
        setState(() {
          currentSong = res;
        });
      } else if (!isEqual(currentSong.song, res.song)) {
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
      setState(() {
        playing = res;
      });
      return res;
    } catch (e) {
      print(e);
      setState(() {
        playing = false;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

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
            padding: EdgeInsets.only(top: (_height * topBarContainerHeightRatio + 20)),
            child: Column(
              children: <Widget>[
                Container(
                  child: Column(
                    children: [
                      if (currentSong != null)
                        IgnorePointer(
                          ignoring: changing,
                          child: SlideTransition(
                            position: _animationOffsetLeft,
                            child: SlideTransition(
                              position: _animationOffsetRight,
                              child: GestureDetector(
                                onTap: () {
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
                                            ),
                                          ),
                                          content: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("Album: " + currentSong.album.title),
                                              Text("Artist: " + currentSong.artist.name),
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
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        shape: BoxShape.rectangle,
                                        image: DecorationImage(
                                            image: Image.memory(currentSong.album.coverArt).image),
                                        borderRadius: BorderRadius.circular(8)),
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    width: MediaQuery.of(context).size.height * 0.5,
                                  ),
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
                      else
                        Container(
                          decoration:
                              BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(8)),
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: MediaQuery.of(context).size.width * 0.95,
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
                              alignment: Alignment.center, child: Text(formatSongTime(currentTime))),
                        ),
                        Expanded(
                          flex: 8,
                          child: Slider(
                            divisions: currentSong != null ? currentSong.song.duration.toInt() : 100,
                            value: currentTime.toDouble(),
                            min: 0,
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
                              child: Text(currentSong != null
                                  ? formatSongTime(currentSong.song.duration.truncate())
                                  : "00:00")),
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
