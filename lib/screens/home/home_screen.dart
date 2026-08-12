import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warda/providers/auth_provider.dart';
import 'package:warda/providers/reporte_provider.dart';
import 'package:warda/routes/app_routes.dart';
import 'package:warda/widgets/custom_button.dart';
import 'package:warda/utils/helpers.dart';
import 'package:warda/screens/reportes/reportes_screen.dart';
import 'package:warda/screens/sos/sos_screen.dart';
import 'package:warda/screens/perfil/perfil_screen.dart';
import 'package:warda/screens/mapa/mapa_screen.dart'; // ✅ NUEVA IMPORTACIÓN

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeContent(),
    ReportesScreen(),
    SosScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_outlined),
            activeIcon: Icon(Icons.report),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sos),
            activeIcon: Icon(Icons.sos),
            label: 'SOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final reporteProvider = Provider.of<ReporteProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WARDA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.notificaciones);
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // ✅ Envuelto en SingleChildScrollView
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo
            Text(
              '¡Hola, ${authProvider.usuarioActual?.nombre ?? 'Usuario'}!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '¿Cómo te sientes hoy?',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Acciones rápidas
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                // ✅ MAPA AHORA NAVEGA A LA PANTALLA DEL MAPA
                _buildQuickAction(
                  context,
                  icon: Icons.map_outlined,
                  label: 'Mapa',
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.mapa),
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.contacts_outlined,
                  label: 'Contactos',
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.contactos),
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.sos,
                  label: 'SOS',
                  color: Colors.red,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.sos),
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.report_outlined,
                  label: 'Reportes',
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.reportes),
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.favorite_outlined,
                  label: 'Bienestar',
                  color: Colors.purple,
                  onTap: () {
                    Helpers.showSnackBar(context, '💚 Funcionalidad en desarrollo');
                  },
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.psychology_outlined,
                  label: 'Mindfulness',
                  color: Colors.teal,
                  onTap: () {
                    Helpers.showSnackBar(context, '🧘 Funcionalidad en desarrollo');
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Reportes recientes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reportes recientes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.reportes);
                  },
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // ✅ Reemplazamos Expanded por SizedBox con altura fija
            reporteProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : reporteProvider.reportes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.report_off_outlined,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay reportes',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crea tu primer reporte',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: 'Crear reporte',
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.crearReporte);
                              },
                              width: 200,
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 300, // ✅ Altura fija para la lista
                        child: ListView.builder(
                          itemCount: reporteProvider.reportes.take(3).length,
                          itemBuilder: (context, index) {
                            final reporte = reporteProvider.reportes[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Helpers.getReporteColor(reporte.estado)
                                      .withOpacity(0.2),
                                  child: Icon(
                                    Icons.report,
                                    color: Helpers.getReporteColor(reporte.estado),
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  reporte.titulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${reporte.tipo} • ${Helpers.formatRelativeDate(reporte.fecha)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Helpers.getReporteColor(reporte.estado)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    reporte.estado,
                                    style: TextStyle(
                                      color: Helpers.getReporteColor(reporte.estado),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.detalle,
                                    arguments: reporte,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}