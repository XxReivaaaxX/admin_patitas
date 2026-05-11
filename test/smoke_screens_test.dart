import 'package:admin_patitas/screens/login/login_mobile.dart';
import 'package:admin_patitas/screens/userRegister/register_user_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Login mobile smoke: renders primary actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/register': (_) => const Scaffold(),
          '/adoptions': (_) => const Scaffold(),
        },
        home: LoginMobile(
          emailController: TextEditingController(),
          passwordController: TextEditingController(),
          isLoading: false,
          errorMessage: null,
          onSignIn: () {},
          onResetPassword: () {},
        ),
      ),
    );

    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('Registrar'), findsOneWidget);
    expect(find.text('Ver Mascotas en Adopción'), findsOneWidget);
  });

  testWidgets('Register mobile smoke: renders mandatory fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegisterUserMobile(
          formkey: GlobalKey<FormState>(),
          email: TextEditingController(),
          password: TextEditingController(),
          validePassword: TextEditingController(),
          isLoading: false,
          pdfOpen: true,
          register: () {},
          verTerminos: () {},
        ),
      ),
    );

    expect(find.text('Crear Cuenta'), findsOneWidget);
    expect(find.text('Correo'), findsWidgets);
    expect(find.text('Contraseña'), findsWidgets);
    expect(find.text('Validar Contraseña'), findsWidgets);
    expect(find.text('Registrar'), findsOneWidget);
  });
}
