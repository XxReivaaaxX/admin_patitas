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
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('¿Que quieres hacer?', style: TextStyle()),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.grey, width: 2),
                ),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),

                  side: const BorderSide(color: Colors.grey, width: 2),
                ),
              ),
              icon: const Icon(Icons.person_search),
              label: const Text('Entrar como colaborador'),
              onPressed: () => (),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.grey, width: 2),
                ),
              ),
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
