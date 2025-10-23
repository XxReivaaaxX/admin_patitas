import 'dart:convert';

import 'package:admin_patitas/screens/widgets/botonlogin.dart';
import 'package:admin_patitas/screens/widgets/formulario.dart';
import 'package:admin_patitas/screens/widgets/logo_bar.dart';
import 'package:admin_patitas/screens/widgets/text_form_register.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final _formkey = GlobalKey<FormState>();

  String email = "", password = "", validatePassword = "";
  TextEditingController _email = new TextEditingController();
  TextEditingController _password = new TextEditingController();
  TextEditingController _validePassword = new TextEditingController();
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    Color colorPrincipal = Color.fromRGBO(55, 148, 194, 1);
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
            margin: EdgeInsets.only(bottom: 40, left: 70, right: 70, top: 40),
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 50),
                  child: TextForm(
                    lines: 2,
                    texto: '¡REGISTRATE AHORA!',
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
                  textOcul: false,
                  colorBorder: Colors.white,
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
                  colorBorder: Colors.white,
                  colorBorderFocus: colorPrincipal,
                  colorText: Colors.black,
                  colorTextForm: Colors.grey,
                  sizeM: 30,
                  sizeP: 10,
                ),
                Checkbox(
                  checkColor: Colors.blue,
                  activeColor: Colors.white,
                  fillColor: null,
                  side: BorderSide(color: Colors.blue),
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                ),
                BotonLogin(
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      setState(() {
                        email = _email.text;
                        password = _password.text;
                      });
                      userRegister(email, password);
                      Navigator.pushNamed(context, '/principal');
                    }
                    //registroUsuario();
                  },
                  texto: 'Registrar',
                  color: Colors.white,
                  colorB: colorPrincipal,
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

//prueba funcion enviar datos a la base de datos
void userFetched() async {
  const url = 'http://localhost:5000/submit';
  final uri = Uri.parse(url);

  try {
    await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': 'Firulais', 'email': 'firulais@email.com'}),
    );
    print("Datos subidos correctamente");
  } catch (e) {
    print('Excepción de Flutter/Dart: $e');
  }
}

// prueba crear usuario
void userRegister(String email, password) async {
  const url = 'http://localhost:5000/register';
  final uri = Uri.parse(url);

  try {
    await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'password': password, 'email': email}),
    );
    print("Usuario enviado correctamente");
  } catch (e) {
    print('Excepción de Flutter/Dart: $e');
  }
}
