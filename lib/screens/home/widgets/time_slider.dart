import 'package:flutter/material.dart';

import 'package:playify_app/utilities/utils.dart';

class TimeSlider extends StatelessWidget {
  final int currentTime;
  final int? duration;
  final TimeSliderParams? timeSliderParams;

  const TimeSlider({
    Key? key,
    required this.currentTime,
    this.duration,
    this.timeSliderParams,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                formatSongTime(currentTime),
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Slider(
              label: formatSongTime(currentTime),
              divisions: duration ?? 100,
              value: currentTime.toDouble(),
              min: 0,
              activeColor: Theme.of(context).primaryColor,
              max: duration?.toDouble() ?? 99,
              onChangeStart: timeSliderParams?.onChangeStart,
              onChangeEnd: timeSliderParams?.onChangeEnd,
              onChanged: timeSliderParams?.onChanged,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                formatSongTime(duration?.truncate() ?? 0),
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeSliderParams {
  void Function(double)? onChangeStart;
  void Function(double)? onChangeEnd;
  void Function(double)? onChanged;

  TimeSliderParams({
    this.onChangeStart,
    this.onChangeEnd,
    this.onChanged,
  });
}
