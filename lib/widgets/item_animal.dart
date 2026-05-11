import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/custom_double_text.dart';
import 'package:flutter/material.dart';

class ItemAnimal extends StatelessWidget {
  final void Function()? onTap,
      onpressedModificar,
      onpressedEliminar,
      onPressedAdopcion;
  final String nombre, especie, estado, estadoAdopcion, imageUrl, sexo, raza;
  final BoxConstraints constraints;
  final sizeImg;

  const ItemAnimal({
    super.key,
    required this.sizeImg,
    required this.nombre,
    required this.especie,
    required this.estado,
    required this.estadoAdopcion,
    required this.imageUrl,
    required this.onTap,
    required this.onpressedModificar,
    required this.onpressedEliminar,
    required this.onPressedAdopcion,
    required this.sexo,
    required this.raza,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Card(
        color: Colors.white,

        elevation: 6,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              // nombre y acciones
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),

                    IconButton(
                      onPressed: onpressedModificar,
                      icon: Icon(Icons.edit, color: AppColors.secondary),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    SizedBox(height: 8),
                    IconButton(
                      onPressed: onpressedEliminar,
                      icon: Icon(Icons.delete, color: Colors.red),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    SizedBox(height: 8),
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
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),

              //  imagen + detalles
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),

                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Imagen
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 130,
                          height: double.infinity,
                          child: imageUrl.isEmpty
                              ? Container(
                                  color: const Color(0xFFF3F4F6),
                                  child: const Icon(
                                    Icons.pets_rounded,
                                    size: 36,
                                    color: Color(0xFFCBCDD4),
                                  ),
                                )
                              : imageUrl.startsWith('data:image')
                              ? Image.memory(
                                  Uri.parse(imageUrl).data!.contentAsBytes(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFF3F4F6),
                                    child: const Icon(
                                      Icons.pets_rounded,
                                      size: 36,
                                      color: Color(0xFFCBCDD4),
                                    ),
                                  ),
                                )
                              : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFF3F4F6),
                                    child: const Icon(
                                      Icons.pets_rounded,
                                      size: 36,
                                      color: Color(0xFFCBCDD4),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Detalles
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Chip de estado (hembra/macho)
                              Row(
                                children: [
                                  sexo == "Hembra"
                                      ? Icon(
                                          Icons.female,
                                          color: Colors.pinkAccent,
                                        )
                                      : Icon(
                                          Icons.male,
                                          color: Colors.blueAccent,
                                        ),
                                  SizedBox(
                                    width: 8,
                                  ), // Adds space between icon and text
                                  Text(
                                    sexo,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: sexo == "Hembra"
                                          ? Colors.pinkAccent
                                          : Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // especie
                              CustomDoubleText(
                                text: especie,
                                typeText: "Especie",
                              ),
                              CustomDoubleText(text: raza, typeText: "Raza"),
                            ],
                          ),
                        ),
                      ),
                    ],
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
