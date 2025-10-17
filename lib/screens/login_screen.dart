import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer'; // Usamos dart:developer para un logging más robusto

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
  
  // Nuevo estado para controlar la visibilidad de la contraseña
  bool _isPasswordVisible = false; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Mapeo de códigos de error de Firebase a mensajes en español.
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
        return 'La contraseña es demasiado débil (debe tener al menos 6 carácteres).';
      default:
        return 'Ocurrió un error de autenticación: $code';
    }
  }

  // Lógica de inicio de sesión
  Future<void> _signIn() async {
    // Validación básica antes de intentar la llamada a Firebase
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Usamos log en lugar de print para una mejor trazabilidad
      log("¡Inicio de sesión exitoso!", name: 'Auth');

    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
        // Registramos el error de Firebase en la consola
        log('Error de autenticación Firebase: ${e.code}', error: e, name: 'AuthError');
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Ocurrió un error inesperado. Inténtelo de nuevo.";
        // Registramos cualquier otro error inesperado
        log('Error inesperado en _signIn: $e', error: e, name: 'GeneralError');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Evita el error de overflow al abrir el teclado en modo apaisado
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: <Widget>[
          _buildBackground(),

          _buildContent(context),

        ],
      ),
    );
  }

  // Widget para el fondo con imagen y gradiente
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          // Asumiendo que esta imagen existe en tus assets
          image: AssetImage('assets/img/Backgound_image_1.png'),
          fit: BoxFit.cover,
        )
      ),
      child: Container(
        decoration: BoxDecoration(
          // Gradiente oscuro para mejorar el contraste del texto
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.5), // Alfa ajustado para claridad
              Colors.black.withOpacity(0.9), // Más oscuro abajo
            ],
            stops: const [0.0, 1.0],
          )
        ),
      ),
    );
  }

  // Contenido principal de la pantalla (logo, campos, botones)
  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

              Center(
                // Asumiendo que esta imagen existe en tus assets
                child: Image.asset('assets/img/Logo_AdminPatitas.png', height: 100)
              ),

              const SizedBox(height: 50),

              const Text(
                'Facilitamos la gestión para que\nmejores el cuidado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                '¡REGISTRATE AHORA!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4FC3F7), // Usando el color del botón para consistencia
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 120),

              // Campo de Correo
              _buildTextField(
                _emailController, 
                'Correo', 
                Icons.email, 
                keyboardType: TextInputType.emailAddress, 
                showCheckmark: true
              ),
              
              const SizedBox(height: 20.0),
              
              // Campo de Contraseña
              _buildTextField(
                _passwordController, 
                'Contraseña', 
                Icons.lock, 
                showVisibilityIcon: true
              ),

              const SizedBox(height: 8.0),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    log('Navegar a Olvidó Contraseña', name: 'Navigation');
                  },
                  child: const Text(
                    '¿Olvido la contraseña?',
                    style: TextStyle(color: Color(0xFF4FC3F7)), // Usando el color azul claro
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              _buildSignInButton(context),
              const SizedBox(height: 15.0),
              _buildRegisterButton(),

              const SizedBox(height: 20.0),

              // Mensaje de error (si existe)
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold),
                ),

            ],
          ),

        ),
      ),
    );
  }

  // Widget para construir los campos de texto
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool showVisibilityIcon = false,
    bool showCheckmark = false,
  }) {
    // Si showVisibilityIcon es true, la propiedad obscureText depende del estado _isPasswordVisible
    final bool obscureText = showVisibilityIcon ? !_isPasswordVisible : false;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText, // Aplicación dinámica
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        floatingLabelStyle: const TextStyle(color: Color(0xFF4FC3F7)), // Color al enfocar
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10.0),
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
          borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2.0), // Borde cuando está enfocado
        ),
        prefixIcon: Icon(icon, color: Colors.grey.shade700),
        
        // Icono de sufijo
        suffixIcon: showCheckmark 
          ? (controller.text.isNotEmpty ? const Icon(Icons.check, color: Colors.green) : null)
          : (showVisibilityIcon 
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off, 
                    color: Colors.grey.shade700
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null
            ),
      ),
      onChanged: (text) {
        if (showCheckmark) {
          setState(() {}); // Forzar el rebuild para reevaluar el suffixIcon del email
        }
      },
    );
  }
  
  // Widget auxiliar para el botón de Iniciar Sesión (Entrar)
  Widget _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _signIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4FC3F7), // Un azul claro y atractivo
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
        ),
        elevation: 5, // Sombra sutil para el botón principal
      ),
      child: _isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
        : const Text(
            'Entrar',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
    );
  }

  // Widget auxiliar para el botón de Registro
  Widget _buildRegisterButton() {
    return OutlinedButton(
      onPressed: () {
        // Implementación de ejemplo para navegación
        log('Navegar a Registro', name: 'Navigation');
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
        ),
        side: const BorderSide(color: Colors.white, width: 1.5), // Borde blanco
      ),
      child: const Text(
        'Registrar',
        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

}
