import 'dart:async';

import 'package:flutter/material.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  }

  void setTimer() {
    setState(() {
      timer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
        try {
          if (changing) return;
          await isPlaying();
          await fetchCurrentSong();
          Playify myplayify = Playify();
          var isplaying = await myplayify.isPlaying();
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
      print("set timer");
    });
  }

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
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

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
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                              image: currentSong.album.coverArt.image),
                          borderRadius: BorderRadius.circular(8)),
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.height * 0.5,
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(8)),
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
                    Text(currentSong != null ? currentSong.song.title : ""),
                    Text(currentSong != null ? currentSong.album.title : ""),
                    Text(currentSong != null ? currentSong.artist.name : ""),
                  ],
                ),
              ),
            if (currentSong != null)
              Container(
                child: IgnorePointer(
                  ignoring: currentSong == null || changing,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                            alignment: Alignment.center,
                            child: Text(formatSongTime(currentTime))),
                      ),
                      Expanded(
                        flex: 8,
                        child: Slider(
                          divisions: currentSong != null
                              ? currentSong.song.duration.toInt()
                              : 100,
                          value: currentTime.toDouble(),
                          min: 0,
                          max: currentSong != null
                              ? currentSong.song.duration
                              : 99,
                          onChangeStart: (val) {
                            setState(() {
                              changing = true;
                              timer.cancel();
                              print("cancelled timer");
                            });
                          },
                          onChangeEnd: (val) {
                            setTimer();
                            setState(() {
                              changing = false;
                            });
                          },
                          onChanged: (val) async {
                            try {
                              setState(() {
                                currentTime = val.truncate();
                              });
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
                            child: Text(formatSongTime(
                                currentSong.song.duration.truncate()))),
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
                            await playify.previous();
                            setState(() {
                              playing = !playing;
                              changing = false;
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[400],
                                shape: BoxShape.circle),
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
                            decoration: BoxDecoration(
                                color: Colors.grey[400],
                                shape: BoxShape.circle),
                            padding: EdgeInsets.all(16),
                            child: Icon(
                                !playing ? Icons.play_arrow : Icons.pause)),
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
                              playing = !playing;
                              changing = false;
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[400],
                                shape: BoxShape.circle),
                            padding: EdgeInsets.fromLTRB(16, 16, 12, 16),
                            child: Icon(Icons.arrow_forward_ios,
                                color: Colors.black)),
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
