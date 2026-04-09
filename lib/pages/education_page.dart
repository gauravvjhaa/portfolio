import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portfolio/widgets/layout.dart';
import '../main.dart';
import '../widgets/reusable.dart';

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
          .order('end_year', ascending: false, nullsFirst: true)
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
                    onRetry:
                        () => setState(
                          () => _educationFuture = _fetchEducation(),
                        ),
                  );
                }

                final education = snapshot.data ?? [];

                if (education.isEmpty) {
                  return const EmptyState(
                    message: "No education details to display yet.",
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: education.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final edu = education[index];
                    return EducationTimelineCard(
                          institution: (edu['institution'] ?? '').toString(),
                          degree: (edu['degree'] ?? '').toString(),
                          fieldOfStudy: edu['field_of_study']?.toString(),
                          startYear: edu['start_year'] as int?,
                          endYear: edu['end_year'] as int?,
                          grade: edu['grade']?.toString(),
                          location: edu['location']?.toString(),
                          description: edu['description']?.toString(),
                          isLast: index == education.length - 1,
                        )
                        .animate(delay: Duration(milliseconds: 60 * index))
                        .fadeIn(duration: 320.ms)
                        .slideY(
                          begin: 0.03,
                          end: 0,
                          curve: Curves.easeOutCubic,
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

class EducationTimelineCard extends StatelessWidget {
  final String institution;
  final String degree;
  final String? fieldOfStudy;
  final int? startYear;
  final int? endYear;
  final String? grade;
  final String? location;
  final String? description;
  final bool isLast;

  const EducationTimelineCard({
    Key? key,
    required this.institution,
    required this.degree,
    this.fieldOfStudy,
    this.startYear,
    this.endYear,
    this.grade,
    this.location,
    this.description,
    this.isLast = false,
  }) : super(key: key);

  bool get _isCurrent => endYear == null;

  String _yearRange() {
    final start = startYear;
    final end = endYear;

    if (start == null && end == null) return 'N/A';
    if (start != null && end == null) return '$start - Present';
    if (start == null && end != null) return '$end';
    if (start == end) return '$start';
    return '$start - $end';
  }

  List<String> _descriptionPoints() {
    final raw = (description ?? '').trim();
    if (raw.isEmpty) return [];

    if (raw.contains('\n')) {
      return raw
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return raw
        .split(RegExp(r'(?<=[.])\s+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    final onBg = Theme.of(context).colorScheme.onBackground;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final points = _descriptionPoints();
    final isSmall = MediaQuery.of(context).size.width < 600;
    final railWidth = isSmall ? 26.0 : 34.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: railWidth,
            child: Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  width: isSmall ? 10 : 12,
                  height: isSmall ? 10 : 12,
                  decoration: BoxDecoration(
                    color: _isCurrent ? Colors.greenAccent.shade400 : secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isCurrent ? Colors.greenAccent : secondary)
                            .withOpacity(0.30),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: secondary.withOpacity(0.22),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.94),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: secondary.withOpacity(0.14)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 14 : 18,
                  vertical: isSmall ? 14 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Responsive: Wrap instead of rigid Row
                    Wrap(
                      runSpacing: 8,
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 120,
                            maxWidth: 700,
                          ),
                          child: Text(
                            degree.isNotEmpty ? degree : 'Education',
                            softWrap: true,
                            style: TextStyle(
                              fontSize: isSmall ? 16.2 : 18,
                              fontWeight: FontWeight.w700,
                              color: onBg,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (_isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Current',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: isSmall ? 11.5 : 12.5,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Institution row responsive
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.school_rounded,
                            size: isSmall ? 14 : 15,
                            color: secondary.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            institution,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: isSmall ? 13.4 : 14.2,
                              fontWeight: FontWeight.w600,
                              color: secondary.withOpacity(0.95),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Wrap chips to next line naturally
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _EduMetaChip(
                          icon: Icons.calendar_month_rounded,
                          label: _yearRange(),
                        ),
                        if (fieldOfStudy != null &&
                            fieldOfStudy!.trim().isNotEmpty)
                          _EduMetaChip(
                            icon: Icons.auto_stories_rounded,
                            label: fieldOfStudy!.trim(),
                          ),
                        if (location != null && location!.trim().isNotEmpty)
                          _EduMetaChip(
                            icon: Icons.location_on_outlined,
                            label: location!.trim(),
                          ),
                        if (grade != null && grade!.trim().isNotEmpty)
                          _EduMetaChip(
                            icon: Icons.grade_rounded,
                            label: 'Grade: ${grade!.trim()}',
                          ),
                      ],
                    ),

                    if (points.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      ...points.map(
                        (point) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 7),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: secondary.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  point,
                                  softWrap: true,
                                  style: TextStyle(
                                    color: onSurface.withOpacity(0.95),
                                    height: 1.65,
                                    fontSize: isSmall ? 14.0 : 14.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EduMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EduMetaChip({Key? key, required this.icon, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isSmall = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 9 : 10,
        vertical: isSmall ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: secondary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 13.5 : 14.5, color: secondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isSmall ? 12.3 : 13.2,
                color: onSurface.withOpacity(0.95),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
