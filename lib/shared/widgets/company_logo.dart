import 'package:flutter/material.dart';

class CompanyLogo extends StatelessWidget {
  final String domain;
  final String name;
  final double size;

  const CompanyLogo({
    super.key,
    required this.domain,
    required this.name,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    if (domain.isEmpty) {
      return _buildLetterAvatar();
    }
    return Image.network(
      'https://logo.clearbit.com/$domain',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => _buildLetterAvatar(),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }

  Widget _buildLetterAvatar() {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey[800],
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}