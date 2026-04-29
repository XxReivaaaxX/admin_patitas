import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:flutter/material.dart';

class CardInfoAnimal extends StatelessWidget {
  final Map datos;
  final int division;

  const CardInfoAnimal({
    super.key,
    required this.datos,
    required this.division,
  });

  @override
  Widget build(BuildContext context) {
    final datosFiltrados = datos.entries
        .where((entry) => entry.key != 'Nombre')
        .toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        double anchoDisponible = constraints.maxWidth;
        double espaciadoSeparacion = 10;
        double anchoCelda =
            (anchoDisponible - (espaciadoSeparacion * (division - 1))) /
            division;

        double alturaDeseada = 90.0;

        double ratioDinamico = anchoCelda / alturaDeseada;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: datosFiltrados.length,

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: division,
            crossAxisSpacing: espaciadoSeparacion,
            mainAxisSpacing: 15,
            childAspectRatio: ratioDinamico, // <--- Aquí usamos el cálculo
          ),
          itemBuilder: (context, index) {
            final entry = datosFiltrados[index];
            return Card(
              color: Colors.white,
              elevation: 3,
              shadowColor: AppColors.secondary,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.normal,
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
