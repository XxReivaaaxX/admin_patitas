import 'package:flutter/material.dart';

class CardRefugios extends StatelessWidget {
  final void Function()? onTap;
  final Color colorIzq, colorDer;
  final double sizeText;
  final String nombre;
  final String? correo;
  final sizeImg;

  const CardRefugios({
    Key? key,
    required this.sizeImg,
    required this.colorIzq,
    required this.colorDer,
    required this.sizeText,
    required this.nombre,
    required this.correo,
    required this.onTap,
  }) : super(key: key);

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
                    'assets/img/gatos_principal.jpg',
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
            Container(padding: const EdgeInsets.all(8.0), child: Text(correo!)),
          ],
        ),
      ),
    );
  }
}
