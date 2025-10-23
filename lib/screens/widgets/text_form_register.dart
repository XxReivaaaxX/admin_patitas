import 'package:flutter/material.dart';

class TextForm extends StatelessWidget {
  // This widget is the root of your application.
  final String texto;
  final int lines;
  final Color color;
  final double size;
  final TextAlign aling;
  final FontWeight negrita;

  const TextForm({
    Key? key,
    required this.lines,
    required this.texto,
    required this.color,
    required this.size,
    required this.aling,
    required this.negrita,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: aling,
      maxLines: lines,
      style: TextStyle(color: color, fontSize: size, fontWeight: negrita),
      overflow: TextOverflow.ellipsis,
    );
  }
}
