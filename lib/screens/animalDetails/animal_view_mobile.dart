import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/models/historial_medico.dart';
import 'package:admin_patitas/models/vacuna.dart';
import 'package:admin_patitas/screens/animal_update.dart';
import 'package:admin_patitas/screens/historial_register.dart';
import 'package:admin_patitas/screens/vacuna_register.dart';
import 'package:admin_patitas/services/historial_medico_service.dart';
import 'package:admin_patitas/services/vacuna_service.dart';
import 'package:admin_patitas/widgets/card_info_animal.dart';
import 'package:admin_patitas/widgets/card_info_historial.dart';
import 'package:admin_patitas/widgets/custom_icon_button.dart';
import 'package:admin_patitas/widgets/vacuna_card.dart';
import 'package:flutter/material.dart';

class AnimalViewMobile extends StatelessWidget {
  final Animal animal;
  final Map<String, String> infoAnimal;
  final String? idRefugio;
  final String idHistorial;
  final Future<HistorialMedico>? historialMedico;
  final List<Vacuna> vacunas;
  final bool loadingVacunas;
  final Future<void> Function() loadVacunas;
  final void Function(
    String newIdHistorial,
    Future<HistorialMedico> futureHistorial,
  )
  onHistorialCreated;
  final void Function(Animal updatedAnimal) onAnimalUpdated;

  const AnimalViewMobile({
    super.key,
    required this.animal,
    required this.infoAnimal,
    required this.idRefugio,
    required this.idHistorial,
    required this.historialMedico,
    required this.vacunas,
    required this.loadingVacunas,
    required this.loadVacunas,
    required this.onHistorialCreated,
    required this.onAnimalUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.grey[100],
      child: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // imegen del animal
              SliverToBoxAdapter(
                child: Container(
                  height: screenHeight * 0.25,
                  margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: animal.imageUrl.isNotEmpty
                        ? (animal.imageUrl.startsWith('data:image')
                              ? Image.memory(
                                  Uri.parse(
                                    animal.imageUrl,
                                  ).data!.contentAsBytes(),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: Colors.grey[200],
                                        width: double.infinity,
                                        child: Icon(
                                          Icons.pets,
                                          size: 50,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                )
                              : Image.network(
                                  animal.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: Colors.grey[200],
                                        width: double.infinity,
                                        child: Icon(
                                          Icons.pets,
                                          size: 50,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                ))
                        : Container(
                            color: Colors.grey[200],
                            width: double.infinity,
                            child: Icon(
                              Icons.pets,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                ),
              ),
              // tab bar que se mantiene fijo
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  Container(
                    color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: const TabBar.secondary(
                      tabAlignment: TabAlignment.center,
                      isScrollable: true,
                      labelPadding: EdgeInsets.symmetric(horizontal: 40),
                      indicatorPadding: EdgeInsets.symmetric(horizontal: 40),
                      tabs: [
                        Tab(text: 'Datos generales'),
                        Tab(text: 'Historial médico'),
                        Tab(text: 'Vacunas'),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },

          body: Container(
            margin: const EdgeInsets.fromLTRB(20, 15, 20, 10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: const [
                BoxShadow(
                  blurStyle: BlurStyle.outer,
                  color: Colors.grey,
                  blurRadius: 2,
                ),
              ],
              color: Colors.white,
            ),
            //secciones del menu
            child: TabBarView(
              children: [
                // datos generales del animal
                SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              animal.nombre,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          CustomIconButton(
                            icono: Icons.settings,
                            texto: "Actualizar datos",
                            onTap: () async {
                              final res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AnimalUpdate(
                                    id_refugio: idRefugio,
                                    animal: animal,
                                    isMobile: true,
                                  ),
                                ),
                              );
                              if (res != null) {
                                onAnimalUpdated(res);
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      CardInfoAnimal(
                        datos: infoAnimal,
                        division: screenWidth > 600 ? 3 : 2,
                      ),
                    ],
                  ),
                ),

                // historial medico
                if (idHistorial == '') ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Crear historial médico'),
                        onPressed: () async {
                          final historialRes = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistorialRegister(
                                nombre: animal.nombre,
                                id_animal: animal.id,
                                id_refugio: idRefugio,
                              ),
                            ),
                          );
                          if (historialRes != null && historialRes != '') {
                            onHistorialCreated(
                              historialRes,
                              HistorialMedicoService().getHistorialMedico(
                                historialRes,
                              ),
                            );
                          }
                        },
                      ),
                      const Text('No hay historial médico.'),
                    ],
                  ),
                ] else ...[
                  FutureBuilder<HistorialMedico>(
                    future: historialMedico,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SingleChildScrollView(
                          child: CardInfoHistorial(
                            historialMedico: snapshot.requireData,
                            nombre: animal.nombre,
                            isMobile: true,
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ],

                // vacunas
                Column(
                  children: [
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.centerRight,

                      child: CustomIconButton(
                        icono: Icons.add,
                        texto: "Nueva Vacuna",
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VacunaRegister(
                                refugioId: idRefugio!,
                                animalId: animal.id,
                                animalNombre: animal.nombre,
                                animalEspecie: animal.especie,
                              ),
                            ),
                          );
                          if (result == true) loadVacunas();
                        },
                      ),
                    ),
                    Expanded(
                      child: loadingVacunas
                          ? const Center(child: CircularProgressIndicator())
                          : vacunas.isEmpty
                          ? const Center(child: Text('No hay vacunas'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: vacunas.length,
                              itemBuilder: (context, index) {
                                final vacuna = vacunas[index];
                                return VacunaCard(
                                  vacuna: vacuna,
                                  onDelete: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Eliminar'),
                                        content: Text(
                                          '¿Eliminar "${vacuna.nombre}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Sí'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await VacunaService().deleteVacuna(
                                        idRefugio!,
                                        animal.id,
                                        vacuna.id,
                                      );
                                      loadVacunas();
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// mantener el menu fijo al hacer scroll
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._container);
  final Container _container;

  @override
  double get minExtent => 50.0;
  @override
  double get maxExtent => 50.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _container;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
