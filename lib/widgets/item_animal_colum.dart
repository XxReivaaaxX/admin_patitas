import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';

class ItemAnimalColum extends StatelessWidget {
  final void Function()? onTap,
      onpressedModificar,
      onpressedEliminar,
      onPressedAdopcion;
  final String nombre, edad, estado, estadoAdopcion, imageUrl;
  final sizeImg;

  const ItemAnimalColum({
    super.key,
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
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(20),
      color: Colors.white,
      shadowColor: Colors.grey,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 10 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
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
              flex: 2,
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(10),
                        child: TextForm(
                          lines: 2,
                          texto: nombre,
                          color: Colors.black,
                          size: 20,
                          aling: TextAlign.center,
                          negrita: FontWeight.bold,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 25),
                        child: Column(
                          children: [
                            TextForm(
                              lines: 2,
                              texto: edad,
                              color: Colors.black,
                              size: 15,
                              aling: TextAlign.left,
                              negrita: FontWeight.normal,
                            ),
                            TextForm(
                              lines: 2,
                              texto: estado,
                              color: Colors.black,
                              size: 15,
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
            ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: onpressedModificar,
                        icon: Icon(Icons.edit, color: Colors.greenAccent),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                      SizedBox(height: 10),
                      IconButton(
                        onPressed: onpressedEliminar,
                        icon: Icon(Icons.delete, color: Colors.red),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                      SizedBox(height: 10),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
