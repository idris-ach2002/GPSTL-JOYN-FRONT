import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/mobile/mobile_app_surface.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../domain/information_content.dart';

class MobileInformationScreen extends StatelessWidget {
  const MobileInformationScreen({super.key, required this.page});

  final InformationPage page;

  @override
  Widget build(BuildContext context) {
    return MobileAppSurface(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 8),
                const MobileBrandMark(compact: true),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page.eyebrow,
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    page.title,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 30,
                      height: 1.02,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    page.introduction,
                    style: const TextStyle(
                      color: AppColors.slate,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 26),
                  for (final section in page.sections) ...[
                    Text(
                      section.title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      section.body,
                      style: const TextStyle(
                        color: AppColors.slate,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
