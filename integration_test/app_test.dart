// @dart = 2.8

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:playify/playify.dart';
import 'package:playify_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  ///Taken from https://github.com/flutter/flutter/issues/73355#issuecomment-805736745.
  ///Author: https://github.com/davidmartos96.
  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    bool timerDone = false;
    final timer = Timer(
        timeout, () => throw TimeoutException("Pump until has timed out"));
    while (timerDone != true) {
      await tester.pump();

      final found = tester.any(finder);
      if (found) {
        timerDone = true;
      }
    }
    timer.cancel();
  }

  group('Playify tests:', () {
    testWidgets('Press play button while music is paused',
        (WidgetTester tester) async {
      app.main(homeAnimationEnabled: false);
      final playButton = find.byKey(ValueKey('play_button'));
      await pumpUntilFound(tester, playButton);

      print("find $playButton");

      Playify playify = Playify();

      await tester.runAsync(() async {
        bool isPlaying = await playify.isPlaying();
        print("isPlaying $isPlaying");
        expect(isPlaying, false);
      });

      await tester.tap(playButton.last);

      await tester.runAsync(() async {
        bool isPlaying = await playify.isPlaying();

        print("isPlaying $isPlaying");
        expect(isPlaying, true);
      });
    });

    testWidgets('Press play button while music is playing',
        (WidgetTester tester) async {
      app.main(homeAnimationEnabled: false);
      final playButton = find.byKey(ValueKey('play_button'));
      await pumpUntilFound(tester, playButton);

      print("find $playButton");

      Playify playify = Playify();

      await tester.runAsync(() async {
        bool isPlaying = await playify.isPlaying();
        print("isPlaying $isPlaying");
        expect(isPlaying, true);
      });

      await tester.tap(playButton.last);

      await tester.runAsync(() async {
        bool isPlaying = await playify.isPlaying();

        print("isPlaying $isPlaying");
        expect(isPlaying, false);
      });
    });

    /*testWidgets('Change volume',
        (WidgetTester tester) async {
      app.main(homeAnimationEnabled: false);
      final volumeSlider = find.byKey(ValueKey('volume_slider'));
      await pumpUntilFound(tester, volumeSlider);


      print("find $volumeSlider");

      Playify playify = Playify();

      bool isPlaying = await playify.isPlaying();

      print("isPlaying $isPlaying");
      expect(isPlaying, true);

      await tester.(volumeSlider.last);

      isPlaying = await playify.isPlaying();

      print("isPlaying $isPlaying");
      expect(isPlaying, false);
    });*/
  });
}
