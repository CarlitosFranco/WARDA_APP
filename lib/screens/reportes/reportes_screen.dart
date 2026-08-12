import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warda/providers/auth_provider.dart';
import 'package:warda/providers/reporte_provider.dart';
import 'package:warda/routes/app_routes.dart';
import 'package:warda/widgets/custom_button.dart';
import 'package:warda/utils/helpers.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reporteProvider = Provider.of<ReporteProvider>(context, listen: false);
    
    if (authProvider.usuarioActual != null) {
      await reporteProvider.cargarReportes(authProvider.usuarioActual!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reporteProvider = Provider.of<ReporteProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.crearReporte);
            },
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
                        'No hay reportes',
                        style: theme.textTheme.headlineSmall?.copyWith(
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
                          ),
                        ),
                        title: Text(
                          reporte.titulo,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reporte.tipo,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              Helpers.formatRelativeDate(reporte.fecha),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Helpers.getReporteColor(reporte.estado)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            reporte.estado,
                            style: TextStyle(
                              color: Helpers.getReporteColor(reporte.estado),
                              fontSize: 11,
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