import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:flutter/material.dart';

class RefugioRegisterWeb extends StatefulWidget {
  final VoidCallback registerRefugio;
  final TextEditingController nombreController;
  final TextEditingController direccionController;
  final GlobalKey<FormState> formkey;
  const RefugioRegisterWeb({
    super.key,
    required this.registerRefugio,
    required this.nombreController,
    required this.direccionController,
    required this.formkey,
  });

  @override
  State<RefugioRegisterWeb> createState() => _RefugioRegisterWebState();
}

class _RefugioRegisterWebState extends State<RefugioRegisterWeb> {
  @override
  Widget build(BuildContext context) {
    Color colorPrincipal = AppColors.primary;
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: Form(
        key: widget.formkey,
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
                controller: widget.nombreController,
                text: 'Nombre',
                textOcul: false,
                colorBorder: Colors.black,
                colorBorderFocus: colorPrincipal,
                colorTextForm: Colors.grey,
                colorText: Colors.black,
                sizeM: 30,
                sizeP: 10,
                floatingLabel: true,
              ),

              Formulario(
                controller: widget.direccionController,
                text: 'Direccion',
                textOcul: false,
                colorBorder: Colors.white,
                colorBorderFocus: colorPrincipal,
                colorText: Colors.black,
                colorTextForm: Colors.grey,
                sizeM: 30,
                sizeP: 10,
                floatingLabel: true,
              ),

              BotonLogin(
                onPressed: widget.registerRefugio,
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
    );
  }
}
