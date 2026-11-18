import 'package:flutter/material.dart';

class StudentDashboardHero extends StatelessWidget {
  const StudentDashboardHero({super.key, required this.actions});
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, limits) {
        final wide = limits.maxWidth >= 690;
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF061A33),
                  Color(0xFF0E3855),
                  Color(0xFF133D62),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: wide ? 38 : 20,
                    vertical: wide ? 44 : 25,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: wide ? limits.maxWidth * .62 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suivi de mes candidatures',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                height: 1.07,
                                fontSize: wide ? 45 : 32,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: actions,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
