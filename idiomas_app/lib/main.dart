// Paquetes de Flutter
import 'package:flutter/material.dart';

// Otras paginas del proyecto
import 'splash_screen.dart';

// Requisitos varios
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Future.delayed(const Duration(seconds: 2)); // solo para testear
  try {
    await Supabase.initialize(
      url: 'https://sabvdmnpwuqyyiuyqmza.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNhYnZkbW5wd3VxeXlpdXlxbXphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ0MTA0ODAsImV4cCI6MjA1OTk4NjQ4MH0.WwHL169CPHu9F3BTPnN_USJaRRkNBE29Gow2_2b5K7E',
    );

    runApp(const MyApp());
  } catch (e) {
    // Esto NO se verá en release, pero sirve en debug o log interno
    debugPrint('Error en main: $e');
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Error de inicialización'))),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabla de Idiomas',
      theme: ThemeData(
        fontFamily: GoogleFonts.comicNeue().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // <- Esta es tu pantalla
    );
  }
}
