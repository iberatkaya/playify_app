import 'package:flutter/material.dart';
import 'package:playify_app/screens/home/constants/constants.dart';

class RoundedAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    return Container(
      height: _height * topBarContainerHeightRatio,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor, // The color should be checked!
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 3),
            blurRadius: 3,
            color: Colors.black26,
          ),
        ],
      ),
      padding: EdgeInsets.only(top: _height * 0.05),
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Playify",
            textScaleFactor: 1.5,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade100,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
