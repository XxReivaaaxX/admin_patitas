import 'dart:convert';
import 'package:admin_patitas/services/user_service.dart';
import 'package:admin_patitas/screens/pantalla_carga.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:admin_patitas/widgets/logo_bar.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // Solo para Web


class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final _formKey = GlobalKey<FormState>();
  late final UserController userController;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _validePassword = TextEditingController();

  bool isChecked = false;
  bool pdfOpened = false;
  bool isLoading = false;

  @override
  void initState() {
    userController = UserController();
    super.initState();
  }

  void _verTerminos() {
    if (kIsWeb) {
      html.window.open('assets/terminosycondiciones.pdf', '_blank');
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Términos y Condiciones',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: SfPdfViewer.asset('assets/terminosycondiciones.pdf'),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    setState(() {
      pdfOpened = true; // Se habilita el checkbox después de abrir el PDF
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar nuestros términos y condiciones')),
      );
      return;
    }

    setState(() => isLoading = true);

    final email = _email.text.trim();
    final password = _password.text.trim();

    bool success = await userController.registerUser(email, password);

    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SplashScreen(
            mensaje: 'Cargando página para iniciar sesión...',
            nextRoute: '/login',
            mainScreen: false,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar usuario')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Registro',
          style: TextStyle(color: colorPrincipal, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        '¡REGÍSTRATE AHORA!',
                        style: TextStyle(
                          color: colorPrincipal,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Formulario(
                        controller: _email,
                        text: 'Correo',
                        textOcul: false,
                        colorBorder: Colors.black,
                        colorBorderFocus: colorPrincipal,
                        colorTextForm: Colors.grey,
                        colorText: Colors.black,
                        sizeM: 20,
                        sizeP: 10,
                      ),
                      Formulario(
                        controller: _password,
                        text: 'Contraseña',
                        textOcul: true,
                        colorBorder: Colors.black,
                        colorBorderFocus: colorPrincipal,
                        colorTextForm: Colors.grey,
                        colorText: Colors.black,
                        sizeM: 20,
                        sizeP: 10,
                      ),
                      Formulario(
                        controller: _validePassword,
                        text: 'Validar Contraseña',
                        textOcul: true,
                        colorBorder: Colors.black,
                        colorBorderFocus: colorPrincipal,
                        colorTextForm: Colors.grey,
                        colorText: Colors.black,
                        sizeM: 20,
                        sizeP: 10,
                        passwordToCompare: _password.text,
                      ),
                      Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            activeColor: colorPrincipal,
                            side: const BorderSide(color: Colors.blue),
                            value: isChecked,
                            onChanged: pdfOpened
                                ? (bool? value) {
                                    setState(() {
                                      isChecked = value!;
                                    });
                                  }
                                : null, // Deshabilitado si no se abrió el PDF
                          ),
                          const Text('Acepto términos y condiciones'),
                          TextButton(onPressed: _verTerminos, child: const Text('Ver')),
                        ],
                      ),
                      BotonLogin(
                        onPressed: (pdfOpened && isChecked) ? _register : null,
                        texto: 'Registrar',
                        color: Colors.white,
                        colorB: (pdfOpened && isChecked) ? colorPrincipal : Colors.grey,
                        size: 16,
                        negrita: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
