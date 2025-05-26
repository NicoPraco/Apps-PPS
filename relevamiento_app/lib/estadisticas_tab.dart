// Paquetes de Flutter
import 'package:flutter/material.dart';
import 'dart:math';

// Otras Paginas

// Requisitos varios
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class EstadisticasTab extends StatefulWidget {
  final String tipo;

  const EstadisticasTab({super.key, required this.tipo});

  @override
  State<EstadisticasTab> createState() => _EstadisticasState();
}

class _EstadisticasState extends State<EstadisticasTab> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> fotos = [];

  bool cargando = true;
  bool mostrandoDialog = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return cargando
        ? const Center(child: CircularProgressIndicator())
        : Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                "Gráfico - Cosas ${widget.tipo}S",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 60),
              Center(child: SizedBox(height: 400, child: _buildGrafico())),
            ],
          ),
        );
  }

  Widget _buildGrafico() {
    if (fotos.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos que mostrar.',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      );
    }

    if (widget.tipo == 'LINDA') {
      return PieChart(
        PieChartData(
          sectionsSpace: 2,
          sections:
              fotos.asMap().entries.map((entry) {
                final foto = entry.value;
                return PieChartSectionData(
                  title: '${foto['votos']}',
                  value: (foto['votos'] as int).toDouble(),
                  radius: 70,
                  color: getRandomColor(),
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              if (response != null &&
                  response.touchedSection != null &&
                  response.touchedSection!.touchedSectionIndex < fotos.length) {
                final index = response.touchedSection!.touchedSectionIndex;
                _mostrarImagenAmpliada(context, fotos[index]['url']);
              }
            },
          ),
        ),
      );
    } else {
      return BarChart(
        BarChartData(
          //backgroundColor: Color.fromRGBO(200, 200, 200, 1),
          barGroups:
              fotos.asMap().entries.map((entry) {
                final index = entry.key;
                final foto = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: (foto['votos'] as int).toDouble(),
                      color: getRandomColor(),
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                  showingTooltipIndicators: [0],
                );
              }).toList(),
          barTouchData: BarTouchData(
            touchCallback: (event, response) {
              if (response != null &&
                  response.spot != null &&
                  response.spot!.touchedBarGroupIndex < fotos.length) {
                final index = response.spot!.touchedBarGroupIndex;
                _mostrarImagenAmpliada(context, fotos[index]['url']);
              }
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white, // Cambia aquí el color
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= fotos.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Foto ${index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }
  }

  void _mostrarImagenAmpliada(BuildContext context, String url) async {
    if (mostrandoDialog) return;
    mostrandoDialog = true;

    await showDialog(
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

    mostrandoDialog = false;
  }

  Future<void> _cargarDatos() async {
    final response = await supabase
        .from('relevamiento_tabla_fotos')
        .select('id, tipo, url, votos')
        .eq('tipo', widget.tipo)
        .gt('votos', 0);

    fotos = [];

    for (final row in response) {
      fotos.add(row);
    }

    if (mounted) {
      setState(() {
        cargando = false;
      });
    }
  }

  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
}
