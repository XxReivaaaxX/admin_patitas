import 'package:admin_patitas/utils/colors.dart';
import 'package:flutter/material.dart';

class BuildCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final int count;
  final VoidCallback onTap;
  final bool isPlaceholder;
  const BuildCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.count,
    required this.onTap,
    required this.isPlaceholder,
  });

  @override
  State<BuildCard> createState() => _BuildCardState();
}

class _BuildCardState extends State<BuildCard> {
  @override
  Widget build(BuildContext context) {
    final cardColor = AppColors.primary;
    //double widthSize = MediaQuery.of(context).size.width;
    //double sizeInput = (widthSize < 600) ? 160 : 300;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
        height: 150, // Altura fija para que el círculo resalte
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            // 1. EL CUERPO DE LA TARJETA (El rectángulo del fondo)
            Container(
              margin: EdgeInsets.only(left: 20),
              width: double.infinity,
              height: 110, // Un poco más bajo que el contenedor total
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              // Contenido del texto
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 110,
                  right: 20,
                ), // Espacio para el círculo

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,

                        child: Text(
                          '${widget.count}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 45, // Número grande como en la imagen
                            fontWeight:
                                FontWeight.w300, // Más delgado para elegancia
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. EL CÍRCULO CON LA IMAGEN (Alineado a la izquierda)
            Positioned(
              left: 0,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: cardColor, width: 6),
                ),
                child: ClipOval(
                  child: widget.isPlaceholder
                      ? Container(
                          color: Colors.white24,
                          child: const Icon(
                            Icons.pets,
                            size: 50,
                            color: Colors.white,
                          ),
                        )
                      : Image.asset(widget.imagePath, fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
