import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:playify_app/redux/utility/utility.dart';
import 'package:playify_app/screens/widgets/transition_background.dart';
import 'package:playify_app/constant/animation_amount.dart';
import 'package:playify_app/constant/colors.dart';
import 'package:playify_app/icons/playify_icon_icons.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/screens/graph_detail/graph_detail.dart';
import 'package:playify_app/utilities/stat_utilities/get_top_albums.dart';
import 'package:playify_app/utilities/stat_utilities/get_top_artists.dart';
import 'package:playify_app/utilities/stat_utilities/get_top_songs.dart';
import 'package:playify_app/utilities/utils.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  late Animation<double> animation; // Fading Animation
  late AnimationController animationController; // Fading Animation Controller
  bool loading = false;

  @override
  void initState() {
    initAnimation();
    super.initState();
  }

  Future<void> updateLibrary() async {
    try {
      if (loading) return;
      setState(() {
        loading = true;
      });
      int desiredWidth = ((MediaQuery.of(context).size.width / 2) < 400)
          ? (MediaQuery.of(context).size.width ~/ 2)
          : 400;
      await updateMusicLibrary(desiredWidth);
      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
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

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
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
                color1: Colors.indigo.shade400,
                color2: Colors.deepPurple.shade400,
              ),
              Container(
                child: StoreConnector<AppState, AppState>(
                  converter: (appstate) => appstate.state,
                  builder: (storeContext, appstate) {
                    Map<String, double> myartistsObj =
                        getTopArtistByPlayTime(appstate);

                    Map<String, double> albumObj =
                        getTopAlbumsByPlayTime(appstate);

                    Map<String, double> songObj =
                        getTopSongsByPlayTime(appstate);

                    if (loading) {
                      return Container(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      );
                    }

                    /// if nothing to shown || No artists were found
                    if (appstate.artists.length == 0) {
                      return Container(
                        alignment: Alignment.center,
                        child: Text("You do not have any songs!",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
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
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18),
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
                                      .map((i) => Color(int.parse(
                                          i.replaceAll("#", ""),
                                          radix: 16)))
                                      .toList(),
                                  chartValuesOptions: ChartValuesOptions(
                                    chartValueStyle: TextStyle(
                                      fontSize: 11,
                                      color: themeModeColor(
                                          MediaQuery.of(context)
                                              .platformBrightness,
                                          Colors.black),
                                    ),
                                  ),
                                  legendOptions: LegendOptions(
                                    legendPosition: LegendPosition.bottom,
                                  ),
                                  chartRadius:
                                      MediaQuery.of(context).size.width * 0.90,
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
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18),
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
                                      .map((i) => Color(int.parse(
                                          i.replaceAll("#", ""),
                                          radix: 16)))
                                      .toList(),
                                  chartValuesOptions: ChartValuesOptions(
                                    chartValueStyle: TextStyle(
                                        fontSize: 11,
                                        color: themeModeColor(
                                            MediaQuery.of(context)
                                                .platformBrightness,
                                            Colors.black)),
                                  ),
                                  legendOptions: LegendOptions(
                                    legendPosition: LegendPosition.bottom,
                                  ),
                                  chartRadius:
                                      MediaQuery.of(context).size.width * 0.90,
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
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18),
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
                                      .map((i) => Color(int.parse(
                                          i.replaceAll("#", ""),
                                          radix: 16)))
                                      .toList(),
                                  chartValuesOptions: ChartValuesOptions(
                                    chartValueStyle: TextStyle(
                                        fontSize: 10,
                                        color: themeModeColor(
                                            MediaQuery.of(context)
                                                .platformBrightness,
                                            Colors.black)),
                                  ),
                                  legendOptions: LegendOptions(
                                    legendPosition: LegendPosition.bottom,
                                  ),
                                  chartRadius:
                                      MediaQuery.of(context).size.width * 0.90,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              Positioned(
                right: 5,
                top: 5,
                child: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    updateLibrary();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
