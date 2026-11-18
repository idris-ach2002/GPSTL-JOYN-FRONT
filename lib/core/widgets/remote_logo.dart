import 'package:flutter/material.dart';

/// Logo distant avec repli stable si l'URL expire ou si l'image est absente.
class RemoteLogo extends StatelessWidget {
  const RemoteLogo({super.key, required this.url, required this.fallback});
  final String? url;
  final Widget fallback;
  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url!,
        fit: BoxFit.contain,
        errorBuilder: (_, error, stack) => fallback,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}
