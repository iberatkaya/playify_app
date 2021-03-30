import 'package:flutter/material.dart';

import 'package:playify_app/screens/home/widgets/control_button.dart';

class Controls extends StatelessWidget {
  final ArrowBackParams? arrowBackParams;
  final ArrowForwardParams? arrowForwardParams;
  final void Function()? onPlayTap;
  final bool playing;

  const Controls({
    Key? key,
    this.arrowBackParams,
    this.arrowForwardParams,
    this.onPlayTap,
    required this.playing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ControlButton(
              onLongPressStart: arrowBackParams?.onLongPressStart,
              onLongPressEnd: arrowBackParams?.onLongPressEnd,
              onTap: arrowBackParams?.onTap,
              padding: EdgeInsets.fromLTRB(24, 16, 16, 16),
              icon: Icon(Icons.arrow_back_ios),
            ),
          ),
          Expanded(
            flex: 1,
            child: ControlButton(
              onTap: onPlayTap,
              padding: EdgeInsets.fromLTRB(14, 16, 16, 16),
              icon: Icon(!playing ? Icons.play_arrow : Icons.pause),
            ),
          ),
          Expanded(
            flex: 3,
            child: ControlButton(
              onLongPressStart: arrowForwardParams?.onLongPressStart,
              onLongPressEnd: arrowForwardParams?.onLongPressEnd,
              onTap: arrowForwardParams?.onTap,
              padding: EdgeInsets.fromLTRB(24, 16, 16, 16),
              icon: Icon(Icons.arrow_forward_ios),
            ),
          ),
        ],
      ),
    );
  }
}

class ArrowBackParams {
  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(LongPressEndDetails)? onLongPressEnd;
  final void Function()? onTap;

  ArrowBackParams({
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onTap,
  });
}

class ArrowForwardParams {
  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(LongPressEndDetails)? onLongPressEnd;
  final void Function()? onTap;

  ArrowForwardParams({
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onTap,
  });
}
