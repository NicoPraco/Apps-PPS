// Paquetes de Flutter
import 'package:flutter/material.dart';

// Otras Paginas
import 'login.dart';
import 'qr_scan_page.dart';

// Requisitos varios
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int creditos = 0;

  String? get email => Supabase.instance.client.auth.currentUser?.email;

  final Map<String, int> codigosValidos = {
    "8c95def646b6127282ed50454b73240300dccabc": 10,
    "ae338e4e0cbb4e4bcffaf9ce5b409feb8edd5172": 50,
    "2786f4877b9091dcad7f35751bfcf5d5ea712b2f": 100,
  };

  bool get esAdmin {
    if (email == null) return false;
    return email!.split('@')[0].toLowerCase() == 'admin';
  }

  @override
  void initState() {
    super.initState();
    _cargarCreditosPrevios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carga de Crédito"),
        actions: [
          TextButton(
            onPressed: () => _confirmarLogout(),
            child: const Text(
              "Salir",

              style: TextStyle(color: Colors.amberAccent, fontSize: 14),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Créditos acumulados:",
                    style: TextStyle(fontSize: 48, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$creditos",
                    style: const TextStyle(
                      fontSize: 128,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),

                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("Escanear Código QR"),
                    onPressed: _escanearQR,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 40,
                      ),
                      textStyle: const TextStyle(fontSize: 28),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever),
              label: const Text("Limpiar Créditos"),
              onPressed: () => _confirmarLimpiar(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarLimpiar() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("¿Borrar Créditos?"),
            content: const Text(
              "Se perderan TODOS los creditos acutalmente acumulados.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // cancelar
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // cerrar el diálogo
                  _limpiarCreditos(); // hacer logout real
                },
                child: const Text(
                  "Borrar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
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

  void _limpiarCreditos() async {
    final correo = email;
    if (correo == null) return;

    final supabase = Supabase.instance.client;

    try {
      // Borra los registros del usuario
      await supabase
          .from('carga_creditos_cargados')
          .delete()
          .eq('correo', correo);

      setState(() {
        creditos = 0;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Créditos y registros eliminados correctamente."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error al limpiar créditos: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _escanearQR() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );

    if (result != null && result is String) {
      _procesarCodigo(result);
    }
  }

  void _cargarCreditosPrevios() async {
    final correo = email;
    if (correo == null) return;

    final supabase = Supabase.instance.client;

    final registros = await supabase
        .from('carga_creditos_cargados')
        .select('codigo, veces_cargado')
        .eq('correo', correo);

    int total = 0;

    for (final registro in registros) {
      final codigo = registro['codigo'] as String?;
      final veces = registro['veces_cargado'] as int?;

      if (codigo != null &&
          veces != null &&
          codigosValidos.containsKey(codigo)) {
        // Si es admin podría haber 2 cargas del mismo código
        final cargaValida = esAdmin ? veces.clamp(0, 2) : veces.clamp(0, 1);
        total += codigosValidos[codigo]! * cargaValida;
      }
    }

    if (!mounted) return;
    setState(() {
      creditos = total;
    });
  }

  void _procesarCodigo(String codigo) async {
    final correo = email;

    if (correo == null) return;

    final supabase = Supabase.instance.client;

    if (!codigosValidos.containsKey(codigo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "❌ Código inválido. Solo se permiten 3 códigos específicos.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Buscar si este código ya fue cargado por este usuario
    final response =
        await supabase
            .from('carga_creditos_cargados')
            .select('veces_cargado')
            .eq('correo', correo)
            .eq('codigo', codigo)
            .maybeSingle();

    final vecesCargado = response?['veces_cargado'] ?? 0;

    // Lógica de validación
    if (!esAdmin && vecesCargado >= 1) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Este código ya fue cargado una vez."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (esAdmin && vecesCargado >= 2) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "⚠️ Este código ya fue cargado 2 veces (límite para Admin).",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Todo OK → Registrar nueva carga
    final nuevosCreditos = codigosValidos[codigo]!;

    await supabase.from('carga_creditos_cargados').upsert({
      'correo': correo,
      'codigo': codigo,
      'veces_cargado': vecesCargado + 1,
    });

    setState(() {
      creditos += nuevosCreditos;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Crédito cargado: +$nuevosCreditos puntos"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
