// Paquetes de Flutter
import 'package:flutter/material.dart';

// Otras Paginas
import 'tabs_main.dart';
import 'login.dart';

// Requisitos varios
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relevamiento Visual'),
        actions: [
          IconButton(
            onPressed: () => _confirmarLogout(context),
            icon: Icon(MdiIcons.exitRun, color: Colors.red),
            tooltip: "Cerrar sesión",
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _navegar(context, 'LINDA'),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/cosas_lindas.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      const Color.fromRGBO(0, 0, 0, 0.4),
                      BlendMode.darken,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Cosas LINDAS',
                  style: TextStyle(
                    fontSize: 42,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () => _navegar(context, 'FEA'),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/cosas_feas.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      const Color.fromRGBO(0, 0, 0, 0.4),
                      BlendMode.darken,
                    ),
                  ),
                ),

                alignment: Alignment.center,
                child: Text(
                  'Cosas FEAS',
                  style: TextStyle(
                    fontSize: 42,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navegar(BuildContext context, String tipo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TabsMain(tipo: tipo)),
    );
  }

  Future<void> _confirmarLogout(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("¿Cerrar sesión?"),
            content: const Text("¿Estás seguro de que querés cerrar sesión?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Cerrar sesión",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const Login()));
      }
    }
  }
}
