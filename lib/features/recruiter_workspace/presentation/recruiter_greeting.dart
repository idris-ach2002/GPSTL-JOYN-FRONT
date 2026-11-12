import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'workspace_controller.dart';

class RecruiterGreeting extends StatelessWidget {
  const RecruiterGreeting({super.key, required this.style});
  final TextStyle style;
  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceController?>();
    final name = '${workspace?.profile?['firstName'] ?? ''}'.trim();
    return Text(
      name.isEmpty ? 'Bonjour 👋' : 'Bonjour $name 👋',
      style: style,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
