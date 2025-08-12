import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../supabase_client.dart';
import '../widgets/components.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({Key? key}) : super(key: key);

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  late Future<List<Map<String, dynamic>>> _educationFuture;

  @override
  void initState() {
    super.initState();
    _educationFuture = _fetchEducation();
  }

  Future<List<Map<String, dynamic>>> _fetchEducation() async {
    try {
      final response = await supabase
          .from('education')
          .select()
          .order('start_year', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load education: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle("Education"),
            const SizedBox(height: 24),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _educationFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState();
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    message:
                        "Failed to load education data. Please try again later.",
                    onRetry: () => setState(
                        () => _educationFuture = _fetchEducation()),
                  );
                }

                final education = snapshot.data ?? [];

                if (education.isEmpty) {
                  return const EmptyState(
                    message: "No education details to display yet.",
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: education.length,
                  itemBuilder: (context, index) {
                    final edu = education[index];
                    return EducationCard(
                      institution: edu['institution'] ?? '',
                      degree: edu['degree'] ?? '',
                      fieldOfStudy: edu['field_of_study'],
                      startYear: edu['start_year'] as int? ?? 0,
                      endYear: edu['end_year'] as int?,
                      grade: edu['grade'],
                      location: edu['location'],
                      description: edu['description'],
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

class EducationCard extends StatelessWidget {
  final String institution;
  final String degree;
  final String? fieldOfStudy;
  final int startYear;
  final int? endYear;
  final String? grade;
  final String? location;
  final String? description;

  const EducationCard({
    Key? key,
    required this.institution,
    required this.degree,
    this.fieldOfStudy,
    required this.startYear,
    this.endYear,
    this.grade,
    this.location,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isCurrent = endYear == null;
    final yearText = '$startYear - ${isCurrent ? 'Present' : endYear}';

    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 24),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        degree,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        institution,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    yearText,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            if (fieldOfStudy != null && fieldOfStudy!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                fieldOfStudy!,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
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
            if (grade != null && grade!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.grade,
                    size: 16,
                    color:
                        Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Grade: $grade',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                description!,
                style: TextStyle(
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }
}