import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:playify_app/redux/store.dart';
import 'package:playify_app/utilities/utils.dart';

class ItemTile extends StatelessWidget {
  ItemTile({
    required this.title,
    required this.fn,
    this.icon,
    this.songID,
    this.padding,
    this.subtitle,
    this.rounded = true,
    this.hasLeadingIcon = true,
    this.addLeadingSpace = false,
  });
  final String title;
  final String? subtitle;
  final String? songID;
  final Widget? icon;
  final void Function() fn;
  final EdgeInsets? padding;
  final bool rounded;
  final bool hasLeadingIcon;
  final bool addLeadingSpace;

  Widget iconBuilder(Brightness brightness) {
    if (!hasLeadingIcon) return Container();
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
    return icon!;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;

    return StoreProvider(
      store: store,
      child: StoreConnector<AppState, AppState>(
          converter: (appstate) => appstate.state,
          builder: (context, appstate) {
            if (subtitle == null) {
              return Container(
                padding: padding,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: fn,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: iconBuilder(brightness),
                        ),
                        if (addLeadingSpace) Spacer(flex: 1),
                        if (appstate.currentSong != null &&
                            appstate.currentSong!.songID == songID)
                          Expanded(
                            flex: 10,
                            child: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: appstate.settings.listTileFontSize
                                    .toDouble(),
                                fontStyle: FontStyle.italic,
                                color: themeModeColor(
                                    brightness, Colors.purple.shade300),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          Expanded(
                            flex: 10,
                            child: Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: appstate.settings.listTileFontSize
                                    .toDouble(),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              );
            }
            if (appstate.currentSong != null &&
                appstate.currentSong!.songID == songID) {
              return Container(
                padding: padding,
                child: ListTile(
                  title: Text(
                    title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: appstate.settings.listTileFontSize.toDouble(),
                        color:
                            themeModeColor(brightness, Colors.purple.shade300),
                        fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: subtitle != null ? Text(subtitle!) : null,
                  leading: iconBuilder(brightness),
                  onTap: fn,
                ),
              );
            } else {
              return Container(
                padding: padding,
                child: ListTile(
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: appstate.settings.listTileFontSize.toDouble(),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: subtitle != null ? Text(subtitle!) : null,
                  leading: iconBuilder(brightness),
                  onTap: fn,
                ),
              );
            }
          }),
    );
  }
}
