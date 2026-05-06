import 'package:admin_patitas/screens/userRegister/register_user_mobile.dart';
import 'package:admin_patitas/screens/userRegister/register_user_web.dart';
import 'package:admin_patitas/services/user_service.dart';
import 'package:admin_patitas/screens/pantalla_carga.dart';
import 'package:admin_patitas/widgets/background_image.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart'; // NUEVO

class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final _formKey = GlobalKey<FormState>();
  late final UserController userController;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _validePassword = TextEditingController();

  bool isChecked = false;
  bool pdfOpened = false;
  bool isLoading = false;

  @override
  void initState() {
    userController = UserController();
    super.initState();
  }

  Future<void> _verTerminos() async {
    const pdfPath = 'assets/terminosycondiciones.pdf';

    if (kIsWeb) {
      // Para Web: abrir en nueva pestaña
      final Uri pdfUri = Uri.parse(pdfPath);
      if (!await launchUrl(pdfUri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el PDF')),
        );
      }
    } else {
      // Para móvil: mostrar visor PDF
      showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: SizedBox(
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
                Expanded(child: SfPdfViewer.asset(pdfPath)),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    setState(() {
      pdfOpened = true; // habilita el checkbox
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar nuestros términos y condiciones'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final email = _email.text.trim();
    final password = _password.text.trim();

    bool success = await userController.registerUser(email, password);

    setState(() => isLoading = false);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: !kIsWeb,
        backgroundColor: Colors.transparent,
        title: Text(
          'PETFLOW',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return isLoading
                ? const Center(child: CircularProgressIndicator())
                : RegisterUserMobile(
                    formkey: _formKey,
                    email: _email,
                    password: _password,
                    validePassword: _validePassword,
                    isLoading: isLoading,
                    pdfOpen: pdfOpened,
                    register: () => _register(),
                    verTerminos: () => _verTerminos(),
                  );
          } else {
            return isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      BackgroundImage(),
                      RegisterUserWeb(
                        formkey: _formKey,
                        email: _email,
                        password: _password,
                        validePassword: _validePassword,
                        isLoading: isLoading,
                        pdfOpen: pdfOpened,
                        register: () => _register(),
                        verTerminos: () => _verTerminos(),
                        isChecked: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                      ),
                    ],
                  );
          }
        },
      ),
    );
  }
}
