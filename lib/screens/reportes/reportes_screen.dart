import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warda/providers/reporte_provider.dart';
import 'package:warda/routes/app_routes.dart';
import 'package:warda/utils/helpers.dart';
import 'package:warda/widgets/custom_button.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Usamos addPostFrameCallback para cargar después del primer build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarReportes();
    });
  }

  Future<void> _cargarReportes() async {
    final provider = Provider.of<ReporteProvider>(context, listen: false);
    // TODO: Usar ID del usuario autenticado en lugar de 'invitado'
    await provider.cargarReportes('invitado');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reporteProvider = Provider.of<ReporteProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reportes'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.crearReporte);
            },
            tooltip: 'Nuevo reporte',
          ),
        ],
      ),
      body: reporteProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reporteProvider.reportes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.report_off_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes reportes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crea tu primer reporte de incidente',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 24),
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
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reporteProvider.reportes.length,
                  itemBuilder: (context, index) {
                    final reporte = reporteProvider.reportes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
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
                          style: const TextStyle(fontWeight: FontWeight.w600),
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
    );
  }
}