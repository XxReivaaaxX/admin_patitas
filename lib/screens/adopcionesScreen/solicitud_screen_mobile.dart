import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/empty_state.dart';
import 'package:admin_patitas/widgets/solicitud_tile.dart';
import 'package:flutter/material.dart';

class SolicitudScreenMobile extends StatelessWidget {
  final String? refugio;
  final List<Map<String, dynamic>> todasLasSolicitudes;
  final Future<void> Function() onRefresh;
  final Function(Map<String, dynamic>) onMostrarDetalle;
  const SolicitudScreenMobile({
    super.key,
    this.refugio,
    required this.onRefresh,
    required this.onMostrarDetalle,
    required this.todasLasSolicitudes,
  });

  @override
  Widget build(BuildContext context) {
    if (todasLasSolicitudes.isEmpty) {
      return EmptyState(
        icon: Icons.inbox_outlined,
        mensaje: 'No hay solicitudes registradas todavía',
        onRefresh: onRefresh,
      );
    }

    final ordenadas = List<Map<String, dynamic>>.from(todasLasSolicitudes)
      ..sort((a, b) {
        const orden = {'pendiente': 0, 'aprobado': 1, 'rechazado': 2};
        return (orden[a['estado']] ?? 3).compareTo(orden[b['estado']] ?? 3);
      });

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ordenadas.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SolicitudTile(
            solicitud: ordenadas[i],
            onTap: () => onMostrarDetalle(ordenadas[i]),
            showAnimalName: true,
          ),
        ),
      ),
    );
  }
}
