import 'package:flutter/material.dart';

class CustomDoubleText extends StatelessWidget {
  final String text, typeText;
  const CustomDoubleText({
    super.key,
    required this.text,
    required this.typeText,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$typeText\n',

            style: TextStyle(
              fontSize: 11,
              color: Color.fromARGB(255, 124, 124, 124),
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          TextSpan(
            text: text,

            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
