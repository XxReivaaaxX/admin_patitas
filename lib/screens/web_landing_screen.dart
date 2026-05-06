import 'package:admin_patitas/utils/colors.dart';
import 'package:flutter/material.dart';

class WebLandingScreen extends StatelessWidget {
  const WebLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.principalBackgroud,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, isDesktop),
                _buildHeroSection(context, isDesktop),
                _buildFeaturesSection(isDesktop),
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 80 : 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/img/logo_petflow.png', height: 50),
              const SizedBox(width: 15),
              const Text(
                'PET',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Text(
                'FLOW',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.complementary,
                ),
              ),
            ],
          ),
          if (isDesktop)
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/adoptions'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  ),
                  child: const Text('Ver Mascotas en Adopción', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Soy Refugio / Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textDark),
              onPressed: () {
                // Modal bottom sheet para menu en movil web
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/adoptions');
                          },
                          child: const Text('Ver Mascotas en Adopción', style: TextStyle(fontSize: 18, color: AppColors.textDark)),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('Soy Refugio / Iniciar Sesión', style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 80 : 40,
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildHeroContent(context)),
                const SizedBox(width: 60),
                Expanded(child: _buildHeroImage()),
              ],
            )
          : Column(
              children: [
                _buildHeroImage(),
                const SizedBox(height: 40),
                _buildHeroContent(context, centered: true),
              ],
            ),
    );
  }

  Widget _buildHeroContent(BuildContext context, {bool centered = false}) {
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '¡Dale un hogar a un peludito! 🐶🐱',
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Transformando la manera en que los refugios y adoptantes se conectan.',
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: centered ? 36 : 48,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'PetFlow es la plataforma integral que facilita el proceso de adopción, seguimiento de salud y gestión de refugios, todo en un solo lugar. ¡Haz la diferencia hoy!',
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textDark.withOpacity(0.7),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/adoptions'),
              icon: const Icon(Icons.favorite),
              label: const Text('Quiero Adoptar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 5,
                shadowColor: AppColors.primary.withOpacity(0.5),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              icon: const Icon(Icons.pets),
              label: const Text('Acceso a Refugios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.complementary,
                side: const BorderSide(color: AppColors.complementary, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.asset(
          'assets/img/gatos_principal7.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: 80,
      ),
      child: Column(
        children: [
          const Text(
            '¿Por qué usar PetFlow?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Una solución completa para amantes de los animales y administradores.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textDark.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 60),
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildFeatureCard(
                      icon: Icons.business,
                      color: AppColors.primary,
                      title: 'Gestión de Refugios',
                      description: 'Administra animales, controla el estado de salud, organiza vacunas y gestiona a tus colaboradores fácilmente.',
                    )),
                    const SizedBox(width: 30),
                    Expanded(child: _buildFeatureCard(
                      icon: Icons.favorite,
                      color: AppColors.secondary,
                      title: 'Adopción Transparente',
                      description: 'Los usuarios pueden ver los animales disponibles, llenar formularios detallados y seguir el proceso online.',
                    )),
                    const SizedBox(width: 30),
                    Expanded(child: _buildFeatureCard(
                      icon: Icons.mail,
                      color: AppColors.complementary,
                      title: 'Notificaciones Rápidas',
                      description: 'Notifica automáticamente por correo electrónico a los solicitantes cuando su solicitud de adopción sea aprobada.',
                    )),
                  ],
                )
              : Column(
                  children: [
                    _buildFeatureCard(
                      icon: Icons.business,
                      color: AppColors.primary,
                      title: 'Gestión de Refugios',
                      description: 'Administra animales, controla el estado de salud, organiza vacunas y gestiona a tus colaboradores fácilmente.',
                    ),
                    const SizedBox(height: 30),
                    _buildFeatureCard(
                      icon: Icons.favorite,
                      color: AppColors.secondary,
                      title: 'Adopción Transparente',
                      description: 'Los usuarios pueden ver los animales disponibles, llenar formularios detallados y seguir el proceso online.',
                    ),
                    const SizedBox(height: 30),
                    _buildFeatureCard(
                      icon: Icons.mail,
                      color: AppColors.complementary,
                      title: 'Notificaciones Rápidas',
                      description: 'Notifica automáticamente por correo electrónico a los solicitantes cuando su solicitud de adopción sea aprobada.',
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.principalBackgroud,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textDark.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/img/logo_petflow.png', height: 30),
              const SizedBox(width: 10),
              const Text(
                'PET',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
              ),
              const Text(
                'FLOW',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.complementary, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '© ${DateTime.now().year} PetFlow. Todos los derechos reservados.',
            style: TextStyle(color: AppColors.textDark.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
