import 'package:admin_patitas/models/animal.dart';
import 'package:flutter/material.dart';

class CardInfoAnimal extends StatelessWidget {
  final Map datos;
  const CardInfoAnimal({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: datos.entries.map((entry) {
          return Container(
            padding: EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(entry.key, style: TextStyle(color: Colors.blue)),
                Text(entry.value),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
