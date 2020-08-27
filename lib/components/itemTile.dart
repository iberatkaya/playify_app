import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:playify_app/classes/settings.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/utilities/utils.dart';

class ItemTile extends StatelessWidget {
  ItemTile({
    @required this.title,
    @required this.icon,
    @required this.fn,
    this.padding,
    this.brightness,
    this.subtitle,
    this.rounded = true,
    this.hasLeadingIcon = true,
  });
  final String title;
  final String subtitle;
  final Widget icon;
  final Function fn;
  final Brightness brightness;
  final EdgeInsets padding;
  final bool rounded;
  final bool hasLeadingIcon;

  Widget iconBuilder() {
    if (!hasLeadingIcon) return null;
    if (icon is Image) {
      return Container(
        width: 60,
        height: 60,
        child: CircleAvatar(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(!rounded ? 6 : 40),
            child: icon,
          ),
        ),
      );
    } else if (icon == null) {
      return Container(
        width: 60,
        height: 60,
        child: CircleAvatar(
          backgroundColor: themeModeColor(brightness, Colors.black12),
          child: ClipRRect(
            child: Container(
              child: Text(
                title.substring(0, 2).toUpperCase(),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeModeColor(
                      brightness,
                      Colors.black,
                    )),
              ),
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
