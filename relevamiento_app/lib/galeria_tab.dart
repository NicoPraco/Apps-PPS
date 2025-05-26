// Paquetes de Flutter
import 'package:flutter/material.dart';

// Requisitos varios
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class GaleriaTab extends StatefulWidget {
  final String tipo;

  const GaleriaTab({super.key, required this.tipo});

  @override
  State<GaleriaTab> createState() => _GaleriaTabState();
}

class _GaleriaTabState extends State<GaleriaTab> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> fotos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarFotos();
  }

  @override
  Widget build(BuildContext context) {
    return cargando
        ? Center(
          child: LoadingAnimationWidget.discreteCircle(
            color: Colors.amberAccent,
            size: 80,
          ),
        )
        : fotos.isEmpty
        ? const Center(
          child: Text(
            "No hay fotos subidas aún.",
            style: TextStyle(color: Colors.white70),
          ),
        )
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fotos.length,
          itemBuilder: (context, index) {
            final foto = fotos[index];

            final String tipo = foto['tipo'];
            final String usuario = foto['usuario'] ?? 'Desconocido';
            final String fecha =
                DateTime.parse(
                  foto['fecha'],
                ).toLocal().toString().split('.')[0];
            final String url = foto['url'];
            final int votos = foto['votos'] ?? 0;

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () => _mostrarImagenAmpliada(context, url),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => const Icon(
                            Icons.image_not_supported,
                            size: 100,
                            color: Colors.red,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Datos a la izquierda
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tipo: $tipo",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Usuario: ${usuario.split('@')[0]}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Fecha: $fecha",
                                style: const TextStyle(color: Colors.white54),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Votos: $votos",
                                style: const TextStyle(
                                  color: Colors.amberAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Botón a la derecha
                        TextButton.icon(
                          onPressed: () => _votarFoto(foto['id']),
                          icon: const Icon(
                            Icons.thumb_up,
                            color: Colors.amberAccent,
                          ),
                          label: const Text(
                            "Votar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
  }

  Future<void> _cargarFotos() async {
    final response = await supabase
        .from('relevamiento_tabla_fotos')
        .select()
        .eq('tipo', widget.tipo)
        .order('fecha', ascending: false);

    if (mounted) {
      setState(() {
        fotos = List<Map<String, dynamic>>.from(response);
        cargando = false;
      });
    }
  }

  void _mostrarImagenAmpliada(BuildContext context, String url) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(url),
              ),
            ),
          ),
    );
  }

  Future<void> _votarFoto(int fotoId) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final yaVoto =
        await supabase
            .from('relevamiento_tabla_votos')
            .select()
            .eq('usuario', user.email!)
            .eq('foto_id', fotoId)
            .maybeSingle();

    if (yaVoto != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ya votaste esta foto.")));
      return;
    }

    await supabase.rpc('incrementar_votos', params: {'foto_id_input': fotoId});

    await supabase.from('relevamiento_tabla_votos').insert({
      'usuario': user.email,
      'foto_id': fotoId,
    });

    _cargarFotos();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("¡Voto Registrado!")));
  }
}
