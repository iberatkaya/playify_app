import 'package:flutter/material.dart';

class TransitionBackground extends StatefulWidget {
  final Animation<double> opacity;
  final Color color1;
  final Color color2;

  TransitionBackground({@required this.opacity, @required this.color1, @required this.color2});

  @override
  _TransitionBackgroundState createState() => _TransitionBackgroundState();
}

class _TransitionBackgroundState extends State<TransitionBackground> {
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.opacity,
      child: Container(
        /// Background Theme
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              spreadRadius: 10,
              blurRadius: 15,
              offset: Offset(10, 15), // changes position of shadow
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              widget.color1,
              widget.color2,
            ],
          ),
        ),
      ),
    );
  }
}
