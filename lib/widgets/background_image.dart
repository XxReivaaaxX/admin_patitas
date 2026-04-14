import 'package:admin_patitas/utils/colors.dart';
import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/mascotas.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundDark.withValues(alpha: 0.2),
              AppColors.backgroundDark.withValues(alpha: 0.7),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
