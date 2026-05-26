import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/services/role_service.dart';
import 'package:admin_patitas/screens/externalAdoptionScreen/animal_detail_public_screen.dart';

class AdoptionAnimalGroup {
  final Animal animal;
  final String refugioId;
  final String refugioNombre;
  final String refugioTelefono;
  final String refugioWhatsapp;
  final String refugioEmail;

  AdoptionAnimalGroup({
    required this.animal,
    required this.refugioId,
    required this.refugioNombre,
    required this.refugioTelefono,
    required this.refugioWhatsapp,
    required this.refugioEmail,
  });
}

class PublicAdoptionsScreen extends StatefulWidget {
  const PublicAdoptionsScreen({super.key});

  @override
  State<PublicAdoptionsScreen> createState() => _PublicAdoptionsScreenState();
}

class _PublicAdoptionsScreenState extends State<PublicAdoptionsScreen> {
  bool _isLoading = true;
  List<AdoptionAnimalGroup> _animals = [];

  @override
  void initState() {
    super.initState();
    _loadAdoptions();
  }

  Future<void> _loadAdoptions() async {
    log('>>> _loadAdoptions() iniciado', name: 'PublicAdoptions');
    try {
      // Asegurar sesión activa para poder leer Firebase (aunque sea anónima)
      if (FirebaseAuth.instance.currentUser == null) {
        log(
          '>>> Sin sesión activa, iniciando sesión anónima...',
          name: 'PublicAdoptions',
        );
        if (FirebaseAuth.instance.currentUser == null) {
          await FirebaseAuth.instance.signInAnonymously();
        }

        log('>>> Sesión anónima iniciada', name: 'PublicAdoptions');
      } else {
        log(
          '>>> Ya hay sesión activa: ${FirebaseAuth.instance.currentUser!.uid}',
          name: 'PublicAdoptions',
        );
      }

      final List<Map<String, dynamic>> refugios = await RoleService()
          .getAllRefugios();
      log(
        '>>> Refugios encontrados: ${refugios.length}',
        name: 'PublicAdoptions',
      );

      List<AdoptionAnimalGroup> allAvailable = [];

      for (var refugio in refugios) {
        final String refugioId = refugio['id'];
        final String refugioNombre = refugio['data']['nombre'] ?? 'Refugio';
        final String telefono = refugio['data']['telefono'] ?? '';
        final String whatsapp = refugio['data']['whatsapp'] ?? '';
        final String email = refugio['data']['email_contacto'] ?? '';

        log(
          '>>> Cargando animales del refugio: $refugioNombre ($refugioId)',
          name: 'PublicAdoptions',
        );
        final List<Animal> refugioAnimals = await AnimalsService().getAnimals(
          refugioId,
        );
        log(
          '>>> Animales encontrados en $refugioNombre: ${refugioAnimals.length}',
          name: 'PublicAdoptions',
        );

        for (var animal in refugioAnimals) {
          final estado = animal.estadoAdopcion.toLowerCase().trim();
          log(
            '>>> Animal: "${animal.nombre}" | estado_adopcion RAW: "${animal.estadoAdopcion}"',
            name: 'PublicAdoptions',
          );
          final esDisponible =
              estado == 'disponible' ||
              estado == 'disponible para adopcion' ||
              estado == 'disponible para adopción' ||
              estado == 'en adopcion' ||
              estado == 'en adopción';
          if (esDisponible) {
            allAvailable.add(
              AdoptionAnimalGroup(
                animal: animal,
                refugioId: refugioId,
                refugioNombre: refugioNombre,
                refugioTelefono: telefono,
                refugioWhatsapp: whatsapp,
                refugioEmail: email,
              ),
            );
          }
        }
      }

      log(
        '>>> Total animales disponibles: ${allAvailable.length}',
        name: 'PublicAdoptions',
      );
      if (mounted) {
        setState(() {
          _animals = allAvailable;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      log('>>> ERROR en _loadAdoptions: $e\n$stack', name: 'PublicAdoptions');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Animales en Adopción',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _animals.isEmpty
          ? _buildEmptyState()
          : LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 1;
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 4;
                } else if (constraints.maxWidth > 800) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 600) {
                  crossAxisCount = 2;
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: _animals.length,
                  itemBuilder: (context, index) {
                    return _buildAdoptionCard(_animals[index]);
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 80,
            color: AppColors.textDark.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 20),
          Text(
            '¡Pronto habrán peluditos buscando hogar!',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textDark.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdoptionCard(AdoptionAnimalGroup group) {
    final animal = group.animal;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnimalDetailPublicScreen(group: group),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 8),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'animal_img_${animal.id}',
                      child: animal.imageUrl.isNotEmpty
                          ? Image.network(
                              animal.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.pets,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                            )
                          : const Icon(
                              Icons.pets,
                              size: 60,
                              color: Colors.grey,
                            ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          animal.especie,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              animal.nombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            animal.genero == 'Macho'
                                ? Icons.male
                                : Icons.female,
                            color: animal.genero == 'Macho'
                                ? Colors.blue
                                : AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        group.refugioNombre,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Raza: ${animal.raza}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.touch_app,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ver detalles',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
