import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warda/services/location_service.dart';
import 'package:warda/providers/usuario_provider.dart';
import 'package:warda/utils/helpers.dart';
import 'package:warda/widgets/custom_button.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isSosActivated = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergencia SOS'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade900,
              Colors.red.shade700,
              Colors.red.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¡ACTIVA EL BOTÓN DE EMERGENCIA!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tus contactos de emergencia serán notificados\ncon tu ubicación en tiempo real',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: _activarSos,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isSosActivated ? Icons.emergency : Icons.sos,
                                  size: 80,
                                  color: _isSosActivated ? Colors.red : Colors.red.shade700,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isSosActivated ? 'ACTIVADO' : 'TOCA PARA SOS',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _isSosActivated ? Colors.red : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
                if (_isSosActivated) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Enviando ubicación...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'CANCELAR SOS',
                          onPressed: _desactivarSos,
                          isOutlined: true,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (!_isSosActivated)
                  Text(
                    'Solo usa esta función en caso de EMERGENCIA REAL',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 📤 ENVIAR ALERTA A CONTACTOS
  // ============================================================
  Future<void> _enviarAlertaContactos(double lat, double lng) async {
    final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
    final contactos = usuarioProvider.getContactos();

    if (contactos.isEmpty) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          '⚠️ No tienes contactos de emergencia. Agrega uno en "Contactos"',
          color: Colors.orange,
        );
      }
      return;
    }

    final mapsUrl = 'https://maps.google.com/?q=$lat,$lng';
    final mensaje = '🚨 ¡EMERGENCIA! Necesito ayuda. Mi ubicación actual es: $mapsUrl';

    for (var contacto in contactos) {
      final telefono = contacto.telefono.replaceAll(RegExp(r'[^0-9]'), '');
      final whatsappUrl = 'https://wa.me/51$telefono?text=${Uri.encodeComponent(mensaje)}';

      try {
        if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
          await launchUrl(Uri.parse(whatsappUrl));
          break; // Si se abre WhatsApp, no abrir SMS para el mismo contacto
        } else {
          final smsUrl = 'sms:$telefono?body=${Uri.encodeComponent(mensaje)}';
          if (await canLaunchUrl(Uri.parse(smsUrl))) {
            await launchUrl(Uri.parse(smsUrl));
          } else {
            if (mounted) {
              Helpers.showSnackBar(
                context,
                '❌ No se puede enviar mensaje a ${contacto.nombre}',
                color: Colors.red,
              );
            }
          }
        }
      } catch (e) {
        print('Error enviando alerta a ${contacto.nombre}: $e');
        if (mounted) {
          Helpers.showSnackBar(
            context,
            '❌ Error al enviar alerta a ${contacto.nombre}',
            color: Colors.red,
          );
        }
      }
    }
  }

  // ============================================================
  // 🔴 ACTIVAR SOS
  // ============================================================
  Future<void> _activarSos() async {
    setState(() => _isSosActivated = true);

    final position = await LocationService.getCurrentLocation();

    if (position != null) {
      final lat = position.latitude;
      final lng = position.longitude;
      print('📍 Ubicación: $lat, $lng');

      await _enviarAlertaContactos(lat, lng);

      if (mounted) {
        Helpers.showSnackBar(
          context,
          '📨 Alertas enviadas a tus contactos de emergencia',
          color: Colors.green,
        );
      }
    } else {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          '⚠️ No se pudo obtener la ubicación. Verifica tu GPS y permisos.',
          color: Colors.orange,
        );
      }
    }
  }

  // ============================================================
  // ⏹️ DESACTIVAR SOS
  // ============================================================
  void _desactivarSos() {
    setState(() => _isSosActivated = false);
    Helpers.showSnackBar(
      context,
      'SOS desactivado',
      color: Colors.grey,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}