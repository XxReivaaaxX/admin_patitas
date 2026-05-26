import 'dart:developer';

import 'package:admin_patitas/screens/adopcionesScreen/adopcion_screen_mobile.dart';

import 'package:admin_patitas/screens/adopcionesScreen/solicitud_screen_mobile.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/utils/state_tab.dart';
import 'package:admin_patitas/widgets/estado_badge.dart';
import 'package:admin_patitas/services/solicitud_adopcion_service.dart';
import 'package:flutter/material.dart';

class AdopcionesMenu extends StatefulWidget {
  final int initialTab;
  const AdopcionesMenu({super.key, this.initialTab = 0});

  @override
  State<AdopcionesMenu> createState() => _AdopcionesMenuState();
}

class _AdopcionesMenuState extends State<AdopcionesMenu> {
  String? id_refugio;
  String refugioNombre = "Refugio";
  bool _isLoading = true;
  final SolicitudAdopcionService _service = SolicitudAdopcionService();

  List<Map<String, dynamic>> _todasLasSolicitudes = [];
  Map<String, List<Map<String, dynamic>>> _porAnimal = {};

  //final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);
  late final ValueNotifier<int> _selectedIndexNotifier;

  @override
  void initState() {
    super.initState();
    id_refugio = PreferencesController.preferences.getString('refugio');
    log('id_refugio cargado: $id_refugio', name: 'AdopcionesMenu');
    log(
      'Todas las keys guardadas: ${PreferencesController.preferences.getKeys()}',
      name: 'AdopcionesMenu',
    );
    _selectedIndexNotifier = ValueNotifier<int>(widget.initialTab);

    _loadSolicitudes();
  }

  Future<void> _loadSolicitudes() async {
    setState(() => _isLoading = true);
    try {
      final solicitudes = await _service.getSolicitudesByRefugio(id_refugio!);

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
        refugioId: id_refugio!,
        animalId: solicitud['animalId'],
        correo: solicitud['correo'],
        estado: nuevoEstado,
        refugioNombre: refugioNombre,
        nombreAdoptante: solicitud['nombre'],
        animalNombre: solicitud['animalNombre'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nuevoEstado == 'aprobado'
                  ? 'Solicitud aprobada correctamente'
                  : 'Solicitud rechazada',
            ),
            backgroundColor: nuevoEstado == 'aprobado'
                ? Colors.green
                : Colors.red.shade400,
          ),
        );
        _loadSolicitudes(); // Refrescar
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
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

  Widget menuMobile() {
    return DefaultTabController(
      initialIndex: widget.initialTab,
      length: 2,
      child: Builder(
        builder: (context) {
          // Escucha cambios de tab
          TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              showFabNotifier.value = tabController.index == 0;
            }
          });

          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: TabBar.secondary(
              isScrollable: true,
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
              unselectedLabelColor: Colors.black,
              tabAlignment: TabAlignment.center,
              tabs: <Widget>[
                Tab(text: "Animales en adopcion"),
                Tab(text: "Solicitudes"),
              ],
            ),
            body: TabBarView(
              children: <Widget>[
                AdopcionScreenMobile(
                  porAnimal: _porAnimal,
                  onRefresh: _loadSolicitudes,
                  onMostrarDetalle: _mostrarDetalle,
                  refugio: id_refugio,
                ),
                SolicitudScreenMobile(
                  todasLasSolicitudes: _todasLasSolicitudes,
                  onRefresh: _loadSolicitudes,
                  onMostrarDetalle: _mostrarDetalle,
                  refugio: id_refugio,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget menuWeb() {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedIndexNotifier,
      builder: (context, selectedIndex, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showFabNotifier.value = selectedIndex == 0;
        });

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // items del menu lateral
              Container(
                height: 200,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),

                child: NavigationRail(
                  extended: true,
                  backgroundColor: Colors.white,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    _selectedIndexNotifier.value = index;
                  },

                  selectedIconTheme: IconThemeData(color: Colors.white),
                  unselectedIconTheme: IconThemeData(color: Colors.black),
                  indicatorColor: AppColors.primary,
                  selectedLabelTextStyle: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),

                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.pets_outlined),
                      selectedIcon: Icon(Icons.pets_rounded),
                      label: Text('Animales en adopcion'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.description),
                      selectedIcon: Icon(Icons.description_outlined),
                      label: Text('Solicitudes'),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24),

              //  Contenido del menu
              Expanded(
                child: IndexedStack(
                  index: selectedIndex,
                  children: [
                    AdopcionScreenMobile(
                      porAnimal: _porAnimal,
                      onRefresh: _loadSolicitudes,
                      onMostrarDetalle: _mostrarDetalle,
                      refugio: id_refugio,
                    ),
                    SolicitudScreenMobile(
                      todasLasSolicitudes: _todasLasSolicitudes,
                      onRefresh: _loadSolicitudes,
                      onMostrarDetalle: _mostrarDetalle,
                      refugio: id_refugio,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (id_refugio == null || id_refugio!.isEmpty) {
      return const Center(
        child: Text("Error: No se encontró el ID del refugio"),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return menuMobile();
        } else {
          return Container(
            color: AppColors.backgroundLight,
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
            child: menuWeb(),
          );
        }
      },
    );
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
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.75),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.assignment_ind,
                    color: Colors.white,
                    size: 28,
                  ),
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
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  EstadoBadge(estado: estado, light: true),
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
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Nombre',
                      value: nombre,
                    ),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Correo',
                      value: correo,
                    ),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Teléfono',
                      value: telefono,
                    ),
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
                        label: const Text(
                          'Rechazar',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAprobar,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'Aprobar',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

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
