import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print("¡Inicio de sesión exitoso!");

    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Ocurrió un error inesperado. Inténtelo de nuevo.";
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
      body: Stack(
        children: <Widget>[
          _buildBackground(),

          _buildContent(context),

        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/Backgound_image_1.png'),
          fit: BoxFit.cover,
        )
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withAlpha(128),
              Colors.black.withAlpha(230)
            ],
            stops: const [0.0, 1.0],
          )
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

              Center(child: Image.asset('assets/img/Logo_AdminPatitas.png', height: 100)),

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
                  color: Color(0xFF1E88E5),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 120),

              _buildTextField(_emailController, 'Correo', Icons.email, keyboardType: TextInputType.emailAddress, showCheckmark: true),
              const SizedBox(height: 20.0),
              _buildTextField(_passwordController, 'Contraseña', Icons.lock, obscureText: true, showVisibilityIcon: true),

              const SizedBox(height: 8.0),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    '¿Olvido la contraseña?',
                    style: TextStyle(color: Color(0xFF1E88E5)),
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
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold),
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
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool showVisibilityIcon = false,
    bool showCheckmark = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        floatingLabelStyle: const TextStyle(color: Colors.white),
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
        prefixIcon: Icon(icon, color: Colors.grey.shade700),
        suffixIcon: showCheckmark 
          ? const Icon(Icons.check, color: Colors.green) 
          : (showVisibilityIcon 
              ? IconButton(
                  icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey.shade700),
                  onPressed: () {
                    // TODO: Implementar el toggle de visibilidad de contraseña
                  },
                )
              : null
            ),
      ),
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
        elevation: 0,
      ),
      child: _isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
        : const Text(
            'Entrar',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
    );
  }

  // Widget auxiliar para el botón de Registro
  Widget _buildRegisterButton() {
    return OutlinedButton(
      onPressed: () {
        // TODO: Navegar a la pantalla de registro
        print('Navegar a Registro');
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
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

}