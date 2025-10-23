import 'package:flutter/material.dart';

class Formulario extends StatelessWidget {
  // This widget is the root of your application.
  final TextEditingController controller;
  final String text;
  final bool textOcul;
  final Color colorBorder, colorBorderFocus, colorTextForm, colorText;
  final double sizeM, sizeP;

  const Formulario({
    Key? key,
    required this.controller,
    required this.text,
    required this.textOcul,
    required this.colorBorder,
    required this.colorBorderFocus,
    required this.colorTextForm,
    required this.colorText,
    required this.sizeM,
    required this.sizeP,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: sizeM),

      child: TextFormField(
        cursorColor: colorText,
        style: TextStyle(color: colorText),
        obscureText: textOcul,
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Porfavor ingrese el dato solicitado';
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(sizeP),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: colorBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: colorBorderFocus),
          ),
          labelText: text,
          floatingLabelStyle: TextStyle(
            color: colorBorderFocus,
            fontWeight: FontWeight.bold,
          ),
          labelStyle: TextStyle(color: colorTextForm),
        ),
      ),
    );
  }
}
