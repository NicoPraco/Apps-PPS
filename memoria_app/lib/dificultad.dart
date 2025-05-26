// Paquetes de Flutter
import 'package:flutter/material.dart';
import 'package:memoria_app/rankings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Otras Paginas
import 'login.dart';
import 'juego_memoria.dart';

class Dificultad extends StatefulWidget {
  const Dificultad({super.key});

  @override
  State<Dificultad> createState() => _DificultadState();
}

class _DificultadState extends State<Dificultad> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF263238),

      // APP BAR - Parte superior de la app
      appBar: AppBar(
        backgroundColor: const Color(0xFF37474F),
        title: const Text(
          "Juego de la Memoria - Dificultad",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: "Top 5 Jugadores",
            color: Colors.yellowAccent[700],
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Rankings()),
              );
            },
          ),
          IconButton(
            onPressed: () => _confirmarLogout(),
            icon: const Icon(Icons.logout),
            color: Colors.red,
          ),
        ],

        iconTheme: IconThemeData(
          color: Colors.white, // Cambia el color del icono de retroceso
        ),
      ),

      // BODY DE LA APP
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: _buildDificultadButton(
                texto: "Fácil (3 Pares)",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => const JuegoMemoria(
                            cantidadPares: 3,
                            titulo: "Fácil",
                          ),
                    ),
                  );
                },
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildDificultadButton(
                texto: "Media (5 Pares)",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => const JuegoMemoria(
                            cantidadPares: 5,
                            titulo: "Media",
                          ),
                    ),
                  );
                },
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildDificultadButton(
                texto: "Difícil (8 Pares)",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => const JuegoMemoria(
                            cantidadPares: 8,
                            titulo: "Difícil",
                          ),
                    ),
                  );
                },
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarLogout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("¿Cerrar sesión?"),
            content: const Text("Se cerrará la sesión actual."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // cancelar
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // cerrar el diálogo
                  _cerrarSesion(); // hacer logout real
                },
                child: const Text(
                  "Cerrar sesión",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _cerrarSesion() async {
    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const Login()));
  }

  Widget _buildDificultadButton({
    required String texto,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
      ),
      child: Center(
        child: Text(
          texto,
          style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
