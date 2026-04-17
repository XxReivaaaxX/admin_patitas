import 'package:admin_patitas/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;
  final Color? colorFondo;
  const CustomIconButton({
    super.key,
    required this.icono,
    required this.texto,
    required this.onTap,
    this.colorFondo,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icono, size: 18),
      label: Text(texto),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorFondo ?? AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
