import 'package:admin_patitas/screens/login/login_mobile.dart';
import 'package:admin_patitas/screens/login/login_web.dart';
import 'package:admin_patitas/screens/pantalla_carga.dart';
import 'package:admin_patitas/services/refugio_management_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El formato del correo es inválido.';
      case 'user-not-found':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'missing-password':
        return 'La contraseña está vacía.';
      default:
        return 'Ocurrió un error: $code';
    }
  }

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Por favor, ingrese correo y contraseña.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        RefugioManagementService().registerUserEmail(
          userCredential.user!.uid,
          userCredential.user!.email!,
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SplashScreen(
            mensaje: 'Cargando aplicación...',
            nextRoute: '/refugio',
            mainScreen: false,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _errorMessage = _getErrorMessage(e.code));
    } catch (e) {
      if (mounted)
        setState(() => _errorMessage = "Error inesperado. Inténtelo de nuevo.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final TextEditingController emailController = TextEditingController();

    final String? email = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundLight,
          title: const Text(
            'Recuperar Contraseña',
            style: TextStyle(color: AppColors.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresa tu correo para restablecer la contraseña.',
                style: TextStyle(color: AppColors.backgroundDark),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: emailController,
                label: 'Correo electrónico',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                floatingLabel: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),

              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.backgroundDark),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, emailController.text.trim()),
              child: const Text(
                'Enviar',
                style: TextStyle(color: AppColors.backgroundLight),
              ),
            ),
          ],
        );
      },
    );

    if (email == null || email.isEmpty) return;
    if (!email.contains('@')) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo inválido'),
            backgroundColor: Colors.red,
          ),
        );
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Correo enviado a $email'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar el correo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return LoginMobile(
              emailController: _emailController,
              passwordController: _passwordController,
              isLoading: _isLoading,
              onSignIn: _signIn,
              onResetPassword: _resetPassword,
              errorMessage: _errorMessage,
            );
          } else {
            return Stack(
              children: [
                _buildBackground(),
                LoginWeb(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isLoading: _isLoading,
                  onSignIn: _signIn,
                  onResetPassword: _resetPassword,
                  errorMessage: _errorMessage,
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildBackground() {
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
