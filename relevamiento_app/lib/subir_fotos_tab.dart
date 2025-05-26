// Paquetes de Flutter
import 'package:flutter/material.dart';

// Otras Paginas
//import 'login.dart';

// Requisitos varios
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SubirFotosTab extends StatefulWidget {
  final String tipo;

  const SubirFotosTab({super.key, required this.tipo});

  @override
  State<SubirFotosTab> createState() => _SubirFotosState();
}

class _SubirFotosState extends State<SubirFotosTab> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _sacarFoto(widget.tipo),
              icon: Icon(MdiIcons.camera, size: 48),
              label: const Text("Sacar Fotos", style: TextStyle(fontSize: 24)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(100),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _elegirMultiplesFotos(),
              label: const Text(
                "Seleccionar Múltiples",
                style: TextStyle(fontSize: 24),
              ),
              icon: const Icon(Icons.photo_library, size: 48),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sacarFoto(String tipo) async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);

    if (foto != null) {
      try {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;

        if (user == null) throw Exception("¡Usuario no registrado!");

        final bytes = await foto.readAsBytes();
        final nombreArchivo =
            'foto-${tipo.toLowerCase()}--${user.email}-${DateTime.now().microsecondsSinceEpoch}.jpg';
        final ruta = 'fotos/$nombreArchivo';

        // SUBO AL STORAGE
        await supabase.storage.from('fotos').uploadBinary(ruta, bytes);

        // Obtengo una URL Publica de la imagen:
        final urlPublica = supabase.storage.from('fotos').getPublicUrl(ruta);

        await supabase.from('relevamiento_tabla_fotos').insert({
          'nombre': nombreArchivo,
          'url': urlPublica,
          'tipo': tipo,
          'usuario': user.email,
          'fecha': DateTime.now().toIso8601String(),
          'votos': 0,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Foto subida con exito!",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.lightGreen,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error al subir la foto: ${e.toString()}",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _elegirMultiplesFotos() async {
    final List<XFile> fotos = await _picker.pickMultiImage();
    int subidas = 0;

    if (fotos.isNotEmpty) {
      // SUBO LA FOTO A SUPABSE CON EL TIPO DE REFERENCIA!

      try {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;

        if (user == null) throw Exception("¡Usuario no registrado!");

        for (final foto in fotos) {
          final bytes = await foto.readAsBytes();
          final nombreArchivo =
              'foto-multiple-${user.email}-${DateTime.now().microsecondsSinceEpoch}.jpg';
          final ruta = 'fotos/$nombreArchivo';

          // Subo a Supabase Storage
          await supabase.storage.from('fotos').uploadBinary(ruta, bytes);

          // Obtengo URL Publica de la foto
          final urlPublica = supabase.storage.from('fotos').getPublicUrl(ruta);

          // Inserto en la tabla
          await supabase.from('relevamiento_tabla_fotos').insert({
            'nombre': nombreArchivo,
            'url': urlPublica,
            'tipo': widget.tipo,
            'usuario': user.email,
            'fecha': DateTime.now().toIso8601String(),
            'votos': 0,
          });

          subidas++;
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "¡Se subieron $subidas foto(s) con exito!",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.lightGreen,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error al subir la foto: ${e.toString()}",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
