import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_patitas/services/refugio_management_service.dart';

class RegisterExistingUsersScreen extends StatefulWidget {
  const RegisterExistingUsersScreen({super.key});

  @override
  State<RegisterExistingUsersScreen> createState() =>
      _RegisterExistingUsersScreenState();
}

class _RegisterExistingUsersScreenState
    extends State<RegisterExistingUsersScreen> {
  bool _isRegistering = false;
  String _status = '';

  Future<void> _registerCurrentUser() async {
    setState(() {
      _isRegistering = true;
      _status = 'Registrando usuario actual...';
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        setState(() {
          _status = 'Error: No hay usuario autenticado';
          _isRegistering = false;
        });
        return;
      }

      await RefugioManagementService().registerUserEmail(user.uid, user.email!);

      setState(() {
        _status = 'Usuario registrado exitosamente:\n${user.email}';
        _isRegistering = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario registrado en el índice'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isRegistering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Usuarios Existentes'),
        backgroundColor: const Color(0xFF4FC3F7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_add, size: 80, color: Color(0xFF4FC3F7)),
            const SizedBox(height: 24),
            const Text(
              'Utilidad de Registro',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Esta utilidad registra al usuario actual en el índice de emails para que pueda ser agregado como colaborador.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isRegistering ? null : _registerCurrentUser,
              icon: _isRegistering
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person_add),
              label: const Text('Registrar Usuario Actual'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  _status,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            const Spacer(),
            const Text(
              'Nota: Cada usuario debe ejecutar esto una vez para poder ser agregado como colaborador.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
