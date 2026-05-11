import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/empty_state.dart';
import 'package:admin_patitas/widgets/minichip.dart';
import 'package:admin_patitas/widgets/solicitud_tile.dart';
import 'package:flutter/material.dart';

class AdopcionScreenMobile extends StatelessWidget {
  final String? refugio;
  final Map<String, List<Map<String, dynamic>>> porAnimal;
  final Future<void> Function() onRefresh;
  final Function(Map<String, dynamic>) onMostrarDetalle;
  const AdopcionScreenMobile({
    super.key,
    required this.refugio,
    required this.porAnimal,
    required this.onRefresh,
    required this.onMostrarDetalle,
  });

  @override
  Widget build(BuildContext context) {
    if (porAnimal.isEmpty) {
      return EmptyState(
        icon: Icons.pets_outlined,
        mensaje: 'Aún no hay solicitudes de adopción',
        onRefresh: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: porAnimal.entries.map((entry) {
          final solicitudes = entry.value;
          final animalNombre =
              solicitudes.first['animalNombre'] as String? ?? entry.key;

          final pendientes = solicitudes
              .where((s) => s['estado'] == 'pendiente')
              .length;
          final aprobadas = solicitudes
              .where((s) => s['estado'] == 'aprobado')
              .length;
          final rechazadas = solicitudes
              .where((s) => s['estado'] == 'rechazado')
              .length;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: ExpansionTile(
              shape: const Border(),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.pets,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              title: Text(
                animalNombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
              subtitle: Wrap(
                spacing: 6,
                children: [
                  if (pendientes > 0)
                    MiniChip(
                      label:
                          '$pendientes pendiente${pendientes > 1 ? 's' : ''}',
                      color: Colors.orange,
                    ),
                  if (aprobadas > 0)
                    MiniChip(
                      label: '$aprobadas aprobada${aprobadas > 1 ? 's' : ''}',
                      color: Colors.green,
                    ),
                  if (rechazadas > 0)
                    MiniChip(
                      label:
                          '$rechazadas rechazada${rechazadas > 1 ? 's' : ''}',
                      color: Colors.red,
                    ),
                ],
              ),
              children: solicitudes
                  .map(
                    (s) => SolicitudTile(
                      solicitud: s,
                      onTap: () => onMostrarDetalle(s),
                    ),
                  )
                  .toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
