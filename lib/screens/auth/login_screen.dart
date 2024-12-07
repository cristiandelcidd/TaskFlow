import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginBody(authService: _authService),
    );
  }
}

class LoginBody extends StatefulWidget {
  final AuthService authService;

  const LoginBody({required this.authService, super.key});

  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _toggleLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 48),
            const Text(
              "Inicia Sesión",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Bienvenido de nuevo. Por favor, introduce tus datos para continuar.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _emailController,
                    label: "Correo Electrónico",
                    icon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Introduce tu correo";
                      }
                      if (!RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                          .hasMatch(value)) {
                        return "Correo no válido";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: "Contraseña",
                    icon: Icons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Introduce tu contraseña";
                      }
                      if (value.length < 6) {
                        return "La contraseña debe tener al menos 6 caracteres";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _login,
                    style: _buttonStyle(),
                    child: const Text("Iniciar Sesión",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _loginWithGoogle,
              icon: const Icon(FontAwesomeIcons.google, color: Colors.white),
              label: const Text(
                "Iniciar Sesión con Google",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: _buttonStyle(color: Colors.blueAccent),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text("¿No tienes cuenta? Regístrate"),
            ),
            TextButton(
              onPressed: _isLoading ? null : _resetPassword,
              child: const Text("¿Olvidaste tu contraseña?"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }

  ButtonStyle _buttonStyle({Color color = Colors.green}) {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: color,
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _toggleLoading(true);
      try {
        User? user = await widget.authService.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        if (user != null) {
          if (mounted) context.go('/');
        } else {
          _showError("Error al iniciar sesión");
        }
      } catch (e) {
        _showError("Error: ${e.toString()}");
      } finally {
        _toggleLoading(false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    _toggleLoading(true);
    try {
      UserCredential? userCredential =
          await widget.authService.signInWithGoogle();
      if (userCredential.user != null) {
        if (mounted) context.go('/');
      } else {
        _showError("Error al iniciar sesión con Google");
      }
    } catch (e) {
      _showError("Error: ${e.toString()}");
    } finally {
      _toggleLoading(false);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isNotEmpty) {
      try {
        await widget.authService.resetPassword(_emailController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text("Correo de recuperación enviado si el email es válido"),
          ));
        }
      } catch (e) {
        _showError("Error al enviar correo de recuperación");
      }
    } else {
      _showError("Introduce un correo válido");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
