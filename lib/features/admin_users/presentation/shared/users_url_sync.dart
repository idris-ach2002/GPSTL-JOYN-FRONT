import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routing/app_routes.dart';
import '../../domain/user_query.dart';
import '../controllers/admin_users_controller.dart';

/// Relie le contrôleur aux paramètres de l'URL (`?page=2&q=emma&role=…`).
///
/// - au chargement, au rafraîchissement ou après « retour », la requête lue
///   dans l'URL est appliquée au contrôleur ;
/// - quand l'admin change un filtre, l'URL est mise à jour.
mixin AdminUsersUrlSync<T extends StatefulWidget> on State<T> {
  /// Requête lue dans l'URL courante.
  UserQuery get urlQuery;

  late final AdminUsersController usersController;

  @override
  void initState() {
    super.initState();
    usersController = context.read<AdminUsersController>()
      ..onQueryChanged = _writeUrl;
    _syncAfterFrame();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAfterFrame();
  }

  @override
  void dispose() {
    usersController.onQueryChanged = null;
    super.dispose();
  }

  // Après la frame : on ne notifie pas pendant la construction des widgets.
  void _syncAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) usersController.syncWithUrl(urlQuery);
    });
  }

  void _writeUrl(UserQuery query) {
    if (!mounted) return;
    final params = query.toQueryParameters();
    GoRouter.of(context).go(
      Uri(
        path: AppRoutes.adminUsers,
        queryParameters: params.isEmpty ? null : params,
      ).toString(),
    );
  }
}
