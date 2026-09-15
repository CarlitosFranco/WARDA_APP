import 'dart:async';
import 'package:flutter/material.dart';

class BienestarScreen extends StatefulWidget {
  const BienestarScreen({super.key});

  @override
  State<BienestarScreen> createState() => _BienestarScreenState();
}

class _BienestarScreenState extends State<BienestarScreen> {
  // Estado de ánimo
  int? _selectedEmojiIndex;
  final List<String> _emojis = ['😊', '😇', '😐', '🤬', '🥵'];
  final List<String> _estados = ['Feliz', 'Tranquilo', 'Normal', 'Enojado', 'Estresado'];

  // Hábitos
  final Map<String, bool> _habitos = {
    'Dormí bien': false,
    'Hice ejercicio': false,
    'Medité': false,
  };

  // Respiración
  bool _isBreathing = false;
  int _secondsLeft = 10;
  Timer? _timer;

  // Datos del gráfico de barras
  final List<double> _diasValores = [0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 0.3];
  final List<String> _diasNombres = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  void _startBreathingExercise() {
    setState(() {
      _isBreathing = true;
      _secondsLeft = 10;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isBreathing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Ejercicio de respiración completado! 🎉')),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitosCompletados = _habitos.values.where((v) => v).length;
    final progreso = _habitos.isEmpty ? 0.0 : habitosCompletados / _habitos.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧘 BIENESTAR'),
        centerTitle: true,
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Hola, Invitado!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('¿Cómo te sientes hoy?', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),

            // Selector de Ánimo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_emojis.length, (index) {
                final isSelected = _selectedEmojiIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedEmojiIndex = index;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Registrado: Te sientes ${_estados[index]}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple.shade100 : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.deepPurple, width: 2) : null,
                    ),
                    child: Text(_emojis[index], style: const TextStyle(fontSize: 32)),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),
            const Text('--- Tu Progreso ---', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Barra de progreso
            LinearProgressIndicator(
              value: progreso,
              backgroundColor: Colors.grey.shade200,
              color: Colors.deepPurple,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progreso * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),
            const Text('📊 Estadísticas de la semana', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // GRÁFICO DE BARRAS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade100),
              ),
              child: SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(_diasValores.length, (index) {
                    final alturaMax = 90.0;
                    final alturaBarra = _diasValores[index] * alturaMax;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 18,
                          height: alturaBarra,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _diasNombres[index],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text('🧘 Respiración Guiada', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Ejercicio de Respiración
            ElevatedButton(
              onPressed: _isBreathing ? null : _startBreathingExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: Text(
                _isBreathing ? 'Inhala / Exhala... ($_secondsLeft s)' : 'Iniciar ejercicio',
              ),
            ),

            const SizedBox(height: 20),
            const Text('✅ Hábitos de hoy', style: TextStyle(fontWeight: FontWeight.bold)),

            // Checkboxes
            ..._habitos.keys.map((habito) {
              return CheckboxListTile(
                title: Text(habito),
                value: _habitos[habito],
                contentPadding: EdgeInsets.zero,
                activeColor: Colors.deepPurple,
                onChanged: (bool? value) {
                  setState(() {
                    _habitos[habito] = value ?? false;
                  });
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}