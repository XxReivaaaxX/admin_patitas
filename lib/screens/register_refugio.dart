import 'dart:developer';
import 'package:admin_patitas/services/refugio_management_service.dart';

import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:admin_patitas/widgets/logo_bar.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';


class RegisterRefugio extends StatefulWidget {
  const RegisterRefugio({super.key});

  @override
  State<RegisterRefugio> createState() => _RegisterRefugioState();
}

class _RegisterRefugioState extends State<RegisterRefugio> {
  final _formkey = GlobalKey<FormState>();

  String nombre = "", direccion = "", idUsuario = "";
  List ayudantes = [];
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _direccion = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _whatsapp = TextEditingController();
  final TextEditingController _emailContacto = TextEditingController();

  @override
  void initState() {

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      idUsuario = user.uid;
    } else {
      log("usuario no encontrado", name: 'RegisterRefugio');
    }

    super.initState();
  }

  void registerRefugio() async {
    setState(() => idUsuario = FirebaseAuth.instance.currentUser?.uid ?? "");
    
    if (idUsuario.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no autenticado')),
      );
      return;
    }

    try {
      final refugioManagementService = RefugioManagementService();
      await refugioManagementService.createRefugio(
        _nombre.text.trim(),
        _direccion.text.trim(),
        idUsuario,
        telefono: _telefono.text.trim(),
        whatsapp: _whatsapp.text.trim(),
        emailContacto: _emailContacto.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refugio registrado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      log('Excepción de Flutter/Dart: $e', error: e, name: 'RegisterRefugio');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar refugio: $e')),
        );
      }
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
                  text: 'Dirección',
                  textOcul: false,
                  colorBorder: Colors.white,
                  colorBorderFocus: colorPrincipal,
                  colorText: Colors.black,
                  colorTextForm: Colors.grey,
                  sizeM: 30,
                  sizeP: 10,
                ),
                Formulario(
                  controller: _telefono,
                  text: 'Teléfono de Contacto',
                  textOcul: false,
                  colorBorder: Colors.black,
                  colorBorderFocus: colorPrincipal,
                  colorTextForm: Colors.grey,
                  colorText: Colors.black,
                  sizeM: 30,
                  sizeP: 10,
                ),
                Formulario(
                  controller: _whatsapp,
                  text: 'WhatsApp (opcional)',
                  textOcul: false,
                  colorBorder: Colors.black,
                  colorBorderFocus: colorPrincipal,
                  colorTextForm: Colors.grey,
                  colorText: Colors.black,
                  sizeM: 30,
                  sizeP: 10,
                ),
                Formulario(
                  controller: _emailContacto,
                  text: 'Correo de Contacto',
                  textOcul: false,
                  colorBorder: Colors.black,
                  colorBorderFocus: colorPrincipal,
                  colorTextForm: Colors.grey,
                  colorText: Colors.black,
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
