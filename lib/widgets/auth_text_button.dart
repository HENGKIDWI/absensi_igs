import 'package:flutter/material.dart';

class AuthTextButton extends StatelessWidget {
  final String text;
  final Color warnaText;
  final VoidCallback onPressed;
  final Alignment alignment;

  const AuthTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.alignment = Alignment.centerLeft,
    required this.warnaText,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w500, color: warnaText),
        ),
      ),
    );
  }
}
