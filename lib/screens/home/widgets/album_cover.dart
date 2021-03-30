import 'dart:typed_data';

import 'package:flutter/material.dart';

class AlbumCover extends StatelessWidget {
  final Uint8List? coverArt;
  final double animationImageSize;

  const AlbumCover({
    Key? key,
    this.coverArt,
    required this.animationImageSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (coverArt != null) {
      return AnimatedContainer(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(image: Image.memory(coverArt!).image),
            borderRadius: BorderRadius.circular(8)),
        duration: Duration(milliseconds: 150),
        height: MediaQuery.of(context).size.width * animationImageSize,
        width: MediaQuery.of(context).size.width * animationImageSize,
      );
    }
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade400, borderRadius: BorderRadius.circular(8)),
      height: MediaQuery.of(context).size.width * 0.8,
      width: MediaQuery.of(context).size.width * 0.8,
      alignment: Alignment.center,
    );
  }
}
