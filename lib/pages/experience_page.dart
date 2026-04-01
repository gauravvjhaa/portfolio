import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // For supabase client
import '../widgets/layout.dart';
import '../widgets/reusable.dart';

class ExperiencePage extends StatefulWidget {
  const ExperiencePage({Key? key}) : super(key: key);

  @override
  State<ExperiencePage> createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> {
  late Future<List<Map<String, dynamic>>> _experienceFuture;

  @override
  void initState() {
    super.initState();
    _experienceFuture = _fetchExperience();
  }

  Future<List<Map<String, dynamic>>> _fetchExperience() async {
    try {
      final response = await supabase
          .from('experience')
          .select()
          .order('start_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load experience: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle("Experience"),
            const SizedBox(height: 24),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _experienceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState();
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    message: "Failed to load experience data. Please try again later.",
                    onRetry: () => setState(() => _experienceFuture = _fetchExperience()),
                  );
                }

                final experiences = snapshot.data ?? [];

                if (experiences.isEmpty) {
                  return const EmptyState(
                    message: "No work experience to display yet.",
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: experiences.length,
                  itemBuilder: (context, index) {
                    final exp = experiences[index];
                    return ExperienceCard(
                      organization: exp['organization'] ?? '',
                      title: exp['title'] ?? '',
                      location: exp['location'],
                      description: exp['description'] ?? '',
                      startDate: exp['start_date'] != null
                          ? DateTime.parse(exp['start_date'])
                          : null,
                      endDate: exp['end_date'] != null ? DateTime.parse(exp['end_date']) : null,
                      isCurrent: exp['is_current'] ?? false,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ExperienceCard extends StatelessWidget {
  final String organization;
  final String title;
  final String? location;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;

  const ExperienceCard({
    Key? key,
    required this.organization,
    required this.title,
    this.location,
    required this.description,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final formatter = DateFormat('MMM yyyy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        organization,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.green.withOpacity(0.2)
                        : Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_formatDate(startDate)} - ${isCurrent ? 'Present' : _formatDate(endDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isCurrent ? Colors.green : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            if (location != null && location!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    location!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }
}