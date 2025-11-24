import 'package:admin_patitas/models/vacuna.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VacunaCard extends StatelessWidget {
  final Vacuna vacuna;
  final VoidCallback? onDelete;

  const VacunaCard({super.key, required this.vacuna, this.onDelete});

  Color _getStatusColor() {
    if (vacuna.isVencida()) {
      return Colors.red;
    } else if (vacuna.isProximaAVencer()) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getStatusText() {
    if (vacuna.isVencida()) {
      return 'Vencida';
    } else if (vacuna.isProximaAVencer()) {
      return 'Próxima a vencer';
    } else {
      return 'Al día';
    }
  }

  IconData _getStatusIcon() {
    if (vacuna.isVencida()) {
      return Icons.error;
    } else if (vacuna.isProximaAVencer()) {
      return Icons.warning;
    } else {
      return Icons.check_circle;
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'No especificada';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre y estado
            Row(
              children: [
                Expanded(
                  child: Text(
                    vacuna.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: 16,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ],
            ),
            const Divider(height: 24),

            // Fecha de aplicación
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha de aplicación',
              _formatDate(vacuna.fecha),
              Colors.blue,
            ),
            const SizedBox(height: 12),

            // Próxima fecha
            if (vacuna.proximaFecha.isNotEmpty) ...[
              _buildInfoRow(
                Icons.event,
                'Próximo refuerzo',
                _formatDate(vacuna.proximaFecha),
                _getStatusColor(),
              ),
              const SizedBox(height: 12),
            ],

            // Veterinario
            if (vacuna.veterinario.isNotEmpty) ...[
              _buildInfoRow(
                Icons.person,
                'Veterinario',
                vacuna.veterinario,
                Colors.purple,
              ),
              const SizedBox(height: 12),
            ],

            // Lote
            if (vacuna.lote.isNotEmpty) ...[
              _buildInfoRow(Icons.qr_code, 'Lote', vacuna.lote, Colors.grey),
              const SizedBox(height: 12),
            ],

            // Observaciones
            if (vacuna.observaciones.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Observaciones:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vacuna.observaciones,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
