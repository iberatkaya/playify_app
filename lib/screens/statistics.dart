import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/utilities/statsUtilities/getTopAlbumsByPlayTime.dart';
import 'package:playify_app/utilities/statsUtilities/getTopArtistByPlayTime.dart';
import 'package:playify_app/utilities/statsUtilities/getTopSongsByPlayTime.dart';
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
                Map<String, double> myartistsObj =
                    getTopArtistByPlayTime(appstate);

                Map<String, double> albumObj = getTopAlbumsByPlayTime(appstate);

                Map<String, double> songObj = getTopSongsByPlayTime(appstate);

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
                return ListView(
                  physics:
                      ClampingScrollPhysics(), // For not to scroll unnecessary way
                  children: [
                    /// Artist Pie Chart
                    Text(
                      "Artists",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: PieChart(
                        dataMap: myartistsObj,
                        chartValueStyle: TextStyle(
                          fontSize: 12,
                          color: themeModeColor(
                              MediaQuery.of(context).platformBrightness,
                              Colors.black),
                        ),
                        legendPosition: LegendPosition.bottom,
                        chartRadius: MediaQuery.of(context).size.width * 0.75,
                      ),
                    ),

                    /// Albums Pie Chart
                    Text(
                      "Albums",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: PieChart(
                        dataMap: albumObj,
                        chartValueStyle: TextStyle(
                            fontSize: 12,
                            color: themeModeColor(
                                MediaQuery.of(context).platformBrightness,
                                Colors.black)),
                        legendPosition: LegendPosition.bottom,
                        chartRadius: MediaQuery.of(context).size.width * 0.75,
                      ),
                    ),

                    /// Songs Pie Chart
                    Text(
                      "Songs",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: PieChart(
                        dataMap: songObj,
                        chartValueStyle: TextStyle(
                            fontSize: 12,
                            color: themeModeColor(
                                MediaQuery.of(context).platformBrightness,
                                Colors.black)),
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
