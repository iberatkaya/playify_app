import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:playify_app/classes/mood.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/components/profile/recentMusic.dart';
import './../components/profile/moodList.dart';

/// Dummy Data

List<SongInfo> recentSongs = [
  SongInfo(album: null, song: null, artist: null),
];
final happymood = HappyMood();

String profilePic =
    "https://media1.popsugar-assets.com/files/thumbor/0ebv7kCHr0T-_O3RfQuBoYmUg1k/475x60:1974x1559/fit-in/500x500/filters:format_auto-!!-:strip_icc-!!-/2019/09/09/023/n/1922398/9f849ffa5d76e13d154137.01128738_/i/Taylor-Swift.jpg";

String mostLoved = "Look What You Made Me Do";

/*
************************/

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  Animation animation;
  AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1, milliseconds: 500),
    );
    animation = Tween(
      begin: 0.4,
      end: 0.95,
    ).animate(animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Animation Controller Repeat
    animationController.repeat(reverse: true);

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final fontsize = MediaQuery.of(context).textScaleFactor;

    return Stack(
      children: <Widget>[
        FadeTransition(
          opacity: animation,
          child: Container(
            /// Background Theme
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                  spreadRadius: 10,
                  blurRadius: 15,
                  offset: Offset(10, 15), // changes position of shadow
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade700,
                  Colors.purple.shade700,
                ],
              ),
              color: Colors.white54,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: <Widget>[
              /// Profile Picture Card
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: height * 0.35,
                  margin: EdgeInsets.only(top: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 1.3,
                        color: Colors.white60,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(profilePic),
                      maxRadius: 120 * fontsize,
                      minRadius: 80 * fontsize,
                    ),
                  ),
                ),
              ),

              /// Mood & Most Loved
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Wrap(
                        children: <Widget>[
                          Text(
                            "${happymood.moodText}",
                            style: TextStyle(
                              color: happymood.moodTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: fontsize * 28,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: happymood.moodIcon,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "$mostLoved",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: fontsize * 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Recent Musics
              // Recent Title
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(
                  top: 50,
                  left: 10,
                  bottom: 12,
                ),
                child: Text(
                  "Recently Played",
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: fontsize * 18,
                  ),
                ),
              ),
              // Recent List
              Container(
                height: height * 0.2,
                margin: EdgeInsets.only(top: 0),
                child: GridView.builder(
                  itemCount: recentSongs.length,
                  itemBuilder: (context, index) {
                    var toPassSongInfo = recentSongs[index];

                    return RecentMusicContainer(songInfo: toPassSongInfo);
                  },
                  padding: EdgeInsets.only(left: 10),
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 1,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
