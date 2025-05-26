// Paquetes de Flutter
import 'package:flutter/material.dart';

// Otras Paginas
import 'subir_fotos_tab.dart';
import 'estadisticas_tab.dart';
import 'galeria_tab.dart';

// Requisitos varios

class TabsMain extends StatefulWidget {
  final String tipo;

  const TabsMain({super.key, required this.tipo});

  @override
  State<TabsMain> createState() => _TabsMainState();
}

class _TabsMainState extends State<TabsMain> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.tipo == 'LINDA'
                ? 'Relevamiento Visual - Cosas Lindas'
                : 'Relevamiento Visual - Cosas Feas',
          ),
          titleTextStyle: TextStyle(fontSize: 18),
          bottom: const TabBar(
            labelColor: Colors.amberAccent,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amberAccent,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(icon: Icon(Icons.camera_alt), text: "Subir Fotos"),
              Tab(icon: Icon(Icons.list_alt), text: "Galeria"),
              Tab(icon: Icon(Icons.bar_chart), text: "Estadísticas"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SubirFotosTab(tipo: widget.tipo),
            GaleriaTab(tipo: widget.tipo),
            EstadisticasTab(tipo: widget.tipo),
          ],
        ),
      ),
    );
  }
}
