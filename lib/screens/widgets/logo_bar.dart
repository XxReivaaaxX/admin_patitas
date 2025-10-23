import 'package:flutter/material.dart';

class LogoBar extends StatelessWidget {
  final Color colorIzq, colorDer;
  final double sizeText;
  final sizeImg;

  const LogoBar({
    Key? key,
    required this.sizeImg,
    required this.colorIzq,
    required this.colorDer,
    required this.sizeText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/img/Logo_AdminPatitas.png',
          fit: BoxFit.contain,
          height: sizeImg,
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              text: 'ADMIN',
              style: TextStyle(
                color: colorIzq,
                fontWeight: FontWeight.bold,
                fontSize: sizeText,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: 'PATITAS',
                  style: TextStyle(
                    color: colorDer,
                    fontWeight: FontWeight.bold,
                    fontSize: sizeText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
