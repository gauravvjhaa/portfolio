import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portfolio/widgets/layout.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/reusable.dart';
import '../main.dart'; // For supabase client

class OpenSourcePage extends StatefulWidget {
  const OpenSourcePage({Key? key}) : super(key: key);

  @override
  State<OpenSourcePage> createState() => _OpenSourcePageState();
}

class _OpenSourcePageState extends State<OpenSourcePage> {
  late Future<List<Map<String, dynamic>>> _opensourceFuture;

  @override
  void initState() {
    super.initState();
    _opensourceFuture = _fetchOpenSource();
  }

  Future<List<Map<String, dynamic>>> _fetchOpenSource() async {
    try {
      final response = await supabase
          .from('opensource')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load open source contributions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle("Open Source"),
            const SizedBox(height: 24),
            Text(
              "My contributions to open source projects and the developer community.",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(height: 1.6),
            ),
            const SizedBox(height: 32),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _opensourceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState();
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    message:
                        "Failed to load open source contributions. Please try again later.",
                    onRetry:
                        () => setState(
                          () => _opensourceFuture = _fetchOpenSource(),
                        ),
                  );
                }

                final repos = snapshot.data ?? [];

                if (repos.isEmpty) {
                  return const EmptyState(
                    message: "No open source contributions yet.",
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: repos.length,
                  itemBuilder: (context, index) {
                    final repo = repos[index];
                    return OpenSourceCard(
                      repoName: repo['repo_name'] ?? '',
                      repoUrl: repo['repo_url'] ?? '',
                      description: repo['description'] ?? '',
                      contributions: repo['contributions'],
                      tags:
                          (repo['tags'] as List<dynamic>?)?.cast<String>() ??
                          [],
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

class OpenSourceCard extends StatelessWidget {
  final String repoName;
  final String repoUrl;
  final String description;
  final String? contributions;
  final List<String> tags;

  const OpenSourceCard({
    Key? key,
    required this.repoName,
    required this.repoUrl,
    required this.description,
    this.contributions,
    required this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          launchUrl(Uri.parse(repoUrl));
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.code, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      repoName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () {
                      launchUrl(Uri.parse(repoUrl));
                    },
                    tooltip: 'Visit Repository',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              if (contributions != null && contributions!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'My Contributions:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  contributions!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.12),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 13,
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
