import 'package:admin_patitas/models/animal.dart';
import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:flutter/material.dart';

class FilteredAnimalsScreen extends StatefulWidget {
  final String category; // 'Perros', 'Gatos', 'Otros'

  const FilteredAnimalsScreen({super.key, required this.category});

  @override
  State<FilteredAnimalsScreen> createState() => _FilteredAnimalsScreenState();
}

class _FilteredAnimalsScreenState extends State<FilteredAnimalsScreen> {
  List<Animal> _animals = [];
  bool _isLoading = true;
  String? _refugioId;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    setState(() => _isLoading = true);
    try {
      _refugioId = PreferencesController.preferences.getString('refugio');
      if (_refugioId == null) return;

      final allAnimals = await AnimalsService().getAnimals(_refugioId!);

      final filtered = allAnimals.where((animal) {
        final especie = animal.especie.toLowerCase();
        if (widget.category == 'Perros') {
          return especie == 'perro' || especie == 'canino';
        } else if (widget.category == 'Gatos') {
          return especie == 'gato' || especie == 'felino';
        } else {
          // Otros: todo lo que no sea perro ni gato
          return especie != 'perro' &&
              especie != 'canino' &&
              especie != 'gato' &&
              especie != 'felino';
        }
      }).toList();

      setState(() {
        _animals = filtered;
      });
    } catch (e) {
      print('Error loading animals: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildGenderChart() {
    int males = _animals.where((a) => a.genero.toLowerCase() == 'macho').length;
    int females = _animals
        .where((a) => a.genero.toLowerCase() == 'hembra')
        .length;
    int total = _animals.length;

    if (total == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de ${widget.category}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(55, 148, 194, 1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total: $total animales',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: males,
                child: males > 0
                    ? Container(
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(8),
                            right: Radius.zero,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$males',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                flex: females,
                child: females > 0
                    ? Container(
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.zero,
                            right: Radius.circular(8),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$females',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.blue, 'Machos'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.pink, 'Hembras'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(55, 148, 194, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildGenderChart(),
                Expanded(
                  child: _animals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pets,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay ${widget.category.toLowerCase()} disponibles',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _animals.length,
                          itemBuilder: (context, index) {
                            final animal = _animals[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('${animal.especie} • ${animal.raza}'),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            animal.estadoAdopcion ==
                                                'Disponible'
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        animal.estadoAdopcion,
                                        style: TextStyle(
                                          color:
                                              animal.estadoAdopcion ==
                                                  'Disponible'
                                              ? Colors.green
                                              : Colors.orange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
