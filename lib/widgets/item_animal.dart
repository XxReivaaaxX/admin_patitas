import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';

class ItemAnimal extends StatelessWidget {
  final void Function()? onTap, onpressedModificar, onpressedEliminar, onPressedAdopcion;
  final String nombre, edad, estado, estadoAdopcion, imageUrl;
  final double sizeImg;

  const ItemAnimal({
    Key? key,
    required this.sizeImg,
    required this.nombre,
    required this.edad,
    required this.estado,
    required this.estadoAdopcion,
    required this.onTap,
    required this.onpressedModificar,
    required this.onpressedEliminar,
    required this.onPressedAdopcion,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      color: Colors.white,
      shadowColor: Colors.grey,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Igual altura para todos
          children: [
            /// Imagen dinámica con botón fullscreen
            Expanded(
              flex: 1,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: imageUrl.isNotEmpty
                        ? Image.memory(
                            base64Decode(imageUrl.split(',').last),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.asset('assets/img/gatos_principal.jpg', fit: BoxFit.cover),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                      tooltip: 'Ver imagen completa',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              insetPadding: const EdgeInsets.all(10),
                              child: InteractiveViewer(
                                child: imageUrl.isNotEmpty
                                    ? Image.memory(base64Decode(imageUrl.split(',').last))
                                    : Image.asset('assets/img/gatos_principal.jpg'),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            /// Información del animal
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextForm(lines: 2, texto: nombre, color: Colors.black, size: 20, aling: TextAlign.left, negrita: FontWeight.bold),
                    const SizedBox(height: 8),
                    TextForm(lines: 2, texto: edad, color: Colors.black, size: 15, aling: TextAlign.left, negrita: FontWeight.normal),
                    TextForm(lines: 2, texto: estado, color: Colors.black, size: 15, aling: TextAlign.left, negrita: FontWeight.normal),
                  ],
                ),
              ),
            ),

            /// Botones de acción
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(onPressed: onpressedModificar, icon: const Icon(Icons.edit, color: Colors.greenAccent)),
                  IconButton(onPressed: onpressedEliminar, icon: const Icon(Icons.delete, color: Colors.red)),
                  IconButton(
                    onPressed: onPressedAdopcion,
                    icon: Icon(Icons.pets, color: (estadoAdopcion == 'Disponible') ? Colors.blue : Colors.grey),
                    tooltip: 'Estado Adopción: $estadoAdopcion',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


