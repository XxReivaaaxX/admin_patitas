import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/background_image.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/cut_custom.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:flutter/material.dart';

class RegisterUserMobile extends StatefulWidget {
  final GlobalKey<FormState> formkey;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController validePassword;
  final VoidCallback register;
  final VoidCallback verTerminos;
  final bool isLoading, pdfOpen;
  const RegisterUserMobile({
    super.key,
    required this.formkey,
    required this.email,
    required this.password,
    required this.validePassword,
    required this.isLoading,
    required this.pdfOpen,
    required this.register,
    required this.verTerminos,
  });

  @override
  State<RegisterUserMobile> createState() => _RegisterUserMobileState();
}

class _RegisterUserMobileState extends State<RegisterUserMobile> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    Color colorPrincipal = AppColors.primary;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            //acomodar imagen y recorte de ondas
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.4,
                  child: const BackgroundImage(),
                ),
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.1,
                  child: OverflowBox(
                    minHeight: size.height,
                    maxHeight: size.height,
                    alignment: Alignment.topCenter,
                    child: ClipPath(
                      clipper: CutCustom(),
                      child: Container(
                        width: double.infinity,
                        height: size.height,
                        color: AppColors.backgroundLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // contenedor de formulario
            Container(
              color: AppColors.backgroundLight,
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                bottom: 30,
              ),
              child: Form(
                key: widget.formkey,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Crear Cuenta',
                        style: TextStyle(
                          color: colorPrincipal,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Formulario(
                      controller: widget.email,
                      text: 'Correo',
                      textOcul: false,
                      colorBorder: Colors.black,
                      colorBorderFocus: colorPrincipal,
                      colorTextForm: Colors.grey,
                      colorText: Colors.black,
                      sizeM: 20,
                      sizeP: 10,
                      floatingLabel: false,
                    ),
                    const SizedBox(height: 10),
                    Formulario(
                      controller: widget.password,
                      text: 'Contraseña',
                      textOcul: true,
                      colorBorder: Colors.black,
                      colorBorderFocus: colorPrincipal,
                      colorTextForm: Colors.grey,
                      colorText: Colors.black,
                      sizeM: 20,
                      sizeP: 10,
                      floatingLabel: false,
                    ),
                    const SizedBox(height: 10),
                    Formulario(
                      controller: widget.validePassword,
                      text: 'Validar Contraseña',
                      textOcul: true,
                      colorBorder: Colors.black,
                      colorBorderFocus: colorPrincipal,
                      colorTextForm: Colors.grey,
                      colorText: Colors.black,
                      sizeM: 20,
                      sizeP: 10,
                      passwordToCompare: widget.password.text,
                      floatingLabel: false,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          activeColor: colorPrincipal,
                          side: const BorderSide(color: Colors.blue),
                          value: isChecked,
                          onChanged: widget.pdfOpen
                              ? (bool? value) {
                                  setState(() {
                                    isChecked = value!;
                                  });
                                }
                              : null, // Deshabilitado si no se abrió el PDF
                        ),
                        const Text('Acepto términos y condiciones'),
                        TextButton(
                          onPressed: widget.verTerminos,
                          child: const Text('Ver'),
                        ),
                      ],
                    ),
                    BotonLogin(
                      onPressed: (widget.pdfOpen && isChecked)
                          ? widget.register
                          : null,
                      texto: 'Registrar',
                      color: Colors.white,
                      colorB: (widget.pdfOpen && isChecked)
                          ? colorPrincipal
                          : Colors.grey,
                      size: 16,
                      negrita: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
