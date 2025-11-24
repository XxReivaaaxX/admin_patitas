import 'package:admin_patitas/services/refugio_management_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'pantalla_carga.dart';

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
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'user-not-found':
        return 'No existe un usuario con este correo electrónico.';
      case 'missing-password':
        return 'El campo de contraseña está vacío.';
      case 'invalid-credential':
        return 'El correo o contraseña están incorrectos.';
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado.';
      case 'weak-password':
        return 'La contraseña es demasiado débil (debe tener al menos 6 caracteres).';
      default:
        return 'Ocurrió un error de autenticación: $code';
    }
  }

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingrese su correo y contraseña.';
        _isLoading = false;
      });
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

      log("¡Inicio de sesión exitoso!", name: 'Auth');

      // Register user email in database for collaborator management
      if (userCredential.user != null) {
        RefugioManagementService().registerUserEmail(
          userCredential.user!.uid,
          userCredential.user!.email!,
        );
      }

      // Note: Role will be determined when user selects a refugio in RefugioScreen
      // This allows users to have different roles in different refugios

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SplashScreen(
            mensaje: 'Cargando página principal...',
            nextRoute: '/refugio',
            mainScreen: false,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
        log(
          'Error de autenticación Firebase: ${e.code}',
          error: e,
          name: 'AuthError',
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Ocurrió un error inesperado. Inténtelo de nuevo.";
        log('Error inesperado en _signIn: $e', error: e, name: 'GeneralError');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final TextEditingController emailController = TextEditingController();

    // Mostrar diálogo para ingresar email
    final String? email = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Recuperar Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, emailController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
              ),
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    // Si el usuario canceló, no hacer nada
    if (email == null || email.isEmpty) {
      return;
    }

    // Validar formato de email
    if (!email.contains('@')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor ingresa un correo electrónico válido'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Mostrar indicador de carga
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        Navigator.pop(context); // Cerrar indicador de carga

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se ha enviado un correo de recuperación a $email'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar indicador de carga

        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No existe una cuenta con este correo electrónico.';
            break;
          case 'invalid-email':
            errorMessage = 'El formato del correo electrónico no es válido.';
            break;
          default:
            errorMessage = 'Error al enviar el correo: ${e.code}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar indicador de carga

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocurrió un error inesperado. Inténtalo de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: <Widget>[_buildBackground(), _buildContent(context)],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/Backgound_image_1.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.9),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Image.asset(
                  'assets/img/Logo_AdminPatitas.png',
                  height: 100,
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                'Facilitamos la gestión para que\nmejores el cuidado animal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '¡REGÍSTRATE AHORA!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4FC3F7),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 120),
              _buildTextField(
                _emailController,
                'Correo',
                Icons.email,
                keyboardType: TextInputType.emailAddress,
                showCheckmark: true,
              ),
              const SizedBox(height: 20.0),
              _buildTextField(
                _passwordController,
                'Contraseña',
                Icons.lock,
                showVisibilityIcon: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _resetPassword,
                  child: const Text(
                    '¿Olvidó la contraseña?',
                    style: TextStyle(color: Color(0xFF4FC3F7)),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              _buildSignInButton(context),
              const SizedBox(height: 15.0),
              _buildRegisterButton(),
              const SizedBox(height: 20.0),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool showVisibilityIcon = false,
    bool showCheckmark = false,
  }) {
    final bool obscureText = showVisibilityIcon ? !_isPasswordVisible : false;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        floatingLabelStyle: const TextStyle(color: Color(0xFF4FC3F7)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18.0,
          horizontal: 10.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2.0),
        ),
        prefixIcon: Icon(icon, color: Colors.grey.shade700),
        suffixIcon: showCheckmark
            ? (controller.text.isNotEmpty
                  ? const Icon(Icons.check, color: Colors.green)
                  : null)
            : (showVisibilityIcon
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey.shade700,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : null),
      ),
      onChanged: (text) {
        if (showCheckmark) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _signIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4FC3F7),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Entrar',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildRegisterButton() {
    return OutlinedButton(
      onPressed: () {
        // Implementación de ejemplo para navegación
        Navigator.pushNamed(context, '/register');

        log('Navegar a Registro', name: 'Navigation');
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: const BorderSide(color: Colors.white, width: 1.5),
      ),
      child: const Text(
        'Registrar',
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
