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
      backgroundColor: Color(0xFF1B2A41),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
                  "Praconovo Nicolás",
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 1500.ms)
                .slideX(begin: -1, duration: 1000.ms),

            Image.asset(
              'assets/ic-idiomas.png',
              width: 250,
              height: 200,
            ).animate().scale(duration: 1000.ms).flip(duration: 1000.ms),

            Text(
                  "PPS - División A342-1",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 1500.ms)
                .slideX(begin: 1, duration: 1000.ms),
          ],
        ),
      ),
    );
  }
}
