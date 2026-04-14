import 'package:flutter/material.dart';
import 'package:admin_patitas/utils/colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool floatingLabel;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    required this.floatingLabel,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    double heightSize = MediaQuery.of(context).size.height;
    double sizeInput = (heightSize < 800) ? 5.0 : 20.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.floatingLabel)
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              widget.label,
              style: const TextStyle(
                color: AppColors.backgroundDark,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          style: const TextStyle(color: AppColors.backgroundDark, fontSize: 16),
          validator: widget.validator,

          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: AppColors.backgroundDark.withValues(alpha: 0.6),
            ),
            floatingLabelStyle: const TextStyle(
              color: AppColors.backgroundDark,
              fontWeight: FontWeight.normal,
            ),
            floatingLabelBehavior: widget.floatingLabel
                ? FloatingLabelBehavior.auto
                : FloatingLabelBehavior.never,
            filled: true,
            fillColor: AppColors.backgroundLight,
            contentPadding: EdgeInsets.symmetric(
              vertical: sizeInput,
              horizontal: 20.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: Colors.amberAccent, width: 4),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: AppColors.borderLight, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            prefixIcon: Icon(
              widget.icon,
              color: AppColors.backgroundDark.withValues(alpha: 0.8),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.backgroundDark.withValues(alpha: 0.7),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
