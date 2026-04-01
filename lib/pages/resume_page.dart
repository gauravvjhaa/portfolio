import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portfolio/widgets/layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html;
import '../widgets/reusable.dart';

class ResumePage extends StatefulWidget {
  const ResumePage({Key? key}) : super(key: key);

  @override
  State<ResumePage> createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> {
  late Future<List<Map<String, dynamic>>> _resumesFuture;

  @override
  void initState() {
    super.initState();
    _resumesFuture = _fetchResumes();
  }

  Future<List<Map<String, dynamic>>> _fetchResumes() async {
    try {
      final response = await Supabase.instance.client
          .from('resume')
          .select()
          .order('uploaded_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load resumes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: AnimatedContentContainer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle("Resume")
                          .animate()
                          .fadeIn(duration: 420.ms)
                          .slideY(
                            begin: 0.15,
                            end: 0,
                            duration: 480.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 24),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _resumesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const LoadingState();
                          }

                          if (snapshot.hasError) {
                            return ErrorState(
                              message:
                                  "Failed to load resumes. Please try again later.",
                              onRetry:
                                  () => setState(
                                    () => _resumesFuture = _fetchResumes(),
                                  ),
                            );
                          }

                          final resumes = snapshot.data ?? [];

                          if (resumes.isEmpty) {
                            return const EmptyState(
                              message: "No resumes uploaded yet.",
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                    "You can view and download all my resumes below.",
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(height: 1.6),
                                  )
                                  .animate(delay: 80.ms)
                                  .fadeIn(duration: 420.ms)
                                  .slideY(
                                    begin: 0.12,
                                    end: 0,
                                    duration: 440.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                              const SizedBox(height: 32),
                              ...List.generate(resumes.length, (index) {
                                final resume = resumes[index];
                                final fileUrl = resume['file_url'] as String;
                                final resumeUrl =
                                    fileUrl.startsWith('http')
                                        ? fileUrl
                                        : fileUrl;
                                final description = resume['description'] ?? '';
                                final uploadedAt =
                                    resume['uploaded_at'] != null
                                        ? DateTime.tryParse(
                                          resume['uploaded_at'].toString(),
                                        )
                                        : null;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 28),
                                  child: AnimatedResumeCard(
                                    index: index,
                                    resumeUrl: resumeUrl,
                                    description: description.toString(),
                                    uploadedAt: uploadedAt,
                                  ),
                                );
                              }),
                            ],
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
      },
    );
  }
}

class AnimatedResumeCard extends StatefulWidget {
  final int index;
  final String resumeUrl;
  final String description;
  final DateTime? uploadedAt;

  const AnimatedResumeCard({
    Key? key,
    required this.index,
    required this.resumeUrl,
    required this.description,
    required this.uploadedAt,
  }) : super(key: key);

  @override
  State<AnimatedResumeCard> createState() => _AnimatedResumeCardState();
}

class _AnimatedResumeCardState extends State<AnimatedResumeCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;

    return Center(
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: AnimatedScale(
              scale: _hovering ? 1.01 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                constraints: const BoxConstraints(maxWidth: 640),
                padding: const EdgeInsets.symmetric(
                  vertical: 26,
                  horizontal: 18,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant
                      .withOpacity(_hovering ? 0.22 : 0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: secondary.withOpacity(_hovering ? 0.75 : 0.4),
                  ),
                  boxShadow:
                      _hovering
                          ? [
                            BoxShadow(
                              color: secondary.withOpacity(0.18),
                              blurRadius: 24,
                              spreadRadius: 1,
                              offset: const Offset(0, 8),
                            ),
                          ]
                          : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined, size: 82, color: secondary)
                        .animate(target: _hovering ? 1 : 0)
                        .scaleXY(
                          end: 1.06,
                          duration: 220.ms,
                          curve: Curves.easeOut,
                        ),
                    const SizedBox(height: 20),
                    Text(
                      "Resume",
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.description.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        widget.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                    if (widget.uploadedAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Uploaded: ${widget.uploadedAt!.toLocal().toString().split(' ').first}",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.72),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 14,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _ActionButton(
                          icon: Icons.visibility,
                          label: 'View Resume',
                          filled: true,
                          onTap: () {
                            html.window.open(widget.resumeUrl, 'Resume');
                          },
                        ),
                        _ActionButton(
                          icon: Icons.download,
                          label: 'Download PDF',
                          filled: false,
                          onTap: () {
                            html.AnchorElement(href: widget.resumeUrl)
                              ..setAttribute(
                                'download',
                                'Gaurav_Jha_Resume.pdf',
                              )
                              ..click();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 120 * widget.index))
        .fadeIn(duration: 420.ms)
        .slideY(
          begin: 0.16,
          end: 0,
          duration: 460.ms,
          curve: Curves.easeOutCubic,
        )
        .scaleXY(
          begin: 0.985,
          end: 1.0,
          duration: 420.ms,
          curve: Curves.easeOut,
        );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;

    final child =
        widget.filled
            ? ElevatedButton.icon(
              icon: Icon(widget.icon),
              label: Text(widget.label),
              onPressed: widget.onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: secondary,
                foregroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _hovering ? 8 : 2,
              ),
            )
            : OutlinedButton.icon(
              icon: Icon(widget.icon),
              label: Text(widget.label),
              onPressed: widget.onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: secondary,
                side: BorderSide(color: secondary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}
