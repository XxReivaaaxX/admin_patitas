import 'package:admin_patitas/screens/externalAdoptionScreen/adoption_request_form.dart';
import 'package:admin_patitas/screens/externalAdoptionScreen/public_adoptions_screen.dart';
import 'package:admin_patitas/utils/colors.dart';
import 'package:flutter/material.dart';

class AnimalDetailPublicScreen extends StatelessWidget {
  final AdoptionAnimalGroup group;

  const AnimalDetailPublicScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final animal = group.animal;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── AppBar con foto hero ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'animal_img_${animal.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    animal.imageUrl.isNotEmpty
                        ? Image.network(
                            animal.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                    // Gradiente inferior para legibilidad
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                    // Badge de especie
                    Positioned(
                      top: 16,
                      right: 16,
                      child: _Badge(label: animal.especie),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenido ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre + género
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          animal.nombre,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _GenderChip(genero: animal.genero),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Refugio
                  Row(
                    children: [
                      const Icon(Icons.home_work_outlined,
                          size: 16, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          group.refugioNombre,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tarjetas de info
                  _InfoGrid(animal: animal),

                  const SizedBox(height: 32),

                  // Botón Adóptame
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openAdoptionForm(context),
                      icon: const Icon(Icons.favorite, color: Colors.white),
                      label: const Text(
                        '¡Adóptame!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAdoptionForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdoptionRequestForm(group: group),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.15),
      child: const Center(
        child: Icon(Icons.pets, size: 80, color: Colors.white54),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets internos
// ─────────────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String genero;
  const _GenderChip({required this.genero});

  @override
  Widget build(BuildContext context) {
    final isMacho = genero.toLowerCase() == 'macho';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isMacho ? Colors.blue : AppColors.primary).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMacho ? Icons.male : Icons.female,
            size: 18,
            color: isMacho ? Colors.blue : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            genero,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isMacho ? Colors.blue : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final dynamic animal;
  const _InfoGrid({required this.animal});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.6,
      children: [
        _InfoTile(
          icon: Icons.category_outlined,
          label: 'Raza',
          value: animal.raza,
        ),
        _InfoTile(
          icon: Icons.favorite_border,
          label: 'Estado de Salud',
          value: animal.estadoSalud,
        ),
        _InfoTile(
          icon: Icons.calendar_today_outlined,
          label: 'Fecha de Ingreso',
          value: animal.fechaIngreso,
        ),
        _InfoTile(
          icon: Icons.check_circle_outline,
          label: 'Disponibilidad',
          value: animal.estadoAdopcion,
          valueColor: Colors.green,
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
