import 'package:flutter/material.dart';

/// Company logo with a 3-level fallback chain:
///   1. Local asset  (`assets/logos/domain.png`)  — sharp, offline, preferred
///   2. Google favicon service                    — network fallback
///   3. Letter avatar                             — always works
///
/// A white chip sits behind the logo so dark logos (AMD, Marvell, …)
/// stay visible on the dark theme.
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
    // Local logos are full-bleed squares — show them edge to edge
    // with rounded corners (app-icon style).
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/logos/$domain.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Decode at ~2x display size instead of full 256px — cheaper to
        // rasterize while staying sharp on high-DPI screens.
        cacheWidth: (size * 2).round(),
        errorBuilder: (context, error, stackTrace) => _buildChippedNetworkLogo(),
      ),
    );
  }

  // White chip behind network favicons (often transparent / dark logos).
  Widget _buildChippedNetworkLogo() {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: _buildNetworkLogo(),
    );
  }

  Widget _buildNetworkLogo() {
    return Image.network(
      'https://www.google.com/s2/favicons?domain=$domain&sz=128',
      fit: BoxFit.contain,
      // On web, fall back to an HTML <img> element when CORS blocks the
      // normal fetch (Google's favicon service sends no CORS headers).
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      errorBuilder: (context, error, stackTrace) => _buildLetterAvatar(),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }

  Widget _buildLetterAvatar() {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return CircleAvatar(
          radius: size / 2,
          backgroundColor: cs.surfaceContainerHighest,
          child: Text(
            letter,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
