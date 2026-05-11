import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/estado_badge.dart';
import 'package:flutter/material.dart';

class SolicitudTile extends StatelessWidget {
  final Map<String, dynamic> solicitud;
  final VoidCallback onTap;
  final bool showAnimalName;

  const SolicitudTile({
    super.key,
    required this.solicitud,
    required this.onTap,
    this.showAnimalName = false,
  });

  @override
  Widget build(BuildContext context) {
    final estado = solicitud['estado'] as String? ?? 'pendiente';
    final nombre = solicitud['nombre'] as String? ?? '—';
    final correo = solicitud['correo'] as String? ?? '—';
    final animalNombre = solicitud['animalNombre'] as String? ?? '—';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar estado
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _estadoColor(estado).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _estadoIcon(estado),
                  color: _estadoColor(estado),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      correo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (showAnimalName)
                      Text(
                        'Para: $animalNombre',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              // Badge estado
              EstadoBadge(estado: estado),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'aprobado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _estadoIcon(String estado) {
    switch (estado) {
      case 'aprobado':
        return Icons.check_circle_outline;
      case 'rechazado':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty;
    }
  }
}
