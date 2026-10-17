// Déclare les routes actives de la landing, de la connexion et de l’assistance.
//
// Référence : doc/landing.md#app_routerdart.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/landing/presentation/screens/landing_screen.dart';
import '../../features/landing/presentation/screens/service_screen.dart';

/// Routeur réellement fourni à MaterialApp.router.
final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/connexion',
      builder: (context, state) => const ServiceScreen(connection: true),
    ),
    GoRoute(
      path: '/assistance',
      builder: (context, state) => ServiceScreen(
        connection: false,
        question: state.uri.queryParameters['question'] ?? '',
      ),
    ),
    for (final audience in ['accueil', 'candidats', 'entreprises'])
      GoRoute(
        path: audience == 'accueil' ? '/' : '/$audience',
        builder: (context, state) => LandingScreen(
          key: ValueKey(state.uri.path),
          audience: audience,
          initialTarget: state.uri.queryParameters['section'],
        ),
      ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Cette page n’existe pas.'),
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('REVENIR À JOYN'),
          ),
        ],
      ),
    ),
  ),
);
