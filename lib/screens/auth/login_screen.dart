import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Inicio de Sesión")),
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
                User? user = await _authService.signInWithEmail(
                    emailController.text, passwordController.text);
                if (user != null) {
                  context.go('/'); // Redirige a la pantalla principal
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error al iniciar sesión")));
                }
              },
              child: const Text("Iniciar Sesión"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                User? user = await _authService.signInWithGoogle();
                if (user != null) {
                  context.go('/'); // Redirige a la pantalla principal
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Error al iniciar sesión con Google")));
                }
              },
              icon: const Icon(Icons.g_mobiledata),
              label: const Text("Iniciar Sesión con Google"),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text("¿No tienes cuenta? Regístrate"),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty) {
                  await _authService.resetPassword(emailController.text);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "Correo de recuperación enviado si el email es válido")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Por favor, introduce un correo válido")));
                }
              },
              child: const Text("¿Olvidaste tu contraseña?"),
            ),
          ],
        ),
      ),
    );
  }
}
