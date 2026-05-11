import 'package:admin_patitas/screens/externalAdoptionScreen/public_adoptions_screen.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/screens/refugioScreen/refugio_screen.dart';
import 'package:admin_patitas/screens/sin_refugio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:admin_patitas/screens/menuPrincipal/principal_screen.dart';
import 'package:admin_patitas/screens/userRegister/register_screen.dart';
import 'package:admin_patitas/screens/animalsScreen/panel_animales.dart';
import 'package:admin_patitas/screens/login/login.dart';
import 'package:admin_patitas/screens/pantalla_carga.dart';
import 'package:admin_patitas/screens/refugio_settings.dart';
import 'package:admin_patitas/screens/manage_collaborators.dart';
import 'package:admin_patitas/screens/register_existing_users.dart';
import 'package:admin_patitas/screens/web_landing_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final Map<String, WidgetBuilder> appRoutes = {
  '/landing_web': (context) => const WebLandingScreen(),
  '/login': (context) => const LoginScreen(),
  '/animales': (context) => const AnimalScreen(),
  '/principal': (context) => const PrincipalScreen(),
  '/register': (context) => const RegisterUser(),
  '/refugio': (context) => const RefugioScreen(),
  '/sinRefugio': (context) => const SinRefugio(),
  '/refugio_settings': (context) => const RefugioSettings(),
  '/manage_collaborators': (context) => const ManageCollaborators(),
  '/register_existing_users': (context) => const RegisterExistingUsersScreen(),
  '/adoptions': (context) => const PublicAdoptionsScreen(),
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesController.iniciarPref();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await NotificationServiceCloud.initialize();

  runApp(const PetFlowApp());
}

class PetFlowApp extends StatelessWidget {
  const PetFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Refugio de Animales - PetFlow',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.principalBackgroud,
        ),
        useMaterial3: true,
      ),

      // Delegados para localización
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Idiomas soportados
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés
      ],

      home: kIsWeb
          ? const WebLandingScreen()
          : SplashScreen(
              mensaje: "Cargando Aplicación",
              nextRoute: '/login',
              mainScreen: false,
            ),
      routes: appRoutes,
    );
  }
}
