import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/layout/content_container.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../landing/presentation/widgets/joyn_mark.dart';
import '../domain/information_content.dart';

/// Page publique accessible directement par URL et depuis le footer.
/// Le retour dépile la route pour conserver le scroll de la landing existante.
class InformationScreen extends StatelessWidget {
  const InformationScreen({required this.page, super.key});
  final InformationPage page;

  void _returnToLanding(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [JoynMark(size: 30), SizedBox(width: 10), Text('joyn')],
      ),
      actions: [
        TextButton.icon(
          key: const ValueKey('return-landing'),
          onPressed: () => _returnToLanding(context),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Retour à la landing'),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: SafeArea(
      child: SelectionArea(
        child: SingleChildScrollView(
          child: ContentContainer(
            maxWidth: 1000,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page.eyebrow.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.orange,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    page.title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    page.introduction,
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.blueGreyDark,
                      height: 1.6,
                    ),
                  ),
                  if (page.notice != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Card(
                        color: AppColors.blueGrey10,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            page.notice!,
                            style: const TextStyle(height: 1.6),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 36),
                  for (final section in page.sections)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section.title,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                section.body,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.7,
                                  color: AppColors.blueGreyDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (page.actionRoute != null)
                    FilledButton.icon(
                      onPressed: () => context.push(page.actionRoute!),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(page.actionLabel!),
                    ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () => _returnToLanding(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Revenir à JOYN'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
