import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warda/providers/auth_provider.dart';      // ✅ Importación necesaria
import 'package:warda/providers/usuario_provider.dart';
import 'package:warda/utils/helpers.dart';

class ContactosScreen extends StatefulWidget {
  const ContactosScreen({super.key});

  @override
  State<ContactosScreen> createState() => _ContactosScreenState();
}

class _ContactosScreenState extends State<ContactosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _relacionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final contactos = usuarioProvider.getContactos();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos de Emergencia'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarDialogoAgregar(context, usuarioProvider),
            tooltip: 'Agregar contacto',
          ),
        ],
      ),
      body: usuarioProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : contactos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.contacts_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes contactos de emergencia',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agrega a tus personas de confianza',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _mostrarDialogoAgregar(context, usuarioProvider),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar contacto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: contactos.length,
                  itemBuilder: (context, index) {
                    final contacto = contactos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Text(
                            contacto.nombre.isNotEmpty
                                ? contacto.nombre[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          contacto.nombre,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📞 ${contacto.telefono}'),
                            Text(
                              '👤 ${contacto.relacion}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmarEliminar(
                            context,
                            usuarioProvider,
                            contacto.id,
                            contacto.nombre,
                          ),
                          tooltip: 'Eliminar contacto',
                        ),
                        onTap: () {
                          Helpers.showSnackBar(
                            context,
                            '📝 Editar funcionalidad en desarrollo',
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogoAgregar(context, usuarioProvider),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo contacto'),
      ),
    );
  }

  void _mostrarDialogoAgregar(BuildContext context, UsuarioProvider provider) {
    _nombreController.clear();
    _telefonoController.clear();
    _relacionController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Agregar contacto de emergencia'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el teléfono';
                  }
                  if (value.trim().length < 9) {
                    return 'Teléfono inválido (mínimo 9 dígitos)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _relacionController,
                decoration: const InputDecoration(
                  labelText: 'Relación (ej. Madre, Hermano, Amigo)',
                  prefixIcon: Icon(Icons.family_restroom_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa la relación';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _agregarContacto(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _agregarContacto(BuildContext context, UsuarioProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ AHORA SÍ RECONOCE AuthProvider POR LA IMPORTACIÓN
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final usuarioId = authProvider.usuarioActual?.id ?? 'invitado_${DateTime.now().millisecondsSinceEpoch}';

    final success = await provider.agregarContactoEmergencia(
      usuarioId,
      _nombreController.text.trim(),
      _telefonoController.text.trim(),
      _relacionController.text.trim(),
    );

    if (context.mounted) {
      Navigator.pop(context);
      if (success) {
        Helpers.showSnackBar(
          context,
          '✅ Contacto agregado correctamente',
          color: Colors.green,
        );
      } else {
        Helpers.showSnackBar(
          context,
          '❌ Error al agregar contacto: ${provider.error}',
          color: Colors.red,
        );
      }
    }
  }

  void _confirmarEliminar(
    BuildContext context,
    UsuarioProvider provider,
    String contactoId,
    String nombre,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar contacto'),
        content: Text('¿Estás seguro de eliminar a "$nombre" de tus contactos de emergencia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.eliminarContactoEmergencia(contactoId);
              if (context.mounted) {
                if (success) {
                  Helpers.showSnackBar(
                    context,
                    '🗑️ Contacto eliminado',
                    color: Colors.orange,
                  );
                } else {
                  Helpers.showSnackBar(
                    context,
                    '❌ Error al eliminar contacto',
                    color: Colors.red,
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _relacionController.dispose();
    super.dispose();
  }
}