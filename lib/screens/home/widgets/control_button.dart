import 'package:flutter/material.dart';

import 'package:playify_app/utilities/utils.dart';

class ControlButton extends StatelessWidget {
  final void Function()? onTap;
  final Key? key;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(LongPressEndDetails)? onLongPressEnd;
  final Icon icon;
  final EdgeInsets? padding;
  const ControlButton({
    required this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.padding,
    required this.icon,
    this.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: key,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: themeModeColor(MediaQuery.of(context).platformBrightness,
                Colors.blue.shade100),
            shape: BoxShape.circle),
        padding: padding ?? EdgeInsets.zero,
        child: icon,
      ),
    );
  }
}
