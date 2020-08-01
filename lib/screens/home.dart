import 'dart:async';

import 'package:flutter/material.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/screens/menu.dart';
import 'package:playify_app/utils.dart';

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

  SongInfo currentSong;

  Playify playify = Playify();

  bool playing = false;

  bool changing = false;

  int currentTime = 0;

  Timer timer;

  @override
  void initState() {
    super.initState();
    setTimer();

    //Set the swipe right and left animation controllers. The offset determines how much left or right the animation will go, and the duration determines the speed of the animation
    _controllerRight = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _animationOffsetRight = Tween<Offset>(begin: Offset(0, 0), end: Offset(0.5, 0)).animate(CurvedAnimation(
      parent: _controllerRight,
      curve: Curves.fastOutSlowIn,
    ))
      ..addStatusListener((status) {
        print(status);
        if (status == AnimationStatus.completed) {
          _controllerRight.reverse();
        }
      });
    _controllerLeft = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _animationOffsetLeft = Tween<Offset>(begin: Offset(0, 0), end: Offset(-0.5, 0)).animate(CurvedAnimation(
      parent: _controllerLeft,
      curve: Curves.fastOutSlowIn,
    ))
      ..addStatusListener((status) {
        print(status);
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

  void setTimer() {
    setState(() {
      //The event loop where the song and the playback time is checked
      timer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
        try {
          //Don't check if the user is changing the time via the slider
          if (changing) return;
          await isPlaying();
          await fetchCurrentSong();
          Playify myplayify = Playify();
          if (playing == true && !changing) {
            var res = await myplayify.getPlaybackTime();
            print(res.truncate());
            setState(() {
              currentTime = res.truncate();
            });
          }
        } catch (e) {
          print(e);
        }
      });
      print("set timer");
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
  Future<void> isPlaying() async {
    try {
      var res = await playify.isPlaying();
      setState(() {
        playing = res;
      });
    } catch (e) {
      print(e);
      setState(() {
        playing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: AppBar().preferredSize.height * 0.6),
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 4),
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
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => MenuPage()));
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
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(image: currentSong.album.coverArt.image),
                                  borderRadius: BorderRadius.circular(8)),
                              height: MediaQuery.of(context).size.height * 0.5,
                              width: MediaQuery.of(context).size.height * 0.5,
                            ),
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
            if (currentSong != null)
              Container(
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(alignment: Alignment.center, child: Text(formatSongTime(currentTime))),
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
                        onChangeEnd: (val) {
                          //Resart the timer
                          setTimer();
                          setState(() {
                            changing = false;
                          });
                        },
                        onChanged: (val) async {
                          try {
                            setState(() {
                              changing = true;
                              timer.cancel();
                              print("cancelled timer");
                            });
                            //Set the selected time
                            await playify.setPlaybackTime(val);
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
                            await playify.previous();
                            setState(() {
                              changing = false;
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Container(
                            decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle),
                            padding: EdgeInsets.fromLTRB(12, 16, 16, 16),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.black,
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
                            decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle),
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
                            await playify.next();
                            setState(() {
                              changing = false;
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Container(
                            decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle),
                            padding: EdgeInsets.fromLTRB(16, 16, 12, 16),
                            child: Icon(Icons.arrow_forward_ios, color: Colors.black)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
