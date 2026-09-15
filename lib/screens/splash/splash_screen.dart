import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warda/providers/auth_provider.dart';
import 'package:warda/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();

    // ✅ Controlador de animación para los puntitos
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // ✅ Usamos addPostFrameCallback para no usar context en initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarSesion();
    });
  }

  Future<void> _verificarSesion() async {
    // Esperar 2.5 segundos para mostrar el splash
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ LOGO DE WARDA (tarjeta blanca con bordes redondeados)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.health_and_safety,
                        size: 100,
                        color: theme.colorScheme.primary,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // ✅ INDICADOR DE CARGA PERSONALIZADO (3 puntitos rebotando)
              _buildBouncingDots(),
              const SizedBox(height: 16),

              // MENSAJE
              Text(
                'Cargando...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🔵 INDICADOR DE CARGA PERSONALIZADO (3 puntitos rebotando)
  // ============================================================
  Widget _buildBouncingDots() {
    // Colores de WARDA (naranja, rojo, azul)
    const colors = [
      Color(0xFFF59E0B), // Naranja
      Color(0xFFEF4444), // Rojo
      Color(0xFF60A5FA), // Azul claro
    ];

    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            // Desfase para cada punto (efecto ola)
            final delay = index * 0.2;
            final progress = (_dotsController.value - delay) % 1.0;

            // Animación de rebote (sube y baja)
            final bounce = progress < 0.5
                ? (progress * 2)
                : (1 - (progress - 0.5) * 2);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Transform.translate(
                offset: Offset(0, -bounce * 15),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors[index].withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: bounce * 3,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}