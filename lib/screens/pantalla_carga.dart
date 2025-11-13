import 'dart:async';

import 'package:admin_patitas/controllers/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final String mensaje;
  final String nextRoute;
  final bool mainScreen;

  const SplashScreen({
    Key? key,
    required this.mensaje,
    required this.nextRoute,
    required this.mainScreen,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription<User?>? _authSubscription;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () async {
      Navigator.pushNamedAndRemoveUntil(
        context,
        widget.nextRoute,
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/img/Logo_AdminPatitas.png', width: 150),
            SizedBox(height: 60),
            Text(
              widget.mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  /*
  sesionActiva() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      if (!mounted) return;
      if (user == null) {
        //print('User is currently signed out!');
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/sinRefugio',
          (route) => false,
        );
      }
    });
  }*/
}
