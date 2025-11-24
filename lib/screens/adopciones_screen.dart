import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/services/role_service.dart';
import 'package:admin_patitas/services/adopcion_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdopcionesScreen extends StatefulWidget {
  const AdopcionesScreen({super.key});
  @override
  State<AdopcionesScreen> createState() => _AdopcionesScreenState();
}

class _AdopcionesScreenState extends State<AdopcionesScreen> {
  // Estructura: { 'RefugioID': { 'nombre': 'NombreRefugio', 'animales': [Animal1, Animal2] } }
  Map<String, Map<String, dynamic>> _groupedAnimals = {};
  Map<String, Map<String, dynamic>> _filteredAnimals = {};
  bool _isLoading = true;
  final Set<String> _savedAnimalIds = {};
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadAvailableAnimals(), _loadSavedStatus()]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadSavedStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final savedAnimals = await AdopcionService().getSavedAnimals(user.uid);
      setState(() {
        _savedAnimalIds.clear();
        for (var item in savedAnimals) {
          _savedAnimalIds.add(item['animalId']);
        }
      });
    } catch (e) {
      debugPrint('Error cargando estado de guardados: $e');
    }
  }

  Future<void> _loadAvailableAnimals() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      List<Map<String, dynamic>> refugios = await RoleService()
          .getAllRefugios();
      Map<String, Map<String, dynamic>> grouped = {};
      for (var refugio in refugios) {
        String refugioId = refugio['id'];
        String refugioNombre =
            refugio['data']['nombre'] ?? 'Refugio sin nombre';
        List<Animal> animals = await AnimalsService().getAnimals(refugioId);
        if (animals.isNotEmpty) {
          grouped[refugioId] = {'nombre': refugioNombre, 'animales': animals};
        }
      }
      setState(() {
        _groupedAnimals = grouped;
        _filteredAnimals = grouped; // Inicialmente mostrar todos
      });
    } catch (e) {
      debugPrint('Error cargando adopciones: $e');
    }
  }

  void _filterAnimals(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredAnimals = _groupedAnimals;
      });
      return;
    }
    final queryLower = query.toLowerCase();
    Map<String, Map<String, dynamic>> filtered = {};
    _groupedAnimals.forEach((refugioId, refugioData) {
      String refugioNombre = refugioData['nombre'].toString().toLowerCase();
      List<Animal> animales = refugioData['animales'];
      // Filtrar animales que coincidan con la búsqueda
      List<Animal> animalesFiltrados = animales.where((animal) {
        String nombreAnimal = animal.nombre.toLowerCase();
        String especieAnimal = animal.especie.toLowerCase();
        return nombreAnimal.contains(queryLower) ||
            especieAnimal.contains(queryLower) ||
            refugioNombre.contains(queryLower);
      }).toList();
      // Solo agregar el refugio si tiene animales que coinciden
      if (animalesFiltrados.isNotEmpty) {
        filtered[refugioId] = {
          'nombre': refugioData['nombre'],
          'animales': animalesFiltrados,
        };
      }
    });
    setState(() {
      _filteredAnimals = filtered;
    });
  }

  Future<void> _toggleSaveAnimal(String refugioId, Animal animal) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final isSaved = _savedAnimalIds.contains(animal.id);
      if (isSaved) {
        await AdopcionService().removeAnimal(user.uid, animal.id);
        setState(() {
          _savedAnimalIds.remove(animal.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Animal eliminado de guardados')),
          );
        }
      } else {
        await AdopcionService().saveAnimal(user.uid, refugioId, animal);
        setState(() {
          _savedAnimalIds.add(animal.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Animal guardado exitosamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar guardados: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Adopciones Disponibles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(55, 148, 194, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(55, 148, 194, 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterAnimals,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por refugio, especie o nombre...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          _filterAnimals('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Lista de animales
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAnimals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchController.text.isEmpty
                              ? Icons.pets
                              : Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No hay animales disponibles'
                              : 'No se encontraron resultados',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_searchController.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              _filterAnimals('');
                            },
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Limpiar búsqueda'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredAnimals.length,
                    itemBuilder: (context, index) {
                      String refugioId = _filteredAnimals.keys.elementAt(index);
                      Map<String, dynamic> refugioData =
                          _filteredAnimals[refugioId]!;
                      String refugioNombre = refugioData['nombre'];
                      List<Animal> animales = refugioData['animales'];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          shape: const Border(),
                          title: Text(
                            refugioNombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color.fromRGBO(55, 148, 194, 1),
                            ),
                          ),
                          leading: const Icon(
                            Icons.home_work,
                            color: Color.fromRGBO(55, 148, 194, 1),
                          ),
                          children: animales.map((animal) {
                            final isSaved = _savedAnimalIds.contains(animal.id);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[200],
                                      child: animal.imageUrl.isNotEmpty
                                          ? Image.network(
                                              animal.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.pets,
                                                      color: Colors.grey[400],
                                                    );
                                                  },
                                            )
                                          : Icon(
                                              Icons.pets,
                                              color: Colors.grey[400],
                                            ),
                                    ),
                                  ),
                                  title: Text(
                                    animal.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        '${animal.especie} • ${animal.raza}',
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'Disponible',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      isSaved
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: isSaved
                                          ? const Color.fromRGBO(
                                              55,
                                              148,
                                              194,
                                              1,
                                            )
                                          : Colors.grey,
                                      size: 28,
                                    ),
                                    onPressed: () =>
                                        _toggleSaveAnimal(refugioId, animal),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
