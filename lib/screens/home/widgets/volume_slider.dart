import 'package:flutter/material.dart';
import 'package:playify/playify.dart';

class SliderEntry extends PopupMenuEntry {
  final double defaultVolume;
  SliderEntry({
    required this.defaultVolume,
  });

  @override
  State<StatefulWidget> createState() => SliderEntryState();

  @override
  double get height => 200;

  @override
  bool represents(n) {
    return true;
  }
}

class SliderEntryState extends State<SliderEntry> {
  Playify playify = Playify();
  double volume = 0;

  @override
  void initState() {
    super.initState();
    volume = widget.defaultVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 80,
      child: RotatedBox(
        quarterTurns: 3,
        child: Slider(
          key: ValueKey("volume_slider"),
          value: volume,
          min: 0,
          max: 100,
          onChanged: (newValue) async {
            try {
              final myVal = newValue / 100;
              setState(() {
                volume = newValue;
              });
              await playify.setVolume(myVal);
            } catch (e) {
              print(e);
            }
          },
        ),
      ),
    );
  }
}
