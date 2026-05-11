import 'package:flutter/material.dart';

class EstadoBadge extends StatelessWidget {
  final String estado;
  final bool light;
  const EstadoBadge({super.key, required this.estado, this.light = false});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (estado) {
      case 'aprobado':
        color = Colors.green;
        label = 'Aprobado';
        break;
      case 'rechazado':
        color = Colors.red;
        label = 'Rechazado';
        break;
      default:
        color = Colors.orange;
        label = 'Pendiente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: light
            ? Colors.white.withValues(alpha: 0.2)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: light ? Colors.white54 : color.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: light ? Colors.white : color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
