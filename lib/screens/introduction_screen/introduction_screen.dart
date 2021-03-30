import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart' as i;

class IntroductionScreen extends StatelessWidget {
  final void Function() onDone;

  const IntroductionScreen({Key? key, required this.onDone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return i.IntroductionScreen(
        next: TextButton(
          child: Text("Next"),
          onPressed: () {},
        ),
        pages: [
          i.PageViewModel(
            image: Image.asset("assets/images/intro/1.png"),
            body: "Start listening music with the best music player available!",
            title: "Welcome To Playify",
          ),
          i.PageViewModel(
            image: Image.asset("assets/images/intro/2.png"),
            body:
                "The background color animation will change based on the song you listen. Click or swipe the album cover in any direction to interact!",
            title: "Help",
          ),
        ],
        done: Text(
          "Done",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onDone: onDone);
  }
}
