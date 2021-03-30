import 'package:flutter/material.dart';
import 'package:playify/playify.dart';

import 'package:playify_app/screens/home/widgets/volume_slider.dart';
import 'package:playify_app/utilities/extensions.dart';
import 'package:playify_app/utilities/utils.dart';

class SecondaryMusicSettings extends StatefulWidget {
  final double volume;

  const SecondaryMusicSettings({
    Key? key,
    required this.volume,
  }) : super(key: key);

  @override
  _SecondaryMusicSettingsState createState() => _SecondaryMusicSettingsState();
}

class _SecondaryMusicSettingsState extends State<SecondaryMusicSettings> {
  Shuffle shuffle = Shuffle.off;
  Repeat repeat = Repeat.none;
  Offset? _tapPosition;
  Playify playify = Playify();

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Spacer(),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTapDown: _storePosition,
              onTap: () async {
                final overlay = Overlay.of(context)?.context.findRenderObject();

                if (overlay != null && _tapPosition != null) {
                  await showMenu(
                    context: context,
                    items: <PopupMenuEntry>[
                      SliderEntry(
                        defaultVolume: widget.volume,
                      ),
                    ],
                    position: RelativeRect.fromRect(
                        _tapPosition! & const Size(0, 0),
                        Offset.zero & overlay.paintBounds.size),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: themeModeColor(
                        MediaQuery.of(context).platformBrightness,
                        Colors.blue.shade100),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: Text("Volume"),
                    ),
                    Divider(
                      height: 1,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.volume_up, size: 16),
                          Text(
                            widget.volume.toStringAsFixed(0) + "%",
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Spacer(),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: themeModeColor(MediaQuery.of(context).platformBrightness,
                    Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text("Shuffle"),
                  ),
                  Divider(
                    height: 1,
                  ),
                  DropdownButton<Shuffle>(
                    icon: Icon(Icons.shuffle, size: 16),
                    style: TextStyle(
                        fontSize: 12,
                        color: themeModeColor(
                            MediaQuery.of(context).platformBrightness,
                            Colors.black)),
                    underline: Container(),
                    items: <Shuffle>[...Shuffle.values].map((Shuffle value) {
                      return DropdownMenuItem<Shuffle>(
                        value: value,
                        child: Text(value.getValue()),
                      );
                    }).toList(),
                    value: shuffle,
                    onChanged: (val) async {
                      if (val != null) {
                        try {
                          setState(() {
                            shuffle = val;
                          });
                          await playify.setShuffleMode(val);
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: themeModeColor(MediaQuery.of(context).platformBrightness,
                    Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text("Repeat"),
                  ),
                  Divider(
                    height: 1,
                  ),
                  DropdownButton<Repeat>(
                    icon: Icon(Icons.repeat, size: 16),
                    style: TextStyle(
                        fontSize: 12,
                        color: themeModeColor(
                            MediaQuery.of(context).platformBrightness,
                            Colors.black)),
                    underline: Container(),
                    items: <Repeat>[...Repeat.values].map((Repeat value) {
                      return DropdownMenuItem<Repeat>(
                        value: value,
                        child: Text(value.getValue()),
                      );
                    }).toList(),
                    value: repeat,
                    onChanged: (val) async {
                      if (val != null) {
                        try {
                          setState(() {
                            repeat = val;
                          });
                          await playify.setRepeatMode(val);
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
