import 'package:flutter/material.dart';
import 'package:playify/playify.dart';

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


  @override
  void initState() {
    super.initState();
    isPlaying().then((_) => fetchCurrentSong());
  }

  Future<void> fetchCurrentSong() async {
    try {
      var res = await playify.nowPlaying();
      setState(() {
        currentSong = res;
      });
    } catch (e) {
      print(e);
      setState(() {
        currentSong = null;
      });
    }
  }

  Future<void> isPlaying() async {
    try {
      var res = await playify.isPlaying();
      print(res);
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
            Container(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Wrap(alignment: WrapAlignment.center, children: [
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[400], shape: BoxShape.circle),
                          padding: EdgeInsets.fromLTRB(12, 16, 16, 16),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          )),
                    ]),
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
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[400], shape: BoxShape.circle),
                        padding: EdgeInsets.fromLTRB(16, 16, 12, 16),
                        child:
                            Icon(Icons.arrow_forward_ios, color: Colors.black)),
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
