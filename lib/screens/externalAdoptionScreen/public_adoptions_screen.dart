import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/services/role_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
    try {
      final List<Map<String, dynamic>> refugios = await RoleService().getAllRefugios();
      List<AdoptionAnimalGroup> allAvailable = [];

      for (var refugio in refugios) {
        final String refugioId = refugio['id'];
        final String refugioNombre = refugio['data']['nombre'] ?? 'Refugio';
        final String telefono = refugio['data']['telefono'] ?? '';
        final String whatsapp = refugio['data']['whatsapp'] ?? '';
        final String email = refugio['data']['email_contacto'] ?? '';

        final List<Animal> refugioAnimals = await AnimalsService().getAnimals(refugioId);
        
        for (var animal in refugioAnimals) {
          if (animal.estadoAdopcion == 'Disponible') {
            allAvailable.add(AdoptionAnimalGroup(
              animal: animal,
              refugioId: refugioId,
              refugioNombre: refugioNombre,
              refugioTelefono: telefono,
              refugioWhatsapp: whatsapp,
              refugioEmail: email,
            ));
          }
        }
      }

      if (mounted) {
        setState(() {
          _animals = allAvailable;
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error cargando adopciones públicas: $e');
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
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
          Icon(Icons.pets, size: 80, color: AppColors.textDark.withValues(alpha: 0.2)),
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
    
    return Container(
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
                   animal.imageUrl.isNotEmpty
                      ? Image.network(
                          animal.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            Image.asset('assets/img/dog_category_premium.png', fit: BoxFit.cover),
                        )
                      : Image.asset('assets/img/dog_category_premium.png', fit: BoxFit.cover),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              flex: 5,
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
                          animal.genero == 'Macho' ? Icons.male : Icons.female, 
                          color: animal.genero == 'Macho' ? Colors.blue : AppColors.primary, 
                          size: 20
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group.refugioNombre,
                      style: TextStyle(
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
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showContactOptions(group),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('¡Adoptame!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactOptions(AdoptionAnimalGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Contactar a ${group.refugioNombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('¿Quieres adoptar a ${group.animal.nombre}? Contacta con el refugio:'),
            const SizedBox(height: 20),
            if (group.refugioTelefono.isNotEmpty)
              _buildContactButton(
                icon: Icons.phone,
                label: 'Llamar: ${group.refugioTelefono}',
                color: Colors.blue,
                onTap: () => launchUrl(Uri.parse('tel:${group.refugioTelefono}')),
              ),
            if (group.refugioWhatsapp.isNotEmpty)
              _buildContactButton(
                icon: Icons.chat,
                label: 'WhatsApp',
                color: Colors.green,
                onTap: () {
                  final cleanWa = group.refugioWhatsapp.replaceAll(RegExp(r'[^0-9]'), '');
                  launchUrl(Uri.parse('https://wa.me/$cleanWa'), mode: LaunchMode.externalApplication);
                },
              ),
            if (group.refugioEmail.isNotEmpty)
              _buildContactButton(
                icon: Icons.email,
                label: 'Enviar Correo',
                color: Colors.orange,
                onTap: () => launchUrl(Uri.parse('mailto:${group.refugioEmail}?subject=Interés en adoptar a ${group.animal.nombre}')),
              ),
            if (group.refugioTelefono.isEmpty && group.refugioWhatsapp.isEmpty && group.refugioEmail.isEmpty)
              const Text('Este refugio no ha proporcionado información de contacto directa.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 18),
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
