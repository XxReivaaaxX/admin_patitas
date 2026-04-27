import 'package:admin_patitas/screens/externalAdoptionScreen/adopciones_external_screen.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/custom_text_field.dart';
import 'package:admin_patitas/widgets/glass_card.dart';
import 'package:admin_patitas/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class LoginWeb extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSignIn;
  final VoidCallback onResetPassword;
  const LoginWeb({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.errorMessage,
    required this.onSignIn,
    required this.onResetPassword,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animado suavemente

                //const SizedBox(height: 30),
                /*
                const Text(
                  'Facilitamos la gestión para que\nmejores el cuidado animal',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),*/
                const SizedBox(height: 40),

                // Tarjeta
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TweenAnimationBuilder(
                        duration: const Duration(seconds: 1),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double val, child) {
                          return Opacity(
                            opacity: val,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - val)),
                              child: child,
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/img/Logo_AdminPatitas.png',
                          height: 110,
                        ),
                      ),
                      const Text(
                        'Iniciar Sesión',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        controller: emailController,
                        label: 'Correo electrónico',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        floatingLabel: false,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: passwordController,
                        label: 'Contraseña',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        floatingLabel: false,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: onResetPassword,
                          child: const Text(
                            '¿Olvidó la contraseña?',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      PrimaryButton(
                        text: 'Ingresar',
                        icon: Icons.login,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : onSignIn,
                        isTransparent: false,
                      ),
                      const SizedBox(height: 15),

                      PrimaryButton(
                        text: 'Registrar',
                        icon: Icons.login,
                        isLoading: isLoading,
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pushNamed(context, '/register'),
                        isTransparent: true,
                      ),

                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/adoptions'),

                        icon: const Icon(
                          Icons.pets,
                          color: AppColors.secondary,
                        ),
                        label: const Text(
                          'Ver Mascotas en Adopción',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
