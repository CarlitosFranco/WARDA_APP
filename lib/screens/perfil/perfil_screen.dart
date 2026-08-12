import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warda/providers/auth_provider.dart';
import 'package:warda/routes/app_routes.dart';
import 'package:warda/widgets/custom_button.dart';
import 'package:warda/utils/helpers.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final usuario = authProvider.usuarioActual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Foto de perfil
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Nombre
            Text(
              usuario?.nombre ?? 'Usuario',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              usuario?.email ?? 'usuario@email.com',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            // Opciones de perfil
            Card(
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Editar perfil',
                    onTap: () {
                      Helpers.showSnackBar(
                          context, 'Funcionalidad en desarrollo');
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    icon: Icons.contacts_outlined,
                    title: 'Contactos de emergencia',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.contactos);
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.notificaciones);
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Privacidad y seguridad',
                    onTap: () {
                      Helpers.showSnackBar(
                          context, 'Funcionalidad en desarrollo');
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    icon: Icons.dark_mode_outlined,
                    title: 'Tema oscuro',
                    onTap: () {
                      // TODO: Implementar cambio de tema
                      Helpers.showSnackBar(
                          context, 'Funcionalidad en desarrollo');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Estadísticas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estadísticas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            label: 'Reportes',
                            value: '0',
                            icon: Icons.report,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            label: 'Días activos',
                            value: '0',
                            icon: Icons.calendar_today,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            label: 'SOS activados',
                            value: '0',
                            icon: Icons.sos,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Botón cerrar sesión
            CustomButton(
              text: 'Cerrar sesión',
              onPressed: () => _confirmarLogout(context, authProvider),
              isOutlined: true,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            // Versión
            Text(
              'Versión 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmarLogout(
      BuildContext context, AuthProvider authProvider) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      'Cerrar sesión',
      '¿Estás seguro de que quieres cerrar sesión?',
    );

    if (confirm == true) {
      await authProvider.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }
}
