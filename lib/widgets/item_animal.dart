import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';

class ItemAnimal extends StatelessWidget {
  final void Function()? onTap,
      onpressedModificar,
      onpressedEliminar,
      onPressedAdopcion;
  final String nombre, edad, estado, estadoAdopcion, imageUrl;
  final double sizeImg;

  const ItemAnimal({
    super.key,
    required this.sizeImg,
    required this.nombre,
    required this.edad,
    required this.estado,
    required this.estadoAdopcion,
    required this.imageUrl,
    required this.onTap,
    required this.onpressedModificar,
    required this.onpressedEliminar,
    required this.onPressedAdopcion,
  });

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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: imageUrl.isNotEmpty
                      ? (imageUrl.startsWith('data:image')
                          ? Image.memory(
                              Uri.parse(imageUrl).data!.contentAsBytes(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.pets,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.pets,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            ))
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.pets,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
              ),
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: TextForm(
                            lines: 1,
                            texto: nombre,
                            color: Colors.black,
                            size: 18,
                            aling: TextAlign.left,
                            negrita: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextForm(
                              lines: 1,
                              texto: '$edad | $estado',
                              color: Colors.black54,
                              size: 13,
                              aling: TextAlign.left,
                              negrita: FontWeight.normal,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: onpressedModificar,
                          icon: const Icon(Icons.edit, color: Colors.greenAccent),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(height: 10),
                        IconButton(
                          onPressed: onpressedEliminar,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(height: 10),
                        IconButton(
                          onPressed: onPressedAdopcion,
                          icon: Icon(
                            Icons.pets,
                            color: (estadoAdopcion == 'Disponible')
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          tooltip: 'Estado Adopción: $estadoAdopcion',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
