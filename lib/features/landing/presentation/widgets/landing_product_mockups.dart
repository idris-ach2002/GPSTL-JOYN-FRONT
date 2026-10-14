import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';

class MatchScoreMockup extends StatelessWidget {
  const MatchScoreMockup({
    this.compact = false,
    this.score = 92,
    this.company = 'Nébula Pay',
    this.title = 'Développeur·euse Full-Stack',
    super.key,
  });

  final bool compact;
  final int score;
  final String company;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(compact ? 18 : 24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.14),
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'N',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Fintech · Paris',
                      style: TextStyle(color: AppColors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F8EE),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: const Text(
                  '1450 €',
                  style: TextStyle(
                    color: Color(0xFF2C8D55),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 14 : 20),
          Text(
            title,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: compact ? 16 : 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: compact ? 12 : 18),
          Row(
            children: [
              SizedBox(
                width: compact ? 64 : 82,
                height: compact ? 64 : 82,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: compact ? 6 : 8,
                      backgroundColor: const Color(0xFFE7EEF4),
                      color: AppColors.cyanBlue,
                    ),
                    Center(
                      child: Text(
                        '$score%',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: compact ? 16 : 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: const [
                    _ScoreLine(label: 'Compétences', value: .82),
                    SizedBox(height: 7),
                    _ScoreLine(label: 'Formation', value: 1),
                    SizedBox(height: 7),
                    _ScoreLine(label: 'Rythme', value: 1),
                    SizedBox(height: 7),
                    _ScoreLine(label: 'Trajet', value: .90),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreLine extends StatelessWidget {
  const _ScoreLine({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 66,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.grey, fontSize: 9),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 5,
              backgroundColor: const Color(0xFFE7EEF4),
              color: AppColors.cyanBlue,
            ),
          ),
        ),
      ],
    );
  }
}

class CandidateListMockup extends StatelessWidget {
  const CandidateListMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0E5F82),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: .2),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: const [
          _CandidateTile(
            initials: 'YK',
            name: 'Yasmine K.',
            detail: 'M1 Informatique · Paris 13e',
            score: 92,
          ),
          SizedBox(height: 10),
          _CandidateTile(
            initials: 'HL',
            name: 'Hugo L.',
            detail: 'BUT Info · dispo sept. 2027',
            score: 88,
          ),
          SizedBox(height: 10),
          _CandidateTile(
            initials: 'NB',
            name: 'Nora B.',
            detail: 'Candidature via Remplace-moi',
            score: 85,
            highlighted: true,
          ),
        ],
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.initials,
    required this.name,
    required this.detail,
    required this.score,
    this.highlighted = false,
  });

  final String initials;
  final String name;
  final String detail;
  final int score;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.white.withValues(alpha: .15)
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: highlighted
            ? Border.all(color: AppColors.white.withValues(alpha: .14))
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: highlighted
                ? const Color(0xFFB7E2CF)
                : const Color(0xFFAEDFF3),
            foregroundColor: AppColors.navy,
            child: Text(
              initials,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: highlighted ? AppColors.white : AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: highlighted
                        ? AppColors.white.withValues(alpha: .72)
                        : AppColors.grey,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: highlighted ? AppColors.orange : const Color(0xFFE8F5FA),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              '$score%',
              style: TextStyle(
                color: highlighted ? AppColors.white : AppColors.navy,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PhoneStackMockup extends StatelessWidget {
  const PhoneStackMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -.18,
            child: const _PhoneShell(offsetContent: true),
          ),
          Transform.rotate(
            angle: .18,
            child: const _PhoneShell(offsetContent: true),
          ),
          const _PhoneShell(),
        ],
      ),
    );
  }
}

class _PhoneShell extends StatelessWidget {
  const _PhoneShell({this.offsetContent = false});

  final bool offsetContent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 122,
      height: 226,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFF071E32),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 22, 10, 10),
        decoration: BoxDecoration(
          color: offsetContent
              ? const Color(0xFFF6FAFD)
              : const Color(0xFF0E5473),
          borderRadius: BorderRadius.circular(20),
        ),
        child: offsetContent
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 62,
                    height: 10,
                    decoration: _barDecoration(AppColors.navy),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 80,
                    height: 7,
                    decoration: _barDecoration(const Color(0xFFDCE7EF)),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    width: 58,
                    height: 7,
                    decoration: _barDecoration(const Color(0xFFDCE7EF)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F4FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: i == 2
                                ? AppColors.orange
                                : const Color(0xFFDCE7EF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (i < 2) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 3, color: AppColors.white),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(-8, 0),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 3,
                              color: AppColors.orange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "C'est un\nmatch.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 72,
                    height: 12,
                    decoration: _barDecoration(AppColors.white),
                  ),
                ],
              ),
      ),
    );
  }

  BoxDecoration _barDecoration(Color color) =>
      BoxDecoration(color: color, borderRadius: BorderRadius.circular(999));
}

class MiniCvMockup extends StatelessWidget {
  const MiniCvMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE52D2D),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'PDF',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'mon_CV.pdf',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                width: 90,
                height: 7,
                decoration: _pill(const Color(0xFF8DE09D)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 5,
          children: const [
            _SkillPill(label: 'React'),
            _SkillPill(label: 'Python'),
            _SkillPill(label: '+9'),
          ],
        ),
      ],
    );
  }

  BoxDecoration _pill(Color color) =>
      BoxDecoration(color: color, borderRadius: BorderRadius.circular(999));
}

class _SkillPill extends StatelessWidget {
  const _SkillPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
