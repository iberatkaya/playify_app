import 'package:flutter/material.dart';
import 'package:playify_app/screens/widgets/transition_background.dart';

class PermissionDeniedWidget extends StatelessWidget {
  final void Function()? onPressed;
  final Animation<double> animation;

  const PermissionDeniedWidget({
    Key? key,
    required this.onPressed,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          TransitionBackground(
            opacity: animation,
            color1: Colors.indigo.shade400,
            color2: Colors.deepPurple.shade400,
          ),
          Positioned.fill(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      "Permission was denied!",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  FlatButton(
                      onPressed: onPressed,
                      color: Colors.purple[300],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Text("Give Permission"))
                ],
              ),
              alignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }
}
