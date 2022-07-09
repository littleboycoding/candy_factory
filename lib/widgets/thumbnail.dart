import 'dart:typed_data';

import 'package:flutter/material.dart';

class Thumbnail extends StatelessWidget {
  const Thumbnail({
    Key? key,
    required this.heroTag,
    required this.binary,
  }) : super(key: key);

  final int heroTag;
  final Uint8List binary;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade50,
      child: Hero(
          tag: heroTag,
          child: Image.memory(binary, height: 350, fit: BoxFit.contain)),
    );
  }
}
