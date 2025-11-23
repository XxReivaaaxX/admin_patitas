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
  final _formkey = GlobalKey<FormState>();
  late final UserController userController;

  String email = "", password = "";
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _validePassword = TextEditingController();

  bool isChecked = false;
  bool pdfOpened = false;

  @override
  void initState() {
    userController = UserController();
    super.initState();
  }

  void _verTerminos() {
    if (kIsWeb) {
      html.window.open('assets/terminosycondiciones.pdf', '_blank');
      setState(() {
        pdfOpened = true;
      });
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
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        pdfOpened = true;
                      });
                    },
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _register() async {
    if (_formkey.currentState!.validate()) {
      if (_password.text != _validePassword.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }

      if (!isChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes aceptar nuestros términos y condiciones'),
          ),
        );
        return;
      }

      setState(() {
        email = _email.text.trim();
        password = _password.text.trim();
      });

      // Validación para correo
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('El correo no es válido')));
        return;
      }

      // Validación para contraseña mínima
      if (password.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La contraseña debe tener al menos 6 caracteres'),
          ),
        );
        return;
      }

      bool success = await userController.registerUser(email, password);

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
  }

  @override
  Widget build(BuildContext context) {
    Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: LogoBar(
          sizeImg: 32,
          colorIzq: colorPrincipal,
          colorDer: Colors.black,
          sizeText: 20,
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Form(
          key: _formkey,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 40),
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 50),
                  child: TextForm(
                    lines: 2,
                    texto: '¡REGÍSTRATE AHORA!',
                    color: colorPrincipal,
                    size: 40,
                    aling: TextAlign.center,
                    negrita: FontWeight.bold,
                  ),
                ),
                Formulario(
                  controller: _email,
                  text: 'Correo',
                  textOcul: false,
                  colorBorder: Colors.black,
                  colorBorderFocus: colorPrincipal,
                  colorTextForm: Colors.grey,
                  colorText: Colors.black,
                  sizeM: 30,
                  sizeP: 10,
                ),
                Formulario(
                  controller: _password,
                  text: 'Contraseña',
                  textOcul: true,
                  colorBorder: Colors.black,
                  colorBorderFocus: colorPrincipal,
                  colorText: Colors.black,
                  colorTextForm: Colors.grey,
                  sizeM: 30,
                  sizeP: 10,
                ),
                Formulario(
                  controller: _validePassword,
                  text: 'Validar Contraseña',
                  textOcul: true,
                  colorBorder: Colors.black,
                  colorBorderFocus: colorPrincipal,
                  colorText: Colors.black,
                  colorTextForm: Colors.grey,
                  sizeM: 30,
                  sizeP: 10,
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
                          : null,
                    ),
                    const Text('Acepto términos y condiciones'),
                    TextButton(onPressed: () {}, child: const Text('Ver')),
                  ],
                ),
                BotonLogin(
                  onPressed: (pdfOpened && isChecked) ? _register : null,
                  texto: 'Registrar',
                  color: Colors.white,
                  colorB: (pdfOpened && isChecked)
                      ? colorPrincipal
                      : Colors.grey,
                  size: 15,
                  negrita: FontWeight.normal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
