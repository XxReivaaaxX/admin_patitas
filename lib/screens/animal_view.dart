import 'dart:developer';
import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/models/vacuna.dart';
import 'package:admin_patitas/screens/animal_update.dart';
import 'package:admin_patitas/screens/historial_register.dart';
import 'package:admin_patitas/screens/vacuna_register.dart';
import 'package:admin_patitas/services/historial_medico_service.dart';
import 'package:admin_patitas/services/vacuna_service.dart';
import 'package:admin_patitas/widgets/card_info_animal.dart';
import 'package:admin_patitas/widgets/text_form_register.dart';
import 'package:admin_patitas/widgets/vacuna_card.dart';
import 'package:admin_patitas/widgets/botonlogin.dart';
import 'package:flutter/material.dart';

class AnimalView extends StatefulWidget {
  final Animal animal;
  final String idRefugio;
  const AnimalView({super.key, required this.animal, required this.idRefugio});

  @override
  State<AnimalView> createState() => _AnimalViewState();
}

class _AnimalViewState extends State<AnimalView> {
  Map<String, String> infoAnimal = {};
  bool loadingVacunas = false;
  late Future<List<Vacuna>> vacunas;
  late Future<List<HistorialMedico>> historialesMedicos;
  List<Vacuna> listVacunas = [];
  List<HistorialMedico> listHistoriales = [];
  DateTime? fechaIngreso;
  Color colorPrincipal = const Color.fromRGBO(55, 148, 194, 1);

  @override
  void initState() {
    super.initState();
    vacunas = VacunaService().getVacunas(widget.idRefugio, widget.animal.id);
    historialesMedicos = HistorialMedicoService().getAllHistoriales(widget.idRefugio, widget.animal.id);
    loadVacunas();
    loadHistorial();
    try {
      fechaIngreso = DateTime.parse(widget.animal.fechaIngreso);
    } catch (_) {
      fechaIngreso = DateTime.now();
    }

    infoAnimal = {
      'Nombre': widget.animal.nombre,
      'Especie': widget.animal.especie,
      'Raza': widget.animal.raza,
      'Peso': widget.animal.peso.isNotEmpty ? '${widget.animal.peso} Kg' : 'No registrado',
      'Color/Señas': widget.animal.colorSenas.isNotEmpty ? widget.animal.colorSenas : 'No registrado',
      'Género': widget.animal.genero,
      'Estado de Adopción': widget.animal.estadoAdopcion,
      'Salud': widget.animal.estadoSalud,
      'Fecha Ingreso': fechaIngreso != null
          ? '${fechaIngreso!.day}/${fechaIngreso!.month}/${fechaIngreso!.year}'
          : 'sin datos',
    };
  }

  Widget _buildAnimalImage() {
    final imageUrl = widget.animal.imageUrl;
    return imageUrl.isNotEmpty
        ? (imageUrl.startsWith('data:image')
            ? Image.memory(
                Uri.parse(imageUrl).data!.contentAsBytes(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
              ))
        : _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.pets, size: 80, color: Colors.grey),
    );
  }

  Future<void> loadVacunas() async {
    if (!mounted) return;
    setState(() => loadingVacunas = true);
    try {
      final results = await VacunaService().getVacunas(widget.idRefugio, widget.animal.id);
      if (mounted) {
        setState(() {
          listVacunas = results;
          loadingVacunas = false;
        });
      }
    } catch (e) {
      log('Error al cargar vacunas $e');
      if (mounted) setState(() => loadingVacunas = false);
    }
  }

  Future<void> loadHistorial() async {
    try {
      final data = await HistorialMedicoService().getAllHistoriales(widget.idRefugio, widget.animal.id);
      if (mounted) {
        setState(() {
          listHistoriales = data;
        });
      }
    } catch (e) {
      log('Error al cargar historial: $e');
    }
  }

  Widget getMovil() {
    return Container(
      color: Colors.grey[100],
      child: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Column(
          children: [
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(14)),
                child: _buildAnimalImage(),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar.secondary(
                tabAlignment: TabAlignment.center,
                isScrollable: true,
                labelPadding: const EdgeInsets.symmetric(horizontal: 40),
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 40),
                tabs: const <Widget>[
                  Tab(text: 'Datos generales'),
                  Tab(text: 'Historial médico'),
                  Tab(text: 'Vacunas'),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                  color: Colors.white,
                ),
                child: TabBarView(
                  children: <Widget>[
                    _buildGeneralDataTab(),
                    _buildHistorialTab(),
                    _buildVacunasTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralDataTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: IconButton(
            icon: const Icon(Icons.settings, color: Colors.blueAccent),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnimalUpdate(
                    idRefugio: widget.idRefugio,
                    animal: widget.animal,
                  ),
                ),
              );
              if (mounted) setState(() {});
            },
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: CardInfoAnimal(datos: infoAnimal),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorialTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: BotonLogin(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistorialRegister(
                    nombre: widget.animal.nombre,
                    idAnimal: widget.animal.id,
                    idRefugio: widget.idRefugio,
                  ),
                ),
              );
              if (result != null) {
                await loadHistorial();
              }
            },
            texto: 'Añadir Seguimiento',
            color: Colors.white,
            colorB: colorPrincipal,
            size: 14,
            negrita: FontWeight.bold,
          ),
        ),
        Expanded(
          child: listHistoriales.isEmpty
              ? const Center(child: Text('No hay seguimientos registrados'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listHistoriales.length,
                  itemBuilder: (context, index) {
                    final h = listHistoriales[index];
                    String formattedDate = h.fechaRevision;
                    try {
                      final date = DateTime.parse(h.fechaRevision);
                      formattedDate = '${date.day}/${date.month}/${date.year}';
                    } catch (_) {}

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorPrincipal.withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Revisión: $formattedDate',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: colorPrincipal),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HistorialRegister(
                                          nombre: widget.animal.nombre,
                                          idAnimal: widget.animal.id,
                                          idRefugio: widget.idRefugio,
                                          initialHistorial: h,
                                        ),
                                      ),
                                    );
                                    if (result != null) {
                                      await loadHistorial();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildHistorialRow(Icons.monitor_weight, 'Peso', '${h.peso} Kg'),
                                const Divider(),
                                _buildHistorialRow(Icons.health_and_safety, 'Castrado', h.castrado),
                                const Divider(),
                                _buildHistorialRow(Icons.bug_report, 'Enfermedades', h.enfermedades.isEmpty ? 'Ninguna' : h.enfermedades),
                                const Divider(),
                                _buildHistorialRow(Icons.medication, 'Tratamiento', h.tratamiento.isEmpty ? 'Ninguno' : h.tratamiento),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHistorialRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: TextStyle(color: Colors.grey[800]))),
        ],
      ),
    );
  }

  Widget _buildVacunasTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.greenAccent, size: 30),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VacunaRegister(
                        refugioId: widget.idRefugio,
                        animalId: widget.animal.id,
                        animalNombre: widget.animal.nombre,
                        animalEspecie: widget.animal.especie,
                      ),
                    ),
                  );
                  if (result == true && mounted) {
                    loadVacunas();
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: loadingVacunas
              ? const Center(child: CircularProgressIndicator())
              : listVacunas.isEmpty
                  ? const Center(child: Text('No hay vacunas registradas'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: listVacunas.length,
                      itemBuilder: (context, index) {
                        final vacuna = listVacunas[index];
                        return VacunaCard(
                          vacuna: vacuna,
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Confirmar eliminación'),
                                content: Text('¿Eliminar vacuna "${vacuna.nombre}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext, true),
                                    child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                await VacunaService().deleteVacuna(widget.idRefugio, widget.animal.id, vacuna.id);
                                loadVacunas();
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                }
                              }
                            }
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget getWeb() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(50),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildAnimalImage(),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                flex: 2,
                child: CardInfoAnimal(datos: infoAnimal),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SizedBox(height: 500, child: _buildHistorialTab())),
              const SizedBox(width: 40),
              Expanded(child: SizedBox(height: 500, child: _buildVacunasTab())),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorPrincipal),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        title: TextForm(
          aling: TextAlign.center,
          texto: widget.animal.nombre,
          size: 24,
          color: colorPrincipal,
          lines: 1,
          negrita: FontWeight.bold,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 1000) {
            return getMovil();
          } else {
            return getWeb();
          }
        },
      ),
    );
  }
}
