import 'package:admin_patitas/services/animals_service.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool _isLoading = true;
  int _totalAnimals = 0;
  int _availableForAdoption = 0;
  double _dogsPct = 0;
  double _catsPct = 0;
  double _othersPct = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final refugioId = PreferencesController.preferences.getString('refugio');
      if (refugioId != null) {
        final animals = await AnimalsService().getAnimals(refugioId);
        
        int dogs = 0;
        int cats = 0;
        int others = 0;
        int available = 0;

        for (var animal in animals) {
          if (animal.estadoAdopcion == 'Disponible') {
            available++;
          }

          final especie = animal.especie.toLowerCase();
          if (especie == 'perro' || especie == 'canino') {
            dogs++;
          } else if (especie == 'gato' || especie == 'felino') {
            cats++;
          } else {
            others++;
          }
        }

        if (mounted) {
          setState(() {
            _totalAnimals = animals.length;
            _availableForAdoption = available;
            if (_totalAnimals > 0) {
              _dogsPct = (dogs / _totalAnimals) * 100;
              _catsPct = (cats / _totalAnimals) * 100;
              _othersPct = (others / _totalAnimals) * 100;
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _fetchStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard General',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Estadísticas y resumen en tiempo real',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textDark.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Top KPI Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Total Animales',
                        value: _totalAnimals.toString(),
                        icon: Icons.pets,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Disponibles',
                        value: _availableForAdoption.toString(),
                        icon: Icons.favorite,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Charts Section
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildSpeciesDistributionChart()),
                          const SizedBox(width: 20),
                          Expanded(child: _buildHealthSummaryCard()),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildSpeciesDistributionChart(),
                          const SizedBox(height: 20),
                          _buildHealthSummaryCard(),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesDistributionChart() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución de Especies',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _totalAnimals == 0 
              ? const Center(child: Text('Sin datos'))
              : PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: [
                      if (_dogsPct > 0)
                        PieChartSectionData(
                          color: AppColors.primary,
                          value: _dogsPct,
                          title: '${_dogsPct.toInt()}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      if (_catsPct > 0)
                        PieChartSectionData(
                          color: AppColors.secondary,
                          value: _catsPct,
                          title: '${_catsPct.toInt()}%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      if (_othersPct > 0)
                        PieChartSectionData(
                          color: Colors.orangeAccent,
                          value: _othersPct,
                          title: '${_othersPct.toInt()}%',
                          radius: 40,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppColors.primary, 'Perros'),
              const SizedBox(width: 15),
              _buildLegendItem(AppColors.secondary, 'Gatos'),
              const SizedBox(width: 15),
              _buildLegendItem(Colors.orangeAccent, 'Otros'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHealthSummaryCard() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consejos de Gestión',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          _buildTipItem(
            Icons.lightbulb_outline,
            'Mantén los registros actualizados para obtener estadísticas precisas.',
          ),
          const SizedBox(height: 15),
          _buildTipItem(
            Icons.security,
            'Recuerda revisar el historial médico antes de cada adopción.',
          ),
          const SizedBox(height: 15),
          _buildTipItem(
            Icons.people_outline,
            'Coordina con tu equipo para actualizar el estado de salud diariamente.',
          ),
          const Spacer(),
          Center(
            child: Text(
              'Actualizado recientemente',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.textDark.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
