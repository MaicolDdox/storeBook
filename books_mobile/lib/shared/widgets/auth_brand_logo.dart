import 'package:flutter/material.dart';

class AuthBrandLogo extends StatelessWidget {
  const AuthBrandLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 240,
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD6E9F7)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A004E78),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 3.3,
          child: Image.asset(
            'assets/brand/logo.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
