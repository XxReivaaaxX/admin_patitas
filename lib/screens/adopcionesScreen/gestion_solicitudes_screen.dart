import 'dart:developer';
import 'package:admin_patitas/services/solicitud_adopcion_service.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:flutter/material.dart';

/// Panel de gestión de solicitudes de adopción para el administrador del refugio.
/// Se divide en dos vistas:
///   [0] Por animal   – todos los animales con solicitudes recibidas
///   [1] Todas        – todas las solicitudes del refugio listadas individualmente
class GestionSolicitudesScreen extends StatefulWidget {
  final String refugioId;
  final String refugioNombre;

  const GestionSolicitudesScreen({
    super.key,
    required this.refugioId,
    required this.refugioNombre,
  });

  @override
  State<GestionSolicitudesScreen> createState() =>
      _GestionSolicitudesScreenState();
}

class _GestionSolicitudesScreenState extends State<GestionSolicitudesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final SolicitudAdopcionService _service = SolicitudAdopcionService();

  List<Map<String, dynamic>> _todasLasSolicitudes = [];
  Map<String, List<Map<String, dynamic>>> _porAnimal = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSolicitudes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSolicitudes() async {
    setState(() => _isLoading = true);
    try {
      final solicitudes =
          await _service.getSolicitudesByRefugio(widget.refugioId);

      // Agrupar por animal
      final Map<String, List<Map<String, dynamic>>> agrupadas = {};
      for (final s in solicitudes) {
        final animalId = s['animalId'] as String? ?? 'Sin animal';
        agrupadas.putIfAbsent(animalId, () => []).add(s);
      }

      if (mounted) {
        setState(() {
          _todasLasSolicitudes = solicitudes;
          _porAnimal = agrupadas;
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error cargando solicitudes: $e', name: 'GestionSolicitudes');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Actualizar estado (aprobar / rechazar) ────────────────────────────────
  Future<void> _actualizarEstado(
    Map<String, dynamic> solicitud,
    String nuevoEstado,
  ) async {
    try {
      await _service.actualizarEstado(
        refugioId: widget.refugioId,
        animalId: solicitud['animalId'],
        correo: solicitud['correo'],
        estado: nuevoEstado,
        refugioNombre: widget.refugioNombre,
        nombreAdoptante: solicitud['nombre'],
        animalNombre: solicitud['animalNombre'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nuevoEstado == 'aprobado'
                  ? '✅ Solicitud aprobada correctamente'
                  : '❌ Solicitud rechazada',
            ),
            backgroundColor:
                nuevoEstado == 'aprobado' ? Colors.green : Colors.red.shade400,
          ),
        );
        _loadSolicitudes(); // Refrescar
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  // ─── Mostrar modal con detalle de la solicitud ────────────────────────────
  void _mostrarDetalle(Map<String, dynamic> solicitud) {
    showDialog(
      context: context,
      builder: (ctx) => _DetalleSolicitudDialog(
        solicitud: solicitud,
        onAprobar: solicitud['estado'] == 'pendiente'
            ? () {
                Navigator.pop(ctx);
                _actualizarEstado(solicitud, 'aprobado');
              }
            : null,
        onRechazar: solicitud['estado'] == 'pendiente'
            ? () {
                Navigator.pop(ctx);
                _actualizarEstado(solicitud, 'rechazado');
              }
            : null,
      ),
    );
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tabs ──────────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(icon: Icon(Icons.pets), text: 'Por Animal'),
              Tab(icon: Icon(Icons.list_alt), text: 'Todas las Solicitudes'),
            ],
          ),
        ),

        // ── Contenido ─────────────────────────────────────────────────────
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPorAnimalTab(),
                    _buildTodasTab(),
                  ],
                ),
        ),
      ],
    );
  }

  // ─── Vista 1: Por Animal ──────────────────────────────────────────────────
  Widget _buildPorAnimalTab() {
    if (_porAnimal.isEmpty) {
      return _buildEmptyState(
        icon: Icons.pets_outlined,
        mensaje: 'Aún no hay solicitudes de adopción',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSolicitudes,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: _porAnimal.entries.map((entry) {
          final solicitudes = entry.value;
          final animalNombre =
              solicitudes.first['animalNombre'] as String? ?? entry.key;

          final pendientes =
              solicitudes.where((s) => s['estado'] == 'pendiente').length;
          final aprobadas =
              solicitudes.where((s) => s['estado'] == 'aprobado').length;
          final rechazadas =
              solicitudes.where((s) => s['estado'] == 'rechazado').length;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: ExpansionTile(
              shape: const Border(),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child:
                    const Icon(Icons.pets, color: AppColors.primary, size: 20),
              ),
              title: Text(
                animalNombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
              subtitle: Wrap(
                spacing: 6,
                children: [
                  if (pendientes > 0)
                    _MiniChip(
                        label: '$pendientes pendiente${pendientes > 1 ? 's' : ''}',
                        color: Colors.orange),
                  if (aprobadas > 0)
                    _MiniChip(
                        label: '$aprobadas aprobada${aprobadas > 1 ? 's' : ''}',
                        color: Colors.green),
                  if (rechazadas > 0)
                    _MiniChip(
                        label:
                            '$rechazadas rechazada${rechazadas > 1 ? 's' : ''}',
                        color: Colors.red),
                ],
              ),
              children: solicitudes
                  .map((s) => _SolicitudTile(
                        solicitud: s,
                        onTap: () => _mostrarDetalle(s),
                      ))
                  .toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Vista 2: Todas las Solicitudes ───────────────────────────────────────
  Widget _buildTodasTab() {
    if (_todasLasSolicitudes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        mensaje: 'No hay solicitudes registradas todavía',
      );
    }

    // Ordenar: pendientes primero
    final ordenadas = List<Map<String, dynamic>>.from(_todasLasSolicitudes)
      ..sort((a, b) {
        const orden = {'pendiente': 0, 'aprobado': 1, 'rechazado': 2};
        return (orden[a['estado']] ?? 3).compareTo(orden[b['estado']] ?? 3);
      });

    return RefreshIndicator(
      onRefresh: _loadSolicitudes,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ordenadas.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _SolicitudTile(
            solicitud: ordenadas[i],
            onTap: () => _mostrarDetalle(ordenadas[i]),
            showAnimalName: true,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String mensaje}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _loadSolicitudes,
            icon: const Icon(Icons.refresh),
            label: const Text('Refrescar'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Tile de solicitud (compacto, usado en ambas vistas)
// ─────────────────────────────────────────────────────────────────────────────
class _SolicitudTile extends StatelessWidget {
  final Map<String, dynamic> solicitud;
  final VoidCallback onTap;
  final bool showAnimalName;

  const _SolicitudTile({
    required this.solicitud,
    required this.onTap,
    this.showAnimalName = false,
  });

  @override
  Widget build(BuildContext context) {
    final estado = solicitud['estado'] as String? ?? 'pendiente';
    final nombre = solicitud['nombre'] as String? ?? '—';
    final correo = solicitud['correo'] as String? ?? '—';
    final animalNombre = solicitud['animalNombre'] as String? ?? '—';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar estado
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _estadoColor(estado).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _estadoIcon(estado),
                  color: _estadoColor(estado),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      correo,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                    if (showAnimalName)
                      Text(
                        'Para: $animalNombre',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              // Badge estado
              _EstadoBadge(estado: estado),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'aprobado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _estadoIcon(String estado) {
    switch (estado) {
      case 'aprobado':
        return Icons.check_circle_outline;
      case 'rechazado':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Modal de detalle de solicitud
// ─────────────────────────────────────────────────────────────────────────────
class _DetalleSolicitudDialog extends StatelessWidget {
  final Map<String, dynamic> solicitud;
  final VoidCallback? onAprobar;
  final VoidCallback? onRechazar;

  const _DetalleSolicitudDialog({
    required this.solicitud,
    this.onAprobar,
    this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    final estado = solicitud['estado'] as String? ?? 'pendiente';
    final nombre = solicitud['nombre'] as String? ?? '—';
    final correo = solicitud['correo'] as String? ?? '—';
    final telefono = solicitud['telefono'] as String? ?? '—';
    final animalNombre = solicitud['animalNombre'] as String? ?? '—';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.assignment_ind, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Solicitud para: $animalNombre',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  _EstadoBadge(estado: estado, light: true),
                ],
              ),
            ),

            // ── Cuerpo scrollable ────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Datos personales
                    _Section(title: 'Datos de Contacto'),
                    _InfoRow(icon: Icons.badge_outlined, label: 'Nombre', value: nombre),
                    _InfoRow(icon: Icons.email_outlined, label: 'Correo', value: correo),
                    _InfoRow(icon: Icons.phone_outlined, label: 'Teléfono', value: telefono),
                    const SizedBox(height: 16),

                    // Preguntas de filtro
                    _Section(title: 'Respuestas del Formulario'),
                    _InfoRow(
                      icon: Icons.history_edu_outlined,
                      label: 'Experiencia previa con mascotas',
                      value: _boolToSiNo(solicitud['experienciaPrevia']),
                    ),
                    _InfoRow(
                      icon: Icons.home_outlined,
                      label: 'Tipo de vivienda',
                      value: solicitud['tipoVivienda']?.toString() ?? '—',
                    ),
                    _InfoRow(
                      icon: Icons.child_care_outlined,
                      label: 'Tiene niños en casa',
                      value: _boolToSiNo(solicitud['tieneNinos']),
                    ),
                    if (solicitud['tieneNinos'] == true &&
                        (solicitud['edadesNinos'] ?? '').toString().isNotEmpty)
                      _InfoRow(
                        icon: Icons.family_restroom,
                        label: 'Edades de los niños',
                        value: solicitud['edadesNinos'].toString(),
                      ),
                    _InfoRow(
                      icon: Icons.pets_outlined,
                      label: 'Tiene otras mascotas',
                      value: _boolToSiNo(solicitud['otrasMascotas']),
                    ),
                    _InfoRow(
                      icon: Icons.schedule_outlined,
                      label: 'Horas solo al día',
                      value: solicitud['horasSolo']?.toString() ?? '—',
                    ),
                    _InfoRow(
                      icon: Icons.local_hospital_outlined,
                      label: 'Puede costear gastos veterinarios',
                      value: _boolToSiNo(solicitud['puedeCostearVet']),
                    ),
                  ],
                ),
              ),
            ),

            // ── Acciones ────────────────────────────────────────────────
            if (estado == 'pendiente') ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRechazar,
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text('Rechazar',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAprobar,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text('Aprobar',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _boolToSiNo(dynamic value) {
    if (value == true) return 'Sí';
    if (value == false) return 'No';
    return '—';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────────────────────────────────────────

class _EstadoBadge extends StatelessWidget {
  final String estado;
  final bool light;
  const _EstadoBadge({required this.estado, this.light = false});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (estado) {
      case 'aprobado':
        color = Colors.green;
        label = 'Aprobado';
        break;
      case 'rechazado':
        color = Colors.red;
        label = 'Rechazado';
        break;
      default:
        color = Colors.orange;
        label = 'Pendiente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: light ? Colors.white.withValues(alpha: 0.2) : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: light ? Colors.white54 : color.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: light ? Colors.white : color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
