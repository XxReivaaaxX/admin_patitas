import 'package:admin_patitas/widgets/build_card.dart';
import 'package:flutter/material.dart';

class InicioScreenMovile extends StatefulWidget {
  final int countPerros;
  final int countGatos;
  final int countOtros;
  final Function(String) navigateToFiltered;
  const InicioScreenMovile({
    super.key,
    required this.countPerros,
    required this.countGatos,
    required this.countOtros,
    required this.navigateToFiltered,
  });

  @override
  State<InicioScreenMovile> createState() => _InicioScreenMovileState();
}

class _InicioScreenMovileState extends State<InicioScreenMovile> {
  bool isPlaceholder = false;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        BuildCard(
          imagePath: 'assets/img/perros_principal.png',
          title: 'Perros',
          count: widget.countPerros,
          onTap: () => widget.navigateToFiltered('Perros'),
          isPlaceholder: false,
        ),
        const SizedBox(height: 16),
        BuildCard(
          imagePath: 'assets/img/gatos_principal.jpg',
          title: 'Gatos',
          count: widget.countGatos,
          onTap: () => widget.navigateToFiltered('Gatos'),
          isPlaceholder: false,
        ),
        const SizedBox(height: 16),
        BuildCard(
          imagePath: 'assets/img/otros_principal.jpg',
          title: 'Otros',
          count: widget.countOtros,
          onTap: () => widget.navigateToFiltered('Otros'),
          isPlaceholder: true,
        ),
      ],
    );
  }
}
