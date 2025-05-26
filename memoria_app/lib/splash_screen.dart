// Paquetes de Flutter
import 'package:flutter/material.dart';

// Otras paginas del proyecto
import 'login.dart';

// Paquete de animaciones
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const Login()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF263238),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
                  "Praconovo Nicolás",
                  style: const TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                .animate()
                .fadeIn(duration: 1500.ms)
                .slideY(begin: -1, duration: 1000.ms),

            Image.asset(
              'assets/ic-memoria.png',
              width: 250,
              height: 200,
            ).animate().scale(duration: 1000.ms).fadeIn(duration: 1000.ms),

            Text(
                  "PPS - División A342-1",
                  style: const TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                .animate()
                .fadeIn(duration: 1500.ms)
                .slideY(begin: 1, duration: 1000.ms),
          ],
        ),
      ),
    );
  }
}
