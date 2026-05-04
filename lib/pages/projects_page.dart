import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart'; // For supabase client and storageUrl
import '../widgets/layout.dart';
import '../widgets/reusable.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({Key? key}) : super(key: key);

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late Future<List<Map<String, dynamic>>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = _fetchProjects();
  }

  Future<List<Map<String, dynamic>>> _fetchProjects() async {
    try {
      final response = await supabase
          .from('projects')
          .select()
          .order('s_no', ascending: true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load projects: $e');
    }
  }

  // Responsive padding matching your blog & contact pages
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
                    const SectionTitle("Projects"),
                    const SizedBox(height: 24),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _projectsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const LoadingState();
                        }

                        if (snapshot.hasError) {
                          return ErrorState(
                            message: "Failed to load projects. Please try again later.",
                            onRetry: () =>
                                setState(() => _projectsFuture = _fetchProjects()),
                          );
                        }

                        final projects = snapshot.data ?? [];

                        if (projects.isEmpty) {
                          return const EmptyState(
                            message: "No projects to show yet. Check back soon!",
                          );
                        }

                        return Responsive(
                          mobile: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: projects.length,
                            itemBuilder: (context, index) {
                              final project = projects[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: ProjectCard(
                                  title: project['title'] ?? "",
                                  description: project['description'] ?? "",
                                  tags: (project['tags'] as List<dynamic>?)
                                          ?.cast<String>() ??
                                      const [],
                                  image: project['cover_image_url'],
                                  githubUrl: project['github_url'],
                                  liveUrl: project['live_url'],
                                ),
                              );
                            },
                          ),
                          desktop: Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: projects.map((project) {
                              return SizedBox(
                                width: (constraints.maxWidth - 40) / 3,
                                child: ProjectCard(
                                  title: project['title'] ?? "",
                                  description: project['description'] ?? "",
                                  tags: (project['tags'] as List<dynamic>?)
                                          ?.cast<String>() ??
                                      const [],
                                  image: project['cover_image_url'],
                                  githubUrl: project['github_url'],
                                  liveUrl: project['live_url'],
                                ),
                              );
                            }).toList(),
                          ),
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

class ProjectCard extends StatefulWidget {
  final String title;
  final String description;
  final List<String> tags;
  final String? image;
  final String? githubUrl;
  final String? liveUrl;

  const ProjectCard({
    Key? key,
    required this.title,
    required this.description,
    required this.tags,
    this.image,
    this.githubUrl,
    this.liveUrl,
  }) : super(key: key);

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool isHovered = false;
  bool showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hasImage = widget.image != null && widget.image!.isNotEmpty;
    final imageUrl = hasImage
        ? (widget.image!.startsWith('http')
            ? widget.image!
            : '$storageUrl/projects/${widget.image}')
        : null;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: isHovered
            ? (Matrix4.identity()..translate(0.0, -4.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? colorScheme.secondary.withOpacity(0.25)
                  : Colors.black.withOpacity(0.18),
              blurRadius: isHovered ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null)
                  _ProjectImage(imageUrl, widget.title),
                if (imageUrl != null) const SizedBox(height: 12),
                _ActionRow(
                  colorScheme: colorScheme,
                  liveUrl: widget.liveUrl,
                  githubUrl: widget.githubUrl,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () =>
                      setState(() => showFullDescription = !showFullDescription),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.description,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        maxLines: showFullDescription ? null : 4,
                        overflow: showFullDescription
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                      if (widget.description.length > 200)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            showFullDescription ? "Show less" : "Read more",
                            style: TextStyle(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _TagsRow(colorScheme: colorScheme, tags: widget.tags),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms, delay: 30.ms);
  }
}

class _ProjectImage extends StatelessWidget {
  final String imageUrl;
  final String title;

  const _ProjectImage(this.imageUrl, this.title);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FullScreenImagePage(imageUrl: imageUrl, title: title),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 140,
            maxWidth: double.infinity,
          ),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            memCacheWidth: 400,   // down‑sample to typical card width
            memCacheHeight: 140,
            placeholder: (context, url) => Container(
              color: colorScheme.surfaceVariant.withOpacity(0.2),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 80,
              color: colorScheme.secondary.withOpacity(0.1),
              child: Icon(
                Icons.image_not_supported,
                color: colorScheme.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final ColorScheme colorScheme;
  final String? liveUrl;
  final String? githubUrl;

  const _ActionRow({
    required this.colorScheme,
    required this.liveUrl,
    required this.githubUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasLive = liveUrl != null && liveUrl!.isNotEmpty;
    final hasSource = githubUrl != null && githubUrl!.isNotEmpty;

    if (!hasLive && !hasSource) return const SizedBox.shrink();

    final baseStyle = OutlinedButton.styleFrom(
      side: BorderSide(color: colorScheme.outline.withOpacity(0.5), width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      foregroundColor: colorScheme.onSurface,
      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (hasLive)
          OutlinedButton.icon(
            onPressed: () => launchUrl(Uri.parse(liveUrl!)),
            style: baseStyle.copyWith(
              overlayColor: WidgetStateProperty.all(
                colorScheme.secondary.withOpacity(0.08),
              ),
            ),
            icon: Icon(
              Icons.play_arrow_rounded,
              size: 18,
              color: colorScheme.secondary,
            ),
            label: const Text("Demo"),
          )
        else
          const SizedBox.shrink(),
        if (hasSource)
          OutlinedButton.icon(
            onPressed: () => launchUrl(Uri.parse(githubUrl!)),
            style: baseStyle.copyWith(
              overlayColor: WidgetStateProperty.all(
                colorScheme.secondary.withOpacity(0.08),
              ),
            ),
            icon: Icon(
              Icons.code_rounded,
              size: 18,
              color: colorScheme.secondary,
            ),
            label: const Text("Code"),
          ),
      ],
    );
  }
}

class _TagsRow extends StatelessWidget {
  final ColorScheme colorScheme;
  final List<String> tags;

  const _TagsRow({required this.colorScheme, required this.tags});

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags
          .map(
            (tag) => Chip(
              label: Text(
                tag,
                style: TextStyle(fontSize: 11, color: colorScheme.secondary),
              ),
              backgroundColor: colorScheme.secondary.withOpacity(0.1),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )
          .toList(),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String title;

  const FullScreenImagePage({
    Key? key,
    required this.imageUrl,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, overflow: TextOverflow.ellipsis),
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 4,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.broken_image,
              color: Colors.white54,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}