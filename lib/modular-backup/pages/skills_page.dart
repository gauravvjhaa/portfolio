import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../supabase_client.dart';
import '../widgets/components.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({Key? key}) : super(key: key);

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  late Future<List<Map<String, dynamic>>> _skillsFuture;

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
          .order('category', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load skills: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle("Skills"),
            const SizedBox(height: 24),
            Text(
              "Here are the technologies and skills I've acquired throughout my journey:",
              style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.6),
            ),
            const SizedBox(height: 32),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _skillsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState();
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    message: "Failed to load skills. Please try again later.",
                    onRetry: () =>
                        setState(() => _skillsFuture = _fetchSkills()),
                  );
                }

                final skills = snapshot.data ?? [];

                if (skills.isEmpty) {
                  return const EmptyState(
                      message: "No skills to display yet.");
                }

                final Map<String, List<Map<String, dynamic>>> skillsByCategory =
                    {};
                for (var skill in skills) {
                  final category = skill['category'] as String? ?? 'Other';
                  skillsByCategory.putIfAbsent(category, () => []);
                  skillsByCategory[category]!.add(skill);
                }

                return Column(
                  children: skillsByCategory.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: entry.value.map((skill) {
                            return SkillChip(
                              name: skill['name'] ?? '',
                              proficiency:
                                  skill['proficiency'] as int? ?? 0,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SkillChip extends StatelessWidget {
  final String name;
  final int proficiency;

  const SkillChip({Key? key, required this.name, required this.proficiency})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.secondary.withOpacity(0.13),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$proficiency/10',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }
}