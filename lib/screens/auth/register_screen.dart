import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';

class RegisterScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Correo"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                User? user = await _authService.registerWithEmail(
                    emailController.text, passwordController.text);
                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text("Cuenta creada. Por favor, inicia sesión")));
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error al registrarse")));
                }
              },
              child: const Text("Registrarse con Correo"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                User? user = await _authService.signInWithGoogle();
                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Registro exitoso con Google.")));
                  context
                      .go('/'); // Redirige al inicio si el registro es exitoso
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Error al registrarse con Google")));
                }
              },
              icon: const Icon(Icons.g_mobiledata),
              label: const Text("Registrarse con Google"),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}
