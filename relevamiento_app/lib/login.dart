// Paquetes de Flutter
import 'package:flutter/material.dart';

// Otras Paginas
import 'home.dart';
import 'registro.dart';

// Requisitos varios
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // ACA VAN LAS VARIABLES
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        //backgroundColor: const Color(0xFFFF8A65),
        automaticallyImplyLeading: false, // Sin flecha atrás
        elevation: 0,
        title: const Text(
          "Iniciar Sesión",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const Registro()));
            },
            child: const Text(
              "Registrarse",
              style: TextStyle(color: Color(0xffe4e4c5)),
            ),
          ),
        ],
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Acceso Rápido:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      backgroundColor: const Color(0xFF3949AB),
                      foregroundColor: Colors.white,
                      elevation: 4,
                    ),
                    onPressed:
                        () => _loginRapido("admin@test.com", "admin1234"),
                    child: const Text("Administrador"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      elevation: 4,
                    ),
                    onPressed:
                        () => _loginRapido("profesor@test.com", "profe1234"),
                    child: const Text("Profesor"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      backgroundColor: const Color(0xFFD81B60),
                      foregroundColor: Colors.white,
                      elevation: 4,
                    ),
                    onPressed:
                        () => _loginRapido("alumno@test.com", "alumni1234"),
                    child: const Text("Alumno"),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 18, color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Correo Electrónico",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(fontSize: 18, color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Clave",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text;
                    await _realizarLogin(email, password);
                  },
                  child: const Text(
                    "Iniciar Sesión",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarSpinner() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: Colors.pinkAccent,
              size: 84,
            ),
          ),
    );
  }

  void _ocultarSpinner() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _realizarLogin(String email, String password) async {
    _mostrarSpinner();
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      await Future.delayed(const Duration(seconds: 1));

      if (response.user != null) {
        // Login Exitoso!
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("¡Inicio de Sesión Exitoso!"),
            backgroundColor: Color.fromARGB(255, 0, 152, 33),
            duration: Duration(seconds: 3),
          ),
        );

        _ocultarSpinner();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Login Fallo!
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error en el Inicio de Sesión"),
            backgroundColor: Color.fromARGB(255, 255, 0, 0),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Excepcion!!
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Color.fromARGB(255, 255, 0, 0),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _loginRapido(String email, String password) async {
    await _realizarLogin(email, password);
  }
}
