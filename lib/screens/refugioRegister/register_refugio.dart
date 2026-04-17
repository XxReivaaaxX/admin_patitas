import 'package:admin_patitas/screens/refugioRegister/refugio_register_mobile.dart';
import 'package:admin_patitas/screens/refugioRegister/refugio_register_web.dart';

import 'package:admin_patitas/widgets/logo_bar.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;

class RegisterRefugio extends StatefulWidget {
  const RegisterRefugio({super.key});

  @override
  State<RegisterRefugio> createState() => _RegisterRefugioState();
}

class _RegisterRefugioState extends State<RegisterRefugio> {
  final _formkey = GlobalKey<FormState>();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  String nombre = "", direccion = "", idUsuario = "";
  List ayudantes = [];
  final TextEditingController _nombre = new TextEditingController();
  final TextEditingController _direccion = new TextEditingController();

  @override
  void initState() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      idUsuario = user.uid;
    } else {
      print("usuario no encontrado");
    }
    super.initState();
  }

  void registerRefugio() async {
    try {
      final nuevoRefugioRef = _dbRef.child('refugios').push();

      await nuevoRefugioRef.set({
        'id_usuario': idUsuario,
        'nombre': _nombre.text,
        'direccion': _direccion.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refugio registrado exitosamente')),
        );
        //Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/refugio',
          (route) => false,
        );
      }
    } catch (e) {
      print('Error al guardar en Firebase: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1180) {
          return RefugioRegisterMobile(
            registerRefugio: () {
              if (_formkey.currentState!.validate()) {
                setState(() {
                  nombre = _nombre.text;
                  direccion = _direccion.text;
                });
                registerRefugio();
              }
              //registroUsuario();
            },
            nombreController: _nombre,
            direccionController: _direccion,
            formkey: _formkey,
          );
        } else {
          return Center(
            child: SizedBox(
              width: 600,
              height: 550,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                child: RefugioRegisterWeb(
                  formkey: _formkey,
                  nombreController: _nombre,
                  direccionController: _direccion,
                  registerRefugio: () {
                    if (_formkey.currentState!.validate()) {
                      setState(() {
                        nombre = _nombre.text;
                        direccion = _direccion.text;
                      });
                      registerRefugio();
                    }
                    //registroUsuario();
                  },
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
