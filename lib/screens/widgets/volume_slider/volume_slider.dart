import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:playify/playify.dart';

class SliderEntry extends PopupMenuEntry {
  final double defaultVolume;
  SliderEntry({
    @required this.defaultVolume,
  }) : assert(defaultVolume != null);

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
      width: 100,
      child: FlutterSlider(
        axis: Axis.vertical,
        jump: true,
        trackBar: FlutterSliderTrackBar(
          inactiveTrackBar: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.blue[100],
            border: Border.all(width: 3, color: Colors.blue),
          ),
          activeTrackBar: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).primaryColor),
        ),
        step: FlutterSliderStep(step: 1),
        values: [volume],
        min: 0,
        max: 100,
        tooltip: FlutterSliderTooltip(
            custom: (val) => Container(
                color: Colors.white,
                padding: EdgeInsets.all(8),
                child: Text(
                  (val as double).toStringAsFixed(0) + "%",
                )),
            direction: FlutterSliderTooltipDirection.top),
        rtl: true,
        onDragging: (handlerIndex, lowerValue, upperValue) async {
          try {
            final myVal = lowerValue / 100;
            setState(() {
              volume = lowerValue;
            });
            await playify.setVolume(myVal);
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}
