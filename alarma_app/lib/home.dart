// Paquetes necesarios
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:torch_light/torch_light.dart';
import 'package:audioplayers/audioplayers.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool alarmaActivada = false;
  bool linternaEncendida = false;
  bool vibracionActivada = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF8A65),
        title: const Text(
          "Alarma de Robo",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      floatingActionButton:
          alarmaActivada
              ? null // No se muestra nada
              : FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                onPressed: _confirmarLogout,
                tooltip: "Cerrar sesión",
                child: const Icon(Icons.logout, color: Colors.red),
              ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (!alarmaActivada) {
                setState(() {
                  alarmaActivada = true;
                });
              } else {
                _mostrarModalDesactivacion();
              }
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: alarmaActivada ? Colors.red : Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                alarmaActivada ? Icons.lock : Icons.lock_open,
                color: Colors.white,
                size: 150,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _iniciarAlarma();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _iniciarAlarma() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      if (!alarmaActivada) return;

      final x = event.x;
      final y = event.y;
      final z = event.z;

      if (x > 5) {
        print("¡Movimiento hacia la derecha!");
        _reproducirSonido("sounds/alarmaDer.mp3");
      } else if (x < -5) {
        print("¡Movimiento hacia la izquierda!");
        _reproducirSonido("sounds/alarmaIzq.mp3");
      } else if (z.abs() < 4 && y.abs() > 6 && !linternaEncendida) {
        print("¡Vertical!");
        linternaEncendida = true;
        _activarLinterna();
      } else if ((z.abs() > 4 || y.abs() < 5) && linternaEncendida) {
        linternaEncendida = false; // Reiniciar la linterna
      } else if (z > 9 && x.abs() < 3 && y.abs() < 3 && !vibracionActivada) {
        print("¡Horizontal!");
        vibracionActivada = true;
        _activarVibracion();
      } else if (z < 9 && vibracionActivada) {
        vibracionActivada = false; // Reiniciar la vibración
      }
    });
  }

  void _activarVibracion() async {
    try {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(duration: 5000, amplitude: 150);
        await _reproducirSonido("sounds/alarmaVibrar.mp3");
      } else {
        print("El dispositivo no tiene vibrador.");
      }
    } catch (e) {
      print("Error al activar la vibración: $e");
    }
  }

  void _activarLinterna() async {
    try {
      if (await TorchLight.isTorchAvailable()) {
        await TorchLight.enableTorch();
        await _reproducirSonido("sounds/alarmaLinterna.mp3");
        await Future.delayed(const Duration(seconds: 5));
        await TorchLight.disableTorch();
      } else {
        print("Linterna no disponible en este dispositivo.");
      }
    } catch (e) {
      print("Error al activar la linterna: $e");
    }
  }

  Future<void> _reproducirSonido(String nombreArchivo) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer
          .setSource(AssetSource(nombreArchivo))
          .timeout(const Duration(seconds: 5));
      await _audioPlayer.resume();
    } catch (e) {
      print("Error al reproducir el sonido: $e");
    }
  }

  _mostrarModalDesactivacion() {
    final TextEditingController claveController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              "Ingrese la clave para desactivar la alarma",
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: claveController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Clave",
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final claveIngresada = claveController.text;
                  final sesion = Supabase.instance.client.auth.currentUser;
                  if (sesion != null && sesion.email != null) {
                    try {
                      final mail = sesion.email!;
                      final resultado = await Supabase.instance.client.auth
                          .signInWithPassword(
                            email: mail,
                            password: claveIngresada,
                          );

                      if (resultado.user != null) {
                        setState(() {
                          alarmaActivada = false;
                          linternaEncendida = false;
                          vibracionActivada = false;
                        });
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      _activarCastigo();
                    }
                  }
                },
                child: const Text(
                  "Aceptar",
                  style: TextStyle(color: Colors.orangeAccent),
                ),
              ),
            ],
          ),
    );
  }

  void _activarCastigo() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: const Text("¡Contraseña Incorrecta!")));

    _activarVibracion();
    _activarLinterna();
    _reproducirSonido("sounds/alarmaTodo.mp3");
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
}
