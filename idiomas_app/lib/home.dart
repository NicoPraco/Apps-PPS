import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Ejemplo de palabras (tema e idioma se podrían usar para traducir)
  final Map<String, Map<String, List<String>>> contenido = {
    'es': {
      'colores': ['Rojo', 'Verde', 'Azul', 'Amarillo', 'Naranja', 'Violeta'],
      'numeros': ['Uno', 'Dos', 'Tres', 'Cuatro', 'Cinco', 'Seis'],
      'animales': ['Perro', 'Gato', 'Pájaro', 'Pez', 'Caballo', 'Oveja'],
    },
    'en': {
      'colores': ['Red', 'Green', 'Blue', 'Yellow', 'Orange', 'Violet'],
      'numeros': ['One', 'Two', 'Three', 'Four', 'Five', 'Six'],
      'animales': ['Dog', 'Cat', 'Bird', 'Fish', 'Horse', 'Sheep'],
    },
    'pt': {
      'colores': ['Vermelho', 'Verde', 'Azul', 'Amarelo', 'Laranja', 'Violeta'],
      'numeros': ['Um', 'Dois', 'Três', 'Quatro', 'Cinco', 'Seis'],
      'animales': ['Cachorro', 'Gato', 'Pásaro', 'Peixe', 'Cavalo', 'Ovelha'],
    },
  };

  String idiomaActual = 'es';
  String temaActual = 'colores';
  final FlutterTts _tts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    final palabras = contenido[idiomaActual]![temaActual]!;

    return Scaffold(
      backgroundColor: const Color(0xFF1B2A41),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C75),
        toolbarHeight: 0,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          final maxWidth = constraints.maxWidth;
          final maxHeight = constraints.maxHeight;

          //final crossCount = isLandscape ? 3 : 2;
          final spacing = 16.0;
          final buttonSize =
              isLandscape
                  ? maxHeight / 2 -
                      spacing *
                          1.5 // 2 filas
                  : (maxWidth - 3 * spacing) / 2; // 2 columnas

          return Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLandscape ? 0 : 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: isLandscape ? maxHeight : double.infinity,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: spacing,
                  runSpacing: spacing,
                  children: List.generate(palabras.length, (index) {
                    return SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: const CircleBorder(),
                          backgroundColor: const Color(0x14FFFFFF),
                          shadowColor: Colors.black12,
                          elevation: 6,
                        ),
                        onPressed: () {
                          // reproducir sonido
                          _decirPalabra(palabras[index]);
                        },
                        child: _getIconFor(index),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        },
      ),

      floatingActionButton: Stack(
        children: [
          // Logout flotante (izquierda)
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: FloatingActionButton(
                heroTag: "logout",
                backgroundColor: Colors.white,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('¿Seguro que querés salir?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context); // Cierra el diálogo
                                _cerrarSesion(); // Ejecuta el logout real
                              },
                              child: const Text('Salir'),
                            ),
                          ],
                        ),
                  );
                },
                tooltip: "Cerrar sesión",
                child: const Icon(Icons.logout, color: Colors.red),
              ),
            ),
          ),

          // Tema (abajo derecha)
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Speed Dial - Temas
                SpeedDial(
                  heroTag: "dial-tema",
                  backgroundColor: Colors.orangeAccent,
                  icon: Icons.category,
                  activeIcon: Icons.close,
                  direction: SpeedDialDirection.left,
                  overlayColor: Colors.grey.shade200,
                  overlayOpacity: 0.15,
                  spaceBetweenChildren: 2,

                  children: [
                    SpeedDialChild(
                      backgroundColor:
                          temaActual == 'colores'
                              ? Colors.lightGreenAccent[100]
                              : Colors.white,
                      child: const Icon(Icons.palette),
                      onTap: () => setState(() => temaActual = 'colores'),
                    ),

                    SpeedDialChild(
                      backgroundColor:
                          temaActual == 'numeros'
                              ? Colors.lightGreenAccent[100]
                              : Colors.white,
                      child: Icon(Icons.looks_one),
                      onTap: () => setState(() => temaActual = 'numeros'),
                    ),

                    SpeedDialChild(
                      backgroundColor:
                          temaActual == 'animales'
                              ? Colors.lightGreenAccent[100]
                              : Colors.white,
                      child: const Icon(Icons.pets),
                      onTap: () => setState(() => temaActual = 'animales'),
                    ),
                  ],
                ),

                // Speed Dial - Idiomas
                SizedBox(height: 20),
                SpeedDial(
                  heroTag: "dial-idioma",
                  backgroundColor: Colors.greenAccent,
                  icon: Icons.translate,
                  activeIcon: Icons.close,
                  direction: SpeedDialDirection.left,
                  overlayColor: Colors.grey.shade200,
                  overlayOpacity: 0.15,
                  spaceBetweenChildren: 2,

                  children: [
                    SpeedDialChild(
                      backgroundColor:
                          idiomaActual == 'es'
                              ? Colors.orangeAccent[100]
                              : Colors.white,
                      child: const Text("🇦🇷", style: TextStyle(fontSize: 24)),
                      onTap: () => setState(() => idiomaActual = 'es'),
                    ),

                    SpeedDialChild(
                      backgroundColor:
                          idiomaActual == 'en'
                              ? Colors.orangeAccent[100]
                              : Colors.white,
                      child: const Text("🇬🇧", style: TextStyle(fontSize: 24)),
                      onTap: () => setState(() => idiomaActual = 'en'),
                    ),

                    SpeedDialChild(
                      backgroundColor:
                          idiomaActual == 'pt'
                              ? Colors.orangeAccent[100]
                              : Colors.white,
                      child: const Text("🇧🇷", style: TextStyle(fontSize: 24)),
                      onTap: () => setState(() => idiomaActual = 'pt'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _decirPalabra(String texto) async {
    String idiomaTTS = switch (idiomaActual) {
      'es' => 'es-ES',
      'en' => 'en-US',
      'pt' => 'pt-BR',
      _ => 'es-ES',
    };

    await _tts.setLanguage(idiomaTTS);
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(texto);
  }

  Icon _getIconFor(int index) {
    switch (temaActual) {
      case 'numeros':
        final numberIcons = [
          Icons.looks_one,
          Icons.looks_two,
          Icons.looks_3,
          Icons.looks_4,
          Icons.looks_5,
          Icons.looks_6,
        ];
        return Icon(
          numberIcons[index % numberIcons.length],
          size: 60,
          color: Colors.white,
        );

      case 'colores':
        final colorList = [
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.yellow,
          Colors.orange,
          Colors.purple,
        ];
        return Icon(
          Icons.circle,
          color: colorList[index % colorList.length],
          size: 60,
        );

      case 'animales':
        final animalIcons = [
          MdiIcons.dog,
          MdiIcons.cat,
          MdiIcons.bird,
          MdiIcons.fish,
          MdiIcons.horse,
          MdiIcons.sheep,
        ];
        return Icon(
          animalIcons[index % animalIcons.length],
          size: 60,
          color: Colors.white,
        );

      default:
        return const Icon(Icons.help);
    }
  }

  void _cerrarSesion() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const Login()));
  }
}
