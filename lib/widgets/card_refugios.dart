import 'package:flutter/material.dart';

class CardRefugios extends StatelessWidget {
  final void Function()? onTap;
  final Color colorIzq, colorDer;
  final double sizeText;
  final String nombre;
  final String? correo;
  final double? sizeImg;

  const CardRefugios({
    super.key,
    required this.sizeImg,
    required this.colorIzq,
    required this.colorDer,
    required this.sizeText,
    required this.nombre,
    required this.correo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Row(
                children: [
                  Image.asset(
                    'assets/img/cat_category_premium.png',
                    fit: BoxFit.fill,
                    height: sizeImg,
                  ),

                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(nombre),
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(8.0), child: Text(correo!)),
          ],
        ),
      ),
    );
  }
}
