import 'package:admin_patitas/widgets/build_card.dart';
import 'package:flutter/material.dart';

class InicioScreenWeb extends StatefulWidget {
  final int countPerros;
  final int countGatos;
  final int countOtros;
  final Function(String) navigateToFiltered;
  const InicioScreenWeb({
    super.key,
    required this.countPerros,
    required this.countGatos,
    required this.countOtros,
    required this.navigateToFiltered,
  });

  @override
  State<InicioScreenWeb> createState() => _InicioScreenWebState();
}

class _InicioScreenWebState extends State<InicioScreenWeb> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 150, vertical: 20),
        child: Column(
          children: [
            // Card principal con el Grid
            Card(
              color: Colors.white,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculamos el alto del grid basado en su contenido
                  const int crossAxisCount = 3;
                  const double childAspectRatio = 3.0;
                  const double crossAxisSpacing = 2;
                  const double mainAxisSpacing = 16;
                  const double padding = 16.0;
                  const int itemCount = 3;

                  final double itemWidth =
                      (constraints.maxWidth -
                          padding * 2 -
                          crossAxisSpacing * (crossAxisCount - 1)) /
                      crossAxisCount;
                  final double itemHeight = itemWidth / childAspectRatio;
                  final int rowCount = (itemCount / crossAxisCount).ceil();
                  final double gridHeight =
                      rowCount * itemHeight +
                      (rowCount - 1) * mainAxisSpacing +
                      padding * 2;

                  return SizedBox(
                    height: gridHeight,
                    child: GridView(
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(padding),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: crossAxisSpacing,
                        mainAxisSpacing: mainAxisSpacing,
                      ),
                      children: [
                        BuildCard(
                          imagePath: 'assets/img/perros_principal.png',
                          title: 'Perros',
                          count: widget.countPerros,
                          onTap: () => widget.navigateToFiltered('Perros'),
                          isPlaceholder: false,
                        ),
                        BuildCard(
                          imagePath: 'assets/img/gatos_principal.jpg',
                          title: 'Gatos',
                          count: widget.countGatos,
                          onTap: () => widget.navigateToFiltered('Gatos'),
                          isPlaceholder: false,
                        ),
                        BuildCard(
                          imagePath: 'assets/img/otros_principal.jpg',
                          title: 'Otros',
                          count: widget.countOtros,
                          onTap: () => widget.navigateToFiltered('Otros'),
                          isPlaceholder: true,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // Card en blanco para contenido futuro
            Card(
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: Center(
                  child: Text(
                    'Próximamente...',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
