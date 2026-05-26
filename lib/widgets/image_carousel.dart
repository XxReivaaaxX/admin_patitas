import 'dart:async';

import 'package:admin_patitas/utils/colors.dart';
import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final List<String> _images = [
    'assets/img/gatos_principal7.jpg',
    'assets/img/perros_principal7.png',
    'assets/img/Backgound_image_1.png',
    'assets/img/mascotas.png',
  ];

  late final PageController _pageController;
  late final Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final img in _images) {
        precacheImage(AssetImage(img), context);
      }
    });

    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      _currentPage = (_currentPage + 1) % _images.length;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // ← altura explícita, igual que el original
      height: 380,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: PageView.builder(
            controller: _pageController,
            itemCount: null,
            itemBuilder: (context, index) {
              return Image.asset(
                _images[index % _images.length],
                fit: BoxFit.cover,
                cacheWidth: MediaQuery.of(context).size.width.toInt(),
              );
            },
          ),
        ),
      ),
    );
  }
}
