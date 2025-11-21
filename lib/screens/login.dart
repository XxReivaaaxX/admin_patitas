import 'package:admin_patitas/services/user_service.dart';
import 'package:flutter/material.dart';
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

  final UserController userController = UserController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validaciones antes de llamar al servicio
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Por favor, ingrese su correo y contraseña.');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _errorMessage = 'El correo no es válido.');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String result = await userController.iniciarSesion(email, password);

    setState(() {
      _isLoading = false;
      if (result == "success") {
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
      } else if (result == "user_not_found") {
        _errorMessage = 'Usuario no encontrado. ¡Regístrate ahora!';
      } else if (result == "invalid_credentials") {
        _errorMessage = 'Correo o contraseña incorrectos.';
      } else {
        _errorMessage = 'Ocurrió un error. Inténtelo de nuevo.';
      }
    });
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
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/dashboardAnimals');
                  },
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
                Column(
                  children: [
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_errorMessage!.contains('Regístrate'))
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          'Ir a Registro',
                          style: TextStyle(
                            color: Color(0xFF4FC3F7),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
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
        Navigator.pushNamed(context, '/register');
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
