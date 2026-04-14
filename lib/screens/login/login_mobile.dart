import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/background_image.dart';
import 'package:admin_patitas/widgets/custom_text_field.dart';
import 'package:admin_patitas/widgets/cut_custom.dart';
import 'package:admin_patitas/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class LoginMobile extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSignIn;
  final VoidCallback onResetPassword;

  const LoginMobile({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.errorMessage,
    required this.onSignIn,
    required this.onResetPassword,
  });

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double heightSize = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            //acomodar imagen y recorte de ondas
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.4,
                  child: const BackgroundImage(),
                ),
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.1,
                  child: OverflowBox(
                    minHeight: size.height,
                    maxHeight: size.height,
                    alignment: Alignment.topCenter,
                    child: ClipPath(
                      clipper: CutCustom(),
                      child: Container(
                        width: double.infinity,
                        height: size.height,
                        color: AppColors.backgroundLight,
                      ),
                    ),
                  ),
                ),
                /*
                Positioned(
                  // 'top' controla qué tan arriba o abajo queda sobre la imagen
                  // 0.3 es un 30% de la pantalla, justo antes del 40% de la curva
                  top: size.height * 0.2,
                  left: 0,
                  right: 0,
                  child: const Text(
                    'Iniciar Sesión',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.backgroundLight,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),*/
              ],
            ),

            // contenedor de formulario
            Container(
              color: AppColors.backgroundLight,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Iniciar Sesión',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: (heightSize < 800) ? 25.0 : 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: widget.emailController,
                    label: 'Correo electrónico',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    floatingLabel: false,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: widget.passwordController,
                    label: 'Contraseña',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    floatingLabel: false,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: widget.onResetPassword,
                      child: const Text(
                        '¿Olvidó la contraseña?',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        widget.errorMessage!,
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
                    isLoading: widget.isLoading,
                    onPressed: widget.isLoading ? null : widget.onSignIn,
                    isTransparent: false,
                  ),
                  const SizedBox(height: 15),
                  PrimaryButton(
                    text: 'Registrar',
                    icon: Icons.person_add_alt_1,
                    isLoading: widget.isLoading,
                    onPressed: widget.isLoading
                        ? null
                        : () => Navigator.pushNamed(context, '/register'),
                    isTransparent: true,
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/adoptions'),
                    icon: const Icon(Icons.pets, color: AppColors.secondary),
                    label: const Text(
                      'Ver Mascotas en Adopción',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60), // Margen final para respiro
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
