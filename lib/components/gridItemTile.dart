import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:playify_app/classes/settings.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/utilities/utils.dart';

class GridItemTile extends StatelessWidget {
  GridItemTile({
    @required this.title,
    @required this.icon,
    @required this.fn,
    this.subtitle,
    this.padding,
    this.brightness,
  });
  final String title;
  final String subtitle;
  final Widget icon;
  final Function fn;
  final Brightness brightness;
  final EdgeInsets padding;

  Widget iconBuilder() {
    if (icon is Image) {
      return Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: icon,
        ),
      );
    } else if (icon == null) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: themeModeColor(brightness, Colors.black12),
          alignment: Alignment.center,
          child: ClipRRect(
            child: Text(
              title.substring(0, 2).toUpperCase(),
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: themeModeColor(
                    brightness,
                    Colors.black,
                  )),
            ),
          ),
        ),
      );
    }
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: StoreConnector<AppState, Settings>(
          converter: (appstate) => appstate.state.settings,
          builder: (context, settings) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: fn,
              child: Container(
                padding: padding,
                child: Column(
                  children: [
                    Expanded(flex: 35, child: iconBuilder()),
                    Spacer(
                      flex: 1,
                    ),
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Spacer(
                            flex: 1,
                          ),
                          Expanded(
                            flex: 8,
                            child: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: (settings.listTileFontSize - 4).toDouble(),
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Spacer(
                            flex: 1,
                          ),
                        ],
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                            fontSize: (settings.listTileFontSize - 7).toDouble(),
                            color: themeModeColor(brightness, Colors.grey[600])),
                      ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
