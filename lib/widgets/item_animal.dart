import 'dart:math';

import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';

class ItemAnimal extends StatelessWidget {
  final void Function()? onTap, onpressedModificar, onpressedEliminar;
  final String nombre, edad, estado;
  final sizeImg;

  const ItemAnimal({
    Key? key,
    required this.sizeImg,
    required this.nombre,
    required this.edad,
    required this.estado,
    required this.onTap,
    required this.onpressedModificar,
    required this.onpressedEliminar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      child: Card(
        margin: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/img/gatos_principal.jpg',
                    fit: BoxFit.cover,
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
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: onpressedModificar,
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: onpressedEliminar,
                          icon: Icon(Icons.delete),
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
