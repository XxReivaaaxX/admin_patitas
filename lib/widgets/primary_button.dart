import 'package:flutter/material.dart';
import 'package:admin_patitas/utils/colors.dart';

class PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final bool isTransparent;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    required this.isTransparent,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double heightSize = MediaQuery.of(context).size.height;
    double sizeButton = (heightSize < 800) ? 40 : 55;
    double sizeFont = (heightSize < 800) ? 13 : 18;
    return GestureDetector(
      onTapDown: (_) => widget.onPressed != null ? _controller.forward() : null,
      onTapUp: (_) {
        if (widget.onPressed != null) {
          _controller.reverse();
          widget.onPressed!();
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: sizeButton,
          decoration: BoxDecoration(
            color: widget.isTransparent
                ? Colors.transparent
                : AppColors.primary,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.primary, width: 2),

            boxShadow: [
              if (widget.onPressed != null && !widget.isTransparent)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: widget.isTransparent
                          ? AppColors.primary
                          : AppColors.backgroundLight,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.isTransparent
                          ? AppColors.primary
                          : AppColors.backgroundLight,
                      fontSize: sizeFont,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
