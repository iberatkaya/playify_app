import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/constant/colors.dart';
import 'package:playify_app/redux/music/action.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/utilities/statsUtilities/getTopAlbumsByPlayTime.dart';
import 'package:playify_app/utilities/statsUtilities/getTopArtistByPlayTime.dart';
import 'package:playify_app/utilities/statsUtilities/getTopSongsByPlayTime.dart';
import 'package:playify_app/utilities/utils.dart';

enum GraphType {
  artist,
  album,
  song,
}

class GraphDetailScreen extends StatefulWidget {
  final GraphType graphType;
  GraphDetailScreen({@required this.graphType});

  @override
  _GraphDetailScreenState createState() => _GraphDetailScreenState();
}

class _GraphDetailScreenState extends State<GraphDetailScreen> {
  Playify playify = Playify();
  int totalStatistics = 18;

  String title() {
    if (widget.graphType == GraphType.artist) {
      return "Artists";
    } else if (widget.graphType == GraphType.album) {
      return "Albums";
    } else {
      return "Songs";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title()),
      ),
      body: Container(
        child: StoreProvider(
          store: store,
          child: StoreConnector<AppState, AppState>(
            converter: (appstate) => appstate.state,
            builder: (storeContext, appstate) {
              Map<String, double> myobj;
              if (widget.graphType == GraphType.artist)
                myobj = getTopArtistByPlayTime(appstate, showCounts: true, totalStatistics: totalStatistics);
              else if (widget.graphType == GraphType.album)
                myobj = getTopAlbumsByPlayTime(appstate, showCounts: true, totalStatistics: totalStatistics);
              else
                myobj = getTopSongsByPlayTime(appstate, showCounts: true, totalStatistics: totalStatistics);
              return ListView(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Total " + title() + ":  ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            )),
                        DropdownButton<int>(
                            value: totalStatistics,
                            items: [15, 18, 21, 24, 27]
                                .map((i) => DropdownMenuItem(
                                      child: Text(i.toString()),
                                      value: i,
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => totalStatistics = val)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: PieChart(
                      dataMap: myobj,
                      colorList:
                          colors.map((i) => Color(int.parse(i.replaceAll("#", ""), radix: 16))).toList(),
                      chartValueStyle: TextStyle(
                        fontSize: 11,
                        color: themeModeColor(MediaQuery.of(context).platformBrightness, Colors.black),
                      ),
                      legendPosition: LegendPosition.bottom,
                      chartRadius: MediaQuery.of(context).size.width,
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
