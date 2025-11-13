import 'package:admin_patitas/screens/register_refugio.dart';
import 'package:flutter/material.dart';

class MenuRefugios extends StatelessWidget {
  const MenuRefugios({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('¿Que quieres hacer?', style: TextStyle()),
            ElevatedButton.icon(
              icon: const Icon(Icons.house),
              label: const Text('Crear Nuevo Refugio'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterRefugio()),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_search),
              label: const Text('Entrar como colavorador'),
              onPressed: () => (),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.pets),
              label: const Text('Adopciones'),
              onPressed: () => (),
            ),
          ],
        ),
      ),
    );
  }
}
