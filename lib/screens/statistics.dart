import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/components/transitionbackground.dart';
import 'package:playify_app/constant/animationAmount.dart';
import 'package:playify_app/constant/colors.dart';
import 'package:playify_app/icons/playify_icon_icons.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/screens/graphdetail.dart';
import 'package:playify_app/utilities/statsUtilities/getTopAlbumsByPlayTime.dart';
import 'package:playify_app/utilities/statsUtilities/getTopArtistByPlayTime.dart';
import 'package:playify_app/utilities/statsUtilities/getTopSongsByPlayTime.dart';
import 'package:playify_app/utilities/utils.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  Animation animation; // Fading Animation
  AnimationController animationController; // Fading Animation Controller

  @override
  void initState() {
    initAnimation();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            tabs: [
              Tab(icon: Icon(PlayifyIcon.artist)),
              Tab(icon: Icon(PlayifyIcon.album)),
              Tab(icon: Icon(PlayifyIcon.song)),
            ],
          ),
        ),
        body: StoreProvider(
          store: store,
          child: Stack(
            children: [
              TransitionBackground(
                opacity: animation,
                color1: Colors.indigo[400],
                color2: Colors.deepPurple[400],
              ),
              Container(
                child: StoreConnector<AppState, AppState>(
                    converter: (appstate) => appstate.state,
                    builder: (storeContext, appstate) {
                      Map<String, double> myartistsObj = getTopArtistByPlayTime(appstate);

                      Map<String, double> albumObj = getTopAlbumsByPlayTime(appstate);

                      Map<String, double> songObj = getTopSongsByPlayTime(appstate);

                      /// if nothing to shown || No artists were found
                      if (appstate.artists.length == 0) {
                        return Container(
                          alignment: Alignment.center,
                          child: Text("You do not have any songs!",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                        );
                      }

                      /// 3 Pie Chart Wrapped With ListView
                      return TabBarView(
                        children: [
                          /// Artist Pie Chart
                          ListView(
                            padding: EdgeInsets.only(top: 24),
                            children: [
                              Text(
                                "Artists",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => GraphDetailScreen(
                                      graphType: GraphType.artist,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: PieChart(
                                    dataMap: myartistsObj,
                                    chartLegendSpacing: 20,
                                    colorList: colors
                                        .map((i) => Color(int.parse(i.replaceAll("#", ""), radix: 16)))
                                        .toList(),
                                    chartValueStyle: TextStyle(
                                      fontSize: 11,
                                      color: themeModeColor(
                                          MediaQuery.of(context).platformBrightness, Colors.black),
                                    ),
                                    legendPosition: LegendPosition.bottom,
                                    chartRadius: MediaQuery.of(context).size.width * 0.90,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          /// Albums Pie Chart
                          ListView(
                            padding: EdgeInsets.only(top: 24),
                            children: [
                              Text(
                                "Albums",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => GraphDetailScreen(
                                      graphType: GraphType.album,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: PieChart(
                                    chartLegendSpacing: 20,
                                    dataMap: albumObj,
                                    colorList: colors
                                        .map((i) => Color(int.parse(i.replaceAll("#", ""), radix: 16)))
                                        .toList(),
                                    chartValueStyle: TextStyle(
                                        fontSize: 11,
                                        color: themeModeColor(
                                            MediaQuery.of(context).platformBrightness, Colors.black)),
                                    legendPosition: LegendPosition.bottom,
                                    chartRadius: MediaQuery.of(context).size.width * 0.90,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          /// Songs Pie Chart
                          ListView(
                            padding: EdgeInsets.only(top: 24),
                            children: [
                              Text(
                                "Songs",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => GraphDetailScreen(
                                      graphType: GraphType.song,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: PieChart(
                                    dataMap: songObj,
                                    chartLegendSpacing: 20,
                                    colorList: colors
                                        .map((i) => Color(int.parse(i.replaceAll("#", ""), radix: 16)))
                                        .toList(),
                                    chartValueStyle: TextStyle(
                                        fontSize: 10,
                                        color: themeModeColor(
                                            MediaQuery.of(context).platformBrightness, Colors.black)),
                                    legendPosition: LegendPosition.bottom,
                                    chartRadius: MediaQuery.of(context).size.width * 0.90,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
