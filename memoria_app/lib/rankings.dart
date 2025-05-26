// Paquetes de Flutter
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';

class Rankings extends StatefulWidget {
  const Rankings({super.key});

  @override
  State<Rankings> createState() => _RankingsState();
}

class _RankingsState extends State<Rankings> {
  List<Map<String, dynamic>> _resultados = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarTopCinco();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF263238),
      appBar: AppBar(
        title: const Text(
          'Clasificación - Los Mejores 5 Jugadores',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF607D8B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          _cargando
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : _mostrarLista(),
    );
  }

  void _cargarTopCinco() async {
    final supabase = Supabase.instance.client;

    try {
      final data = await supabase
          .from('resultados_juego_memoria')
          .select()
          .order('tiempo', ascending: true)
          .limit(5);

      setState(() {
        _resultados = List<Map<String, dynamic>>.from(data);
        _cargando = false;
      });
    } catch (e) {
      _cargando = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar los datos: $e',
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _mostrarLista() {
    if (_resultados.isEmpty) {
      return const Center(
        child: Text(
          'No hay resultados disponibles',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _resultados.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white24),
      itemBuilder: (context, index) {
        final fila = _resultados[index];

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.amber,
            child: Text(
              "#${index + 1}",
              style: const TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
          title: Text(
            fila['correo'] ?? 'Usuario desconocido',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          subtitle: Text(
            'Tiempo: ${_formatearTiempo(fila['tiempo'])} - Dificultad: ${fila['dificultad']}',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        );
      },
    );
  }

  String _formatearTiempo(int segundos) {
    final minutos = (segundos ~/ 60).toString().padLeft(2, '0');
    final segs = (segundos % 60).toString().padLeft(2, '0');
    return "$minutos:$segs";
  }
}
