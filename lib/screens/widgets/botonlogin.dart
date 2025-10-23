import 'package:flutter/material.dart';

class BotonLogin extends StatelessWidget {
  final void Function()? onPressed;
  final String texto;
  final Color color, colorB;
  final double size;
  final FontWeight negrita;

  const BotonLogin({
    Key? key,
    required this.texto,
    required this.onPressed,
    required this.color,
    required this.colorB,
    required this.size,
    required this.negrita,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: Container(
        color: colorB,
        width: double.infinity,
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            texto,
            style: TextStyle(color: color, fontSize: size, fontWeight: negrita),
          ),
        ),
      ),
    );
  }
}
