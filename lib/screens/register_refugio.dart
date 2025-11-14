import 'dart:convert';

import 'package:admin_patitas/screens/widgets/botonlogin.dart';
import 'package:admin_patitas/screens/widgets/formulario.dart';
import 'package:admin_patitas/screens/widgets/logo_bar.dart';
import 'package:admin_patitas/screens/widgets/text_form_register.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterRefugio extends StatefulWidget {
  const RegisterRefugio({super.key});

  @override
  State<RegisterRefugio> createState() => _RegisterRefugioState();
}

class _RegisterRefugioState extends State<RegisterRefugio> {
  final _formkey = GlobalKey<FormState>();

  String nombre = "", direccion = "", idUsuario = "";
  List ayudantes = [];
  TextEditingController _nombre = new TextEditingController();
  TextEditingController _direccion = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      idUsuario = user.uid;
    } else {
      print("usuario no encontrado");
    }

    super.initState();
  }

  void registerRefugio() async {
    const url = 'http://localhost:5000/registro-refugio';
    final uri = Uri.parse(url);

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': _nombre.text,
          'direccion': _direccion.text,
          'id_usuario': idUsuario,
        }),
      );

      print('Código de estado: ${response.statusCode}');
      print('Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('refugio registrado exitosamente')),
        );
        Navigator.pop(context);
        //Navigator.pushNamed(context, '/principal');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      print('Excepción de Flutter/Dart: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Excepción: $e')));
    }
  }

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
                    texto: 'REGISTRA TU REFUGIO',
                    color: colorPrincipal,
                    size: 40,
                    aling: TextAlign.center,
                    negrita: FontWeight.bold,
                  ),
                ),

                Formulario(
                  controller: _nombre,
                  text: 'Nombre',
                  textOcul: false,
                  colorBorder: Colors.black,
                  colorBorderFocus: colorPrincipal,
                  colorTextForm: Colors.grey,
                  colorText: Colors.black,
                  sizeM: 30,
                  sizeP: 10,
                ),

                Formulario(
                  controller: _direccion,
                  text: 'Direccion',
                  textOcul: false,
                  colorBorder: Colors.white,
                  colorBorderFocus: colorPrincipal,
                  colorText: Colors.black,
                  colorTextForm: Colors.grey,
                  sizeM: 30,
                  sizeP: 10,
                ),

                BotonLogin(
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      setState(() {
                        nombre = _nombre.text;
                        direccion = _direccion.text;
                      });
                      registerRefugio();
                    }
                    //registroUsuario();
                  },
                  texto: 'Crear Refugio',
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
