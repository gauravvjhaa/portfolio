import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main.dart';
import '../widgets/layout.dart';
import '../widgets/reusable.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({Key? key}) : super(key: key);

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  late Future<List<Map<String, dynamic>>> _skillsFuture;

  static const List<String> _preferredCategoryOrder = [
    'Programming Languages',
    'Frameworks & Backend',
    'Machine Learning',
    'Computer Science Fundamentals',
    'Developer Tools',
  ];

  @override
  void initState() {
    super.initState();
    _skillsFuture = _fetchSkills();
  }

  Future<List<Map<String, dynamic>>> _fetchSkills() async {
    try {
      final response = await supabase
          .from('skills')
          .select()
          .order('category', ascending: true)
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load skills: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sidePadding = MediaQuery.of(context).size.width < 700 ? 16.0 : 24.0;

    return SingleChildScrollView(
      child: AnimatedContentContainer(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sidePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle("Skills")
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(
                        begin: 0.12,
                        end: 0,
                        duration: 450.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 20),
                  Text(
                        "A focused set of technologies and foundations I use to build reliable software.",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge!.copyWith(height: 1.55),
                      )
                      .animate(delay: 80.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(
                        begin: 0.10,
                        end: 0,
                        duration: 450.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 30),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _skillsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingState();
                      }
                      if (snapshot.hasError) {
                        return ErrorState(
                          message:
                              "Failed to load skills. Please try again later.",
                          onRetry:
                              () => setState(
                                () => _skillsFuture = _fetchSkills(),
                              ),
                        );
                      }

                      final skills = snapshot.data ?? [];
                      if (skills.isEmpty) {
                        return const EmptyState(
                          message: "No skills to display yet.",
                        );
                      }

                      final Map<String, List<Map<String, dynamic>>>
                      skillsByCategory = {};
                      for (final skill in skills) {
                        final category =
                            (skill['category'] as String?)?.trim().isNotEmpty ==
                                    true
                                ? (skill['category'] as String).trim()
                                : 'Other';
                        skillsByCategory
                            .putIfAbsent(category, () => [])
                            .add(skill);
                      }

                      final categories =
                          skillsByCategory.keys.toList()..sort((a, b) {
                            final ai = _preferredCategoryOrder.indexOf(a);
                            final bi = _preferredCategoryOrder.indexOf(b);
                            if (ai == -1 && bi == -1) return a.compareTo(b);
                            if (ai == -1) return 1;
                            if (bi == -1) return -1;
                            return ai.compareTo(bi);
                          });

                      return Column(
                        children: List.generate(categories.length, (
                          categoryIndex,
                        ) {
                          final category = categories[categoryIndex];
                          final categorySkills =
                              skillsByCategory[category]!..sort(
                                (a, b) => (a['name'] ?? '')
                                    .toString()
                                    .compareTo((b['name'] ?? '').toString()),
                              );

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  categoryIndex == categories.length - 1
                                      ? 8
                                      : 30,
                            ),
                            child: _CategorySection(
                              category: category,
                              skills: categorySkills ?? [],
                              categoryIndex: categoryIndex,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> skills;
  final int categoryIndex;

  const _CategorySection({
    Key? key,
    required this.category,
    required this.skills,
    required this.categoryIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;

    return Column(
      children: [
        Center(
              child: Column(
                children: [
                  Text(
                    category,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: secondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 74,
                    height: 3,
                    decoration: BoxDecoration(
                      color: secondary.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ],
              ),
            )
            .animate(delay: Duration(milliseconds: categoryIndex * 110))
            .fadeIn(duration: 380.ms)
            .slideY(
              begin: 0.18,
              end: 0,
              duration: 440.ms,
              curve: Curves.easeOutQuart,
            ),
        const SizedBox(height: 16),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: List.generate(skills.length, (skillIndex) {
              final skill = skills[skillIndex];
              return SkillChip(
                name: (skill['name'] ?? '').toString(),
                proficiency: (skill['proficiency'] as int?) ?? 0,
                index: skillIndex,
                categoryIndex: categoryIndex,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class SkillChip extends StatefulWidget {
  final String name;
  final int proficiency; // not displayed
  final int index;
  final int categoryIndex;

  const SkillChip({
    Key? key,
    required this.name,
    required this.proficiency,
    required this.index,
    required this.categoryIndex,
  }) : super(key: key);

  @override
  State<SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<SkillChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    final normalized = math.max(0, math.min(widget.proficiency, 10)) / 10.0;
    final bgOpacity = 0.11 + normalized * 0.09;
    final borderOpacity = 0.28 + normalized * 0.20;

    final delayMs = (widget.categoryIndex * 120) + (widget.index * 45);

    return MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: AnimatedScale(
            scale: _hovering ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: secondary.withOpacity(
                  _hovering ? bgOpacity + 0.04 : bgOpacity,
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: secondary.withOpacity(
                    _hovering ? borderOpacity + 0.14 : borderOpacity,
                  ),
                  width: 1.05,
                ),
                boxShadow:
                    _hovering
                        ? [
                          BoxShadow(
                            color: secondary.withOpacity(0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [],
              ),
              child: Text(
                widget.name,
                style: TextStyle(color: secondary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: delayMs))
        .fadeIn(duration: 320.ms)
        .slideY(
          begin: 0.12,
          end: 0,
          duration: 380.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
