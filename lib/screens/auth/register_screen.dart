import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';

class RegisterScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RegisterBody(authService: _authService),
    );
  }
}

class RegisterBody extends StatefulWidget {
  final AuthService authService;

  const RegisterBody({required this.authService, super.key});

  @override
  State<RegisterBody> createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<RegisterBody> {
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),
          const Text(
            "Crear Cuenta",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Regístrate para comenzar tu experiencia",
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
                      return "Por favor, introduce tu correo";
                    }
                    if (!RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                        .hasMatch(value)) {
                      return "Introduce un correo válido";
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
                      return "Por favor, introduce tu contraseña";
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
                  onPressed: _register,
                  style: _buttonStyle(),
                  child: const Text("Registrarse",
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _registerWithGoogle,
            icon: const Icon(FontAwesomeIcons.google, color: Colors.white),
            label: const Text("Registrarse con Google",
                style: TextStyle(fontSize: 15, color: Colors.white)),
            style: _buttonStyle(color: Colors.blueAccent),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              "¿Ya tienes una cuenta? Inicia sesión",
              style: TextStyle(color: Colors.indigo, fontSize: 14),
            ),
          ),
        ],
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

  ButtonStyle _buttonStyle({Color color = Colors.indigo}) {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: color,
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _toggleLoading(true);
      try {
        User? user = await widget.authService.registerWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        if (user != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Cuenta creada. Por favor, inicia sesión"),
            ));
            context.pop();
          }
        } else {
          _showError("Error al registrarse");
        }
      } catch (e) {
        _showError("Error: ${e.toString()}");
      } finally {
        _toggleLoading(false);
      }
    }
  }

  Future<void> _registerWithGoogle() async {
    _toggleLoading(true);
    try {
      UserCredential? userCredential =
          await widget.authService.signInWithGoogle();
      if (userCredential.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Registro exitoso con Google."),
          ));
          context.go('/');
        }
      } else {
        _showError("Error al registrarse con Google");
      }
    } catch (e) {
      _showError("Error: ${e.toString()}");
    } finally {
      _toggleLoading(false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
