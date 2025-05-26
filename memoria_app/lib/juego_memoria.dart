import 'package:flutter/material.dart';
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Carta {
  final int id; // Identifica el par de cartas
  bool estaDadaVuelta; // Indica si la carta está dada vuelta
  bool resuelta; // Indica si la carta ha sido resuelta

  Carta({required this.id, this.estaDadaVuelta = false, this.resuelta = false});
}

class JuegoMemoria extends StatefulWidget {
  final int cantidadPares;
  final String titulo;

  const JuegoMemoria({
    super.key,
    required this.cantidadPares,
    required this.titulo,
  });

  @override
  State<JuegoMemoria> createState() => _JuegoMemoriaState();
}

class _JuegoMemoriaState extends State<JuegoMemoria> {
  int segundos = 0;
  late Timer _timer;
  late List<Carta> cartas;
  List<int> seleccionadas = [];

  bool _juegoTerminado() {
    return cartas.every((carta) => carta.resuelta);
  }

  @override
  Widget build(BuildContext context) {
    final totalTarjetas = widget.cantidadPares * 2;

    // AppBar Color --> Segun Dificultad
    Color appBarColor;
    if (widget.titulo == "Fácil") {
      appBarColor = const Color(0xFF4CAF50);
    } else if (widget.titulo == "Media") {
      appBarColor = const Color(0xFFFF9800);
    } else {
      appBarColor = const Color(0xFFF44336);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF263238),
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          "Juego de la Memoria - ${widget.titulo}",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Elegimos columnas según dificultad
          int columnas = _calcularColumnas(totalTarjetas);

          final filas = (totalTarjetas / columnas).ceil();

          // Calculamos el aspecto para que el grid ocupe toda la altura sin scroll
          final alturaDisponible =
              constraints.maxHeight - 120; // espacio para el header y margen
          final altoPorTarjeta =
              (alturaDisponible - ((filas - 1) * 12)) / filas;
          final anchoPorTarjeta =
              (constraints.maxWidth - ((columnas - 1) * 12)) / columnas;
          final aspectRatio = anchoPorTarjeta / altoPorTarjeta;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      "Emparejá las Imágenes",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tiempo: ${_formatearTiempo(segundos)}",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columnas,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: aspectRatio,
                  padding: const EdgeInsets.all(12),

                  children: List.generate(totalTarjetas, (index) {
                    return _mostrarCartas(index);
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _iniciarTemporizador();
    _cartasInicializar();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _iniciarTemporizador() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        segundos++;
      });
    });
  }

  int _calcularColumnas(int totalTarjetas) {
    // Busca el valor más cercano a la raíz cuadrada del total de tarjetas
    int columnas = totalTarjetas;
    for (int i = 1; i <= totalTarjetas; i++) {
      if (totalTarjetas % i == 0) {
        if ((totalTarjetas / i - i).abs() <
            (totalTarjetas / columnas - columnas).abs()) {
          columnas = i;
        }
      }
    }
    return columnas;
  }

  static String _formatearTiempo(int segundos) {
    final minutos = (segundos ~/ 60).toString().padLeft(2, '0');
    final segundosRestantes = (segundos % 60).toString().padLeft(2, '0');
    return "$minutos:$segundosRestantes";
  }

  void _cartasInicializar() {
    cartas = [];

    for (int i = 0; i < widget.cantidadPares; i++) {
      cartas.add(Carta(id: i));
      cartas.add(Carta(id: i));
    }
    cartas.shuffle();
  }

  Widget _obtenerIconoCarta(int id) {
    final String nivel = widget.titulo;

    if (nivel == "Fácil") {
      final iconos = [
        FontAwesomeIcons.dog,
        FontAwesomeIcons.cat,
        FontAwesomeIcons.fish,
      ];
      return FaIcon(iconos[id], size: 40, color: Colors.white);
    } else if (nivel == "Media") {
      final iconos = [
        FontAwesomeIcons.wrench,
        FontAwesomeIcons.hammer,
        FontAwesomeIcons.trowel,
        FontAwesomeIcons.screwdriver,
        FontAwesomeIcons.screwdriverWrench,
      ];
      return FaIcon(iconos[id], size: 40, color: Colors.white);
    } else {
      final imagenes = [
        'manzana.png',
        'banana.png',
        'frutilla.png',
        'kiwi.png',
        'pera.png',
        'sandia.png',
        'uvas.png',
        'tomate.png',
      ];
      return Image.asset(
        'assets/frutas/${imagenes[id]}',
        width: 50,
        height: 50,
      );
    }
  }

  Widget _mostrarCartas(int index) {
    return GestureDetector(
      onTap: () {
        if (!cartas[index].resuelta &&
            !cartas[index].estaDadaVuelta &&
            seleccionadas.length < 2) {
          setState(() {
            cartas[index].estaDadaVuelta = true;
            seleccionadas.add(index);
          });
          if (seleccionadas.length == 2) {
            _verificarSeleccion();
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color:
              cartas[index].estaDadaVuelta
                  ? Colors.green
                  : (cartas[index].resuelta
                      ? Colors.lightBlue
                      : Colors.blueGrey.shade700),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child:
              cartas[index].estaDadaVuelta || cartas[index].resuelta
                  ? _obtenerIconoCarta(cartas[index].id)
                  : const Icon(Icons.help_outline, color: Colors.white),
        ),
      ),
    );
  }

  void _verificarSeleccion() async {
    if (seleccionadas.length == 2) {
      final carta1 = cartas[seleccionadas[0]];
      final carta2 = cartas[seleccionadas[1]];

      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        if (carta1.id == carta2.id) {
          carta1.resuelta = true;
          carta2.resuelta = true;
        } else {
          carta1.estaDadaVuelta = false;
          carta2.estaDadaVuelta = false;
        }
      });

      seleccionadas.clear();

      if (_juegoTerminado()) {
        // Mostrar mensaje de juego terminado
        _timer.cancel();
        _guardarResultado();
        _mostrarMensaje();
      }
    }
  }

  void _guardarResultado() async {
    final supabase = Supabase.instance.client;
    final usuario = supabase.auth.currentUser;

    try {
      if (usuario != null) {
        final tiempoFinal = _formatearTiempo(segundos);
        final fecha = DateTime.now().toIso8601String();

        await supabase.from('resultados_juego_memoria').insert({
          'correo': usuario.email,
          'tiempo': segundos,
          'tiempo_str': tiempoFinal,
          'fecha': fecha,
          'dificultad': widget.titulo,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Resultado guardado con éxito",
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error al guardar el resultado: $e",
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarMensaje() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "¡Ganaste! Tu tiempo fue de: ${_formatearTiempo(segundos)}",
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}
