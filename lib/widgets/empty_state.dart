import 'package:flutter/material.dart';

class EmptyState extends StatefulWidget {
  final IconData icon;
  final String mensaje;
  final Future<void> Function() onRefresh;
  const EmptyState({
    super.key,
    required this.icon,
    required this.mensaje,
    required this.onRefresh,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            widget.mensaje,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refrescar'),
          ),
        ],
      ),
    );
  }
}
