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
      // Ensure response is List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load resumes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to avoid overflows and adapt to screen size
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
                      const SectionTitle("Resume"),
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
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(height: 1.6),
                              ),
                              const SizedBox(height: 32),
                              ...resumes.map((resume) {
                                final fileUrl = resume['file_url'] as String;
                                final resumeUrl =
                                    fileUrl.startsWith('http')
                                        ? fileUrl
                                        : fileUrl; // Adjust if you use a storageUrl
                                final description = resume['description'] ?? '';
                                final uploadedAt =
                                    resume['uploaded_at'] != null
                                        ? DateTime.tryParse(
                                          resume['uploaded_at'].toString(),
                                        )
                                        : null;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 40),
                                  child: Center(
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 600,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.description_outlined,
                                            size: 80,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            "Resume",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.headlineSmall?.copyWith(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onBackground,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (description.isNotEmpty) ...[
                                            const SizedBox(height: 16),
                                            Text(
                                              description,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                          if (uploadedAt != null) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              "Uploaded: ${uploadedAt.toLocal().toString().split(' ').first}",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.7),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 24),
                                          Wrap(
                                            spacing: 16,
                                            alignment: WrapAlignment.center,
                                            children: [
                                              ElevatedButton.icon(
                                                icon: const Icon(
                                                  Icons.visibility,
                                                ),
                                                label: const Text(
                                                  'View Resume',
                                                ),
                                                onPressed: () {
                                                  html.window.open(
                                                    resumeUrl,
                                                    'Resume',
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.secondary,
                                                  foregroundColor:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.surface,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 16,
                                                      ),
                                                ),
                                              ),
                                              OutlinedButton.icon(
                                                icon: const Icon(
                                                  Icons.download,
                                                ),
                                                label: const Text(
                                                  'Download PDF',
                                                ),
                                                onPressed: () {
                                                  html.AnchorElement(
                                                      href: resumeUrl,
                                                    )
                                                    ..setAttribute(
                                                      'download',
                                                      'Gaurav_Jha_Resume.pdf',
                                                    )
                                                    ..click();
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.secondary,
                                                  side: BorderSide(
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.secondary,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 16,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
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
