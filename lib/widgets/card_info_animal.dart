import 'package:admin_patitas/models/animal.dart';
import 'package:flutter/material.dart';

class CardInfoAnimal extends StatelessWidget {
  final Map datos;
  const CardInfoAnimal({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: datos.entries.map((entry) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.key, style: TextStyle(color: Colors.blue)),
              Text(entry.value),
            ],
          );
        }).toList(),
      ),
    );
  }
}
