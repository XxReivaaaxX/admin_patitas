import 'package:flutter/material.dart';

class Formulario extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final bool textOcul;
  final Color colorBorder, colorBorderFocus, colorTextForm, colorText;
  final double sizeM, sizeP;

  const Formulario({
    super.key,
    required this.controller,
    required this.text,
    required this.textOcul,
    required this.colorBorder,
    required this.colorBorderFocus,
    required this.colorTextForm,
    required this.colorText,
    required this.sizeM,
    required this.sizeP,
  });

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
            return 'Por favor ingrese el dato solicitado';
          }

          if (text.toLowerCase() == 'correo') {
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) {
              return 'Ingrese un correo válido';
            }
          }

          if (text.toLowerCase().contains('contraseña')) {
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
          }

          return null;
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(sizeP),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: colorBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
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
