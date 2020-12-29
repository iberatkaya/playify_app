import 'package:flutter/material.dart';

import 'package:playify_app/utilities/utils.dart';

class ControlButton extends StatelessWidget {
  final void Function() onTap;
  final void Function(LongPressStartDetails) onLongPressStart;
  final void Function(LongPressEndDetails) onLongPressEnd;
  final Icon icon;
  final EdgeInsets padding;
  const ControlButton(
      {@required this.onTap,
      this.onLongPressStart,
      this.onLongPressEnd,
      this.padding,
      @required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: themeModeColor(
                MediaQuery.of(context).platformBrightness, Colors.blue[100]),
            shape: BoxShape.circle),
        padding: padding ?? EdgeInsets.zero,
        child: icon,
      ),
    );
  }
}
