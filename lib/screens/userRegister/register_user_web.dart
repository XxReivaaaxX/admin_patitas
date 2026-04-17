import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:admin_patitas/widgets/formulario.dart';
import 'package:admin_patitas/widgets/glass_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RegisterUserWeb extends StatefulWidget {
  final GlobalKey<FormState> formkey;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController validePassword;
  final VoidCallback register;
  final VoidCallback verTerminos;
  final bool isLoading, pdfOpen, isChecked;
  final ValueChanged<bool?> onChanged;
  const RegisterUserWeb({
    super.key,
    required this.formkey,
    required this.email,
    required this.password,
    required this.validePassword,
    required this.isLoading,
    required this.pdfOpen,
    required this.register,
    required this.verTerminos,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  State<RegisterUserWeb> createState() => _RegisterUserWebState();
}

class _RegisterUserWebState extends State<RegisterUserWeb> {
  @override
  Widget build(BuildContext context) {
    Color colorPrincipal = AppColors.primary;
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: GlassCard(
            child: Form(
              key: widget.formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  if (!kIsWeb)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: colorPrincipal,
                      onPressed: () => Navigator.pop(context),
                    ),
                  Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      color: colorPrincipal,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
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
                        value: widget.isChecked,
                        onChanged: widget.pdfOpen
                            ? widget.onChanged
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
                    onPressed: (widget.pdfOpen && widget.isChecked)
                        ? widget.register
                        : null,
                    texto: 'Registrar',
                    color: Colors.white,
                    colorB: (widget.pdfOpen && widget.isChecked)
                        ? colorPrincipal
                        : Colors.grey,
                    size: 16,
                    negrita: FontWeight.bold,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
