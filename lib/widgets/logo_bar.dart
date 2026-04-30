import 'package:flutter/material.dart';

class LogoBar extends StatelessWidget {
  final Color colorIzq, colorDer;
  final double sizeText;
  final double sizeImg;

  const LogoBar({
    super.key,
    required this.sizeImg,
    required this.colorIzq,
    required this.colorDer,
    required this.sizeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 14),
      child: Row(
        children: [
          Image.asset(
            'assets/img/logo_petflow.png',
            fit: BoxFit.contain,
            height: sizeImg * 1.5,
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                text: 'PET',
                style: TextStyle(
                  color: colorIzq,
                  fontWeight: FontWeight.bold,
                  fontSize: sizeText,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'FLOW',
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
      ),
    );
  }
}
