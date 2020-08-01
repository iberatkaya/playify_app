import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:playify_app/classes/mood.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/components/profile/MoodBottomSheet.dart';
import 'package:playify_app/components/profile/recentMusic.dart';
import 'package:playify_app/utilities/moodUtility.dart';
import 'package:toast/toast.dart';
import './../components/profile/moodList.dart';

/// Dummy Data

List<SongInfo> recentSongs = [
  SongInfo(album: null, song: null, artist: null),
];

SongInfo favoriteSong;

Image favoriteSongPic =
    favoriteSong != null ? favoriteSong.album.coverArt : null;

String mostLoved =
    favoriteSong != null ? favoriteSong.song.title : "Your Current Fav Song!";

String mostLovedSongArtist =
    favoriteSong != null ? favoriteSong.song.artistName : "  ";

/*
************************/

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  Animation animation;
  dynamic currentMood = HappyMood();
  AnimationController animationController;

  @override
  void initState() {
    getCurrentMood();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1, milliseconds: 500),
    );
    animation = Tween(
      begin: 0.4,
      end: 0.8,
    ).animate(animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

   getCurrentMood() async {
    try {
      var local = await getMood();

      setState(() {
        currentMood = local;
      });
      print("Try To get Mood");
    } catch (e) {
      print(e);
    }
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
            ),
          ),
        ),
        SafeArea(
          child: ListView(
            children: <Widget>[
              /// Edit Icon
              Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    showBottomToSaveMood(context, getCurrentMood);
                  },
                ),
              ),

              /// Profile Picture Card
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: Container(
                  height: height * 0.3,
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
                    child: favoriteSongPic != null
                        ? CircleAvatar(
                            /// Uncomment this
                            backgroundImage: favoriteSongPic != null
                                ? favoriteSongPic.image
                                : null,
                            maxRadius: 120 * fontsize,
                            minRadius: 80 * fontsize,
                          )
                        : CircleAvatar(
                            child: Text("Fav Album Cover!"),
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
                            "${currentMood.moodText}",
                            style: TextStyle(
                              color: currentMood.moodTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: fontsize * 35,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: currentMood.moodIcon,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "$mostLoved",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: fontsize * 18,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(right: 15),
                      padding: const EdgeInsets.all(5.0),
                      child: Opacity(
                        opacity: 0.54,
                        child: Text(
                          "$mostLovedSongArtist",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: fontsize * 14,
                          ),
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
                  top: 15,
                  left: 10,
                  bottom: 12,
                ),
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    "Recently Played",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fontsize * 18,
                    ),
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
