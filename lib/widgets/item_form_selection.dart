import 'package:flutter/material.dart';

class ItemFormSelection extends StatelessWidget {
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String>? validator;
  final List<String> items; // lista de opciones
  final String text;

  const ItemFormSelection({
    super.key,

    required this.onChanged,
    required this.validator,
    required this.items,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: text,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      items: items.map((especie) {
        return DropdownMenuItem(value: especie, child: Text(especie));
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
