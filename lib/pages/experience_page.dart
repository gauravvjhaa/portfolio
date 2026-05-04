import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart'; // supabase client
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
          .order('is_current', ascending: false)
          .order('start_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load experience: $e');
    }
  }

  // Responsive padding – same as your other pages
  EdgeInsets _pagePadding(double width) {
    if (width < 600) return const EdgeInsets.symmetric(horizontal: 14);
    if (width < 900) return const EdgeInsets.symmetric(horizontal: 18);
    return const EdgeInsets.symmetric(horizontal: 24);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pad = _pagePadding(constraints.maxWidth);
        return SingleChildScrollView(
          padding: pad.copyWith(top: 48, bottom: 48),
          child: Center(
            child: AnimatedContentContainer(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle("Experience"),
                    const SizedBox(height: 24),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _experienceFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LoadingState();
                        }

                        if (snapshot.hasError) {
                          return ErrorState(
                            message:
                                "Failed to load experience data. Please try again later.",
                            onRetry: () => setState(
                                () => _experienceFuture = _fetchExperience()),
                          );
                        }

                        final experiences = snapshot.data ?? [];

                        if (experiences.isEmpty) {
                          return const EmptyState(
                            message: "No work experience to display yet.",
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: experiences.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 18),
                          itemBuilder: (context, index) {
                            final exp = experiences[index];
                            return ExperienceTimelineCard(
                                  organization: exp['organization'] ?? '',
                                  title: exp['title'] ?? '',
                                  location: exp['location'],
                                  description:
                                      (exp['description'] ?? '').toString(),
                                  startDate: exp['start_date'] != null
                                      ? DateTime.tryParse(
                                          exp['start_date'].toString())
                                      : null,
                                  endDate: exp['end_date'] != null
                                      ? DateTime.tryParse(
                                          exp['end_date'].toString())
                                      : null,
                                  isCurrent: exp['is_current'] ?? false,
                                  liveLink: (exp['live'] ?? '').toString(),
                                  isLast: index == experiences.length - 1,
                                )
                                .animate(
                                    delay:
                                        Duration(milliseconds: 70 * index))
                                .fadeIn(duration: 380.ms)
                                .slideY(
                                  begin: 0.04,
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
            ),
          ),
        );
      },
    );
  }
}

class ExperienceTimelineCard extends StatelessWidget {
  final String organization;
  final String title;
  final String? location;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String liveLink;
  final bool isLast;

  const ExperienceTimelineCard({
    Key? key,
    required this.organization,
    required this.title,
    this.location,
    required this.description,
    this.startDate,
    this.endDate,
    required this.isCurrent,
    required this.liveLink,
    this.isLast = false,
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM yyyy').format(date);
  }

  String _dateRange() {
    final start = _formatDate(startDate);
    final end = isCurrent ? 'Present' : _formatDate(endDate);
    if (start.isEmpty && end.isEmpty) return 'Date not specified';
    if (start.isEmpty) return end;
    if (end.isEmpty) return start;
    return '$start - $end';
  }

  String _duration() {
    if (startDate == null) return '';
    final effectiveEnd =
        isCurrent ? DateTime.now() : (endDate ?? DateTime.now());
    if (effectiveEnd.isBefore(startDate!)) return '';

    int months = (effectiveEnd.year - startDate!.year) * 12 +
        (effectiveEnd.month - startDate!.month);

    if (effectiveEnd.day < startDate!.day) months -= 1;
    if (months < 1) return '< 1 month';

    final years = months ~/ 12;
    final remMonths = months % 12;

    if (years > 0 && remMonths > 0) return '$years yr ${remMonths} months';
    if (years > 0) return '$years yr';
    return '$remMonths months';
  }

  List<String> _descriptionPoints() {
    final raw = description.trim();
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

  Future<void> _openLiveLink(BuildContext context) async {
    String url = liveLink.trim();
    if (url.isEmpty) return;

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open live link')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    final onBg = Theme.of(context).colorScheme.onBackground;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final points = _descriptionPoints();
    final duration = _duration();
    final hasLive = liveLink.trim().isNotEmpty;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isCurrent ? Colors.greenAccent.shade400 : secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isCurrent ? Colors.greenAccent : secondary)
                            .withOpacity(0.35),
                        blurRadius: 10,
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
                      color: secondary.withOpacity(0.25),
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
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: onBg,
                            height: 1.3,
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Current',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.business_rounded,
                          size: 15,
                          color: secondary.withOpacity(0.9),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            organization,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.2,
                              fontWeight: FontWeight.w600,
                              color: secondary.withOpacity(0.95),
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          icon: Icons.calendar_month_rounded,
                          label: _dateRange(),
                        ),
                        if (duration.isNotEmpty)
                          _MetaChip(
                            icon: Icons.timelapse_rounded,
                            label: duration,
                          ),
                        if (location != null && location!.trim().isNotEmpty)
                          _MetaChip(
                            icon: Icons.location_on_outlined,
                            label: location!.trim(),
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
                                  style: TextStyle(
                                    color: onSurface.withOpacity(0.95),
                                    height: 1.65,
                                    fontSize: 14.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (hasLive) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => _openLiveLink(context),
                          icon:
                              const Icon(Icons.open_in_new_rounded, size: 17),
                          label: const Text('View Live'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: secondary,
                            side: BorderSide(
                              color: secondary.withOpacity(0.45),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
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

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({Key? key, required this.icon, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: secondary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.5, color: secondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.2,
              color: onSurface.withOpacity(0.95),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}