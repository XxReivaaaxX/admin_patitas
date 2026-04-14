import 'package:flutter/material.dart';

class CutCustom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // ajusta posicion de la curva con respecto al eje y
    final double waveY = size.height * 0.30;
    final double amplitude = size.height * 0.07;

    final path = Path();

    path.moveTo(size.width, waveY + amplitude); // empieza por la derecha

    path.cubicTo(
      size.width * 0.75,
      waveY + amplitude * 1, // control 1 → derecha hacia abajo
      size.width * 0.25,
      waveY - amplitude * 1, // control 2 → izquierda hacia arriba
      0,
      waveY, // termina a la izquierda
    );

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
