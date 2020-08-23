import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/utilities/utils.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreProvider(
        store: store,
        child: Container(
          padding: EdgeInsets.only(top: 24),
          child: StoreConnector<AppState, AppState>(
              converter: (appstate) => appstate.state,
              builder: (storeContext, appstate) {
                List<Map<String, dynamic>> myartists = [];
                for (var i = 0; i < appstate.artists.length; i++) {
                  myartists.add({
                    "artist": appstate.artists[i].name,
                    "totalSeconds": appstate.artists[i].albums
                        .map((e) => e.songs)
                        .map((e) =>
                            e.map((e) => e.playCount).reduce((value, element) => value += element).toDouble())
                        .reduce((value, element) => value += element)
                  });
                }
                myartists.sort((a, b) => b["totalSeconds"].compareTo(a["totalSeconds"].toDouble()));
                Map<String, double> myartistsObj = new Map();
                double otherArtist = 0;
                double topArtist = 0;
                for (int i = 0; i < myartists.length; i++) {
                  if (appstate.settings.statisticNumberArtist > i) {
                    myartistsObj.putIfAbsent(myartists[i]["artist"], () => myartists[i]["totalSeconds"]);
                    topArtist += myartists[i]["totalSeconds"];
                  } else
                    otherArtist += myartists[i]["totalSeconds"];
                }
                if (myartists.length > appstate.settings.statisticNumberArtist) {
                  myartistsObj.putIfAbsent("Other", () => otherArtist);
                }

                List<Map<String, dynamic>> albums = [];
                for (var i = 0; i < appstate.artists.length; i++) {
                  for (var j = 0; j < appstate.artists[i].albums.length; j++) {
                    albums.add({
                      "title": appstate.artists[i].albums[j].title,
                      "artist": appstate.artists[i].name,
                      "totalSeconds": appstate.artists[i].albums[j].songs
                          .map((e) => e.playCount)
                          .reduce((value, element) => value += element)
                          .toDouble()
                    });
                  }
                }
                albums.sort((a, b) => b["totalSeconds"].compareTo(a["totalSeconds"].toDouble()));
                Map<String, double> albumObj = new Map();
                double otherAlbum = 0;
                double topAlbum = 0;
                for (int i = 0; i < albums.length; i++) {
                  if (appstate.settings.statisticNumberAlbum > i) {
                    albumObj.putIfAbsent(
                        albums[i]["title"] + " - " + albums[i]["artist"], () => albums[i]["totalSeconds"]);
                    topAlbum += albums[i]["totalSeconds"];
                  } else
                    otherAlbum += albums[i]["totalSeconds"];
                }
                if (albums.length > appstate.settings.statisticNumberAlbum) {
                  albumObj.putIfAbsent("Other", () => otherAlbum);
                }

                List<Map<String, dynamic>> songs = [];
                for (var i = 0; i < appstate.artists.length; i++) {
                  for (var j = 0; j < appstate.artists[i].albums.length; j++) {
                    for (var k = 0; k < appstate.artists[i].albums[j].songs.length; k++) {
                      songs.add({
                        "title": appstate.artists[i].albums[j].songs[k].title,
                        "artist": appstate.artists[i].name,
                        "album": appstate.artists[i].albums[j].title,
                        "totalSeconds": appstate.artists[i].albums[j].songs[k].playCount.toDouble()
                      });
                    }
                  }
                }
                songs.sort((a, b) => b["totalSeconds"].compareTo(a["totalSeconds"]));

                Map<String, double> songObj = new Map();
                double otherSong = 0;
                double topSong = 0;
                for (int i = 0; i < songs.length; i++) {
                  if (appstate.settings.statisticNumberSong > i) {
                    songObj.putIfAbsent(
                        songs[i]["title"] + " - " + songs[i]["artist"], () => songs[i]["totalSeconds"]);
                    topSong += songs[i]["totalSeconds"];
                  } else
                    otherSong += songs[i]["totalSeconds"];
                }
                if (songs.length > appstate.settings.statisticNumberSong) {
                  songObj.putIfAbsent("Other", () => otherSong);
                }

                if (appstate.artists.length == 0) {
                  return Container(
                    alignment: Alignment.center,
                    child: Text("You do not have any songs!",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  );
                }

                return ListView(
                  children: [
                    Text(
                      "Artists",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: PieChart(
                        dataMap: myartistsObj,
                        chartValueStyle: TextStyle(
                            fontSize: 12,
                            color: themeModeColor(MediaQuery.of(context).platformBrightness, Colors.black)),
                        legendPosition: LegendPosition.bottom,
                        chartRadius: MediaQuery.of(context).size.width * 0.75,
                      ),
                    ),
                    Text(
                      "Albums",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: PieChart(
                        dataMap: albumObj,
                        chartValueStyle: TextStyle(
                            fontSize: 12,
                            color: themeModeColor(MediaQuery.of(context).platformBrightness, Colors.black)),
                        legendPosition: LegendPosition.bottom,
                        chartRadius: MediaQuery.of(context).size.width * 0.75,
                      ),
                    ),
                    Text(
                      "Songs",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: PieChart(
                        dataMap: songObj,
                        chartValueStyle: TextStyle(
                            fontSize: 12,
                            color: themeModeColor(MediaQuery.of(context).platformBrightness, Colors.black)),
                        legendPosition: LegendPosition.bottom,
                        chartRadius: MediaQuery.of(context).size.width * 0.75,
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
