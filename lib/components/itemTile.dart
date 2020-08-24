import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:playify_app/classes/settings.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/utilities/utils.dart';

class ItemTile extends StatelessWidget {
  ItemTile(
      {@required this.title,
      @required this.icon,
      @required this.fn,
      this.padding,
      this.brightness,
      this.subtitle});
  final String title;
  final String subtitle;
  final Widget icon;
  final Function fn;
  final Brightness brightness;
  final EdgeInsets padding;

  Widget iconBuilder() {
    if (icon is Image) {
      return Container(
        width: 60,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: icon,
        ),
      );
    } else if (icon == null) {
      return Container(
        width: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: themeModeColor(brightness, Colors.black12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          title.substring(0, 2).toUpperCase(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
            if (subtitle == null) {
              return Container(
                padding: padding,
                child: ListTile(
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: settings.listTileFontSize.toDouble(),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: iconBuilder(),
                  onTap: fn,
                ),
              );
            }
            return Container(
              padding: padding,
              child: ListTile(
                title: Text(
                  title,
                  style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: settings.listTileFontSize.toDouble()),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(subtitle),
                leading: iconBuilder(),
                onTap: fn,
              ),
            );
          }),
    );
  }
}
