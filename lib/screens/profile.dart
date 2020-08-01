import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String mood = "Drama";
  String mostLoved = "Shake It Off";

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final fontsize = MediaQuery.of(context).textScaleFactor;

    return Container(
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
          colors: [
            Colors.blue.shade100,
            Colors.purple.shade200,
          ],
        ),
        color: Colors.white54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            /// Profile Picture Card
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: height * 0.35,
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
                    colors: [
                      Colors.pinkAccent.shade200,
                      Colors.teal.shade400,
                    ],
                  ),
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    /// Circle Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1.3,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            "https://media1.popsugar-assets.com/files/thumbor/0ebv7kCHr0T-_O3RfQuBoYmUg1k/475x60:1974x1559/fit-in/500x500/filters:format_auto-!!-:strip_icc-!!-/2019/09/09/023/n/1922398/9f849ffa5d76e13d154137.01128738_/i/Taylor-Swift.jpg"),
                        radius: 80 * fontsize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),

            /// Mood & Most Loved
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "$mood",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: fontsize * 26,
                    ),
                  ),
                  Text(
                    "$mostLoved",
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: fontsize * 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
