import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../main.dart';
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 720;

    return SingleChildScrollView(
      child: AnimatedContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
              child: const SectionTitle("Projects"),
            ),

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
                    onRetry: () {
                      setState(() {
                        _projectsFuture = _fetchProjects();
                      });
                    },
                  );
                }

                final projects = snapshot.data ?? [];

                if (projects.isEmpty) {
                  return const EmptyState(
                    message: "No projects to show yet. Check back soon!",
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;

                    final int columns =
                        maxWidth >= 1100 ? 3 : (maxWidth >= 720 ? 2 : 1);

                    final double spacing = 20;
                    final double cardWidth =
                        (maxWidth - (spacing * (columns - 1))) / columns;

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Wrap(
                        key: ValueKey(projects.length),
                        spacing: spacing,
                        runSpacing: spacing,
                        children: List.generate(projects.length, (index) {
                          final project = projects[index];

                          return SizedBox(
                            width: cardWidth,
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
                        }),
                      ),
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
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        transform: isHovered
            ? (Matrix4.identity()..translate(0.0, -3.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHovered
                ? colorScheme.secondary.withOpacity(0.28)
                : colorScheme.onSurface.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? colorScheme.secondary.withOpacity(0.14)
                  : Colors.black.withOpacity(0.18),
              blurRadius: isHovered ? 20 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null) _ProjectImage(imageUrl),
                if (imageUrl != null) const SizedBox(height: 14),

                Text(
                  widget.title,
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      showFullDescription = !showFullDescription;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.description,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.92),
                          fontSize: 13.7,
                          height: 1.55,
                        ),
                        maxLines: showFullDescription ? null : 4,
                        overflow: showFullDescription
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                      if (widget.description.length > 190)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            showFullDescription ? "Show less" : "Read more",
                            style: TextStyle(
                              color: colorScheme.secondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                _TagsRow(colorScheme: colorScheme, tags: widget.tags),

                const SizedBox(height: 14),

                _ActionRow(
                  colorScheme: colorScheme,
                  liveUrl: widget.liveUrl,
                  githubUrl: widget.githubUrl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectImage extends StatelessWidget {
  final String imageUrl;

  const _ProjectImage(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: 140,
        fit: BoxFit.cover,
        memCacheWidth: 700,
        maxWidthDiskCache: 900,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (context, url) => Container(
          height: 140,
          width: double.infinity,
          color: colorScheme.secondary.withOpacity(0.055),
          alignment: Alignment.center,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.secondary.withOpacity(0.75),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 140,
          width: double.infinity,
          color: colorScheme.secondary.withOpacity(0.08),
          alignment: Alignment.center,
          child: Icon(
            Icons.image_not_supported_outlined,
            color: colorScheme.secondary,
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

    return Row(
      children: [
        if (hasLive)
          Expanded(
            child: _ProjectLinkButton(
              label: "Demo",
              icon: Icons.play_arrow_rounded,
              colorScheme: colorScheme,
              onPressed: () {
                launchUrl(
                  Uri.parse(liveUrl!),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
          ),
        if (hasLive && hasSource) const SizedBox(width: 10),
        if (hasSource)
          Expanded(
            child: _ProjectLinkButton(
              label: "Code",
              icon: Icons.code_rounded,
              colorScheme: colorScheme,
              onPressed: () {
                launchUrl(
                  Uri.parse(githubUrl!),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ProjectLinkButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final ColorScheme colorScheme;
  final VoidCallback onPressed;

  const _ProjectLinkButton({
    required this.label,
    required this.icon,
    required this.colorScheme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 17,
        color: Colors.white,
      ),
      label: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(
          color: colorScheme.secondary.withOpacity(0.35),
          width: 1,
        ),
        backgroundColor: colorScheme.secondary.withOpacity(0.045),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _TagsRow extends StatefulWidget {
  final ColorScheme colorScheme;
  final List<String> tags;

  const _TagsRow({
    required this.colorScheme,
    required this.tags,
  });

  @override
  State<_TagsRow> createState() => _TagsRowState();
}

class _TagsRowState extends State<_TagsRow> {
  bool showAllTags = false;

  @override
  Widget build(BuildContext context) {
    if (widget.tags.isEmpty) return const SizedBox.shrink();

    final visibleTags = showAllTags ? widget.tags : widget.tags.take(4).toList();
    final remaining = widget.tags.length - 4;

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        ...visibleTags.map(
          (tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: widget.colorScheme.secondary.withOpacity(0.075),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: widget.colorScheme.secondary.withOpacity(0.18),
              ),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 11,
                color: widget.colorScheme.secondary.withOpacity(0.95),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        if (remaining > 0)
          GestureDetector(
            onTap: () {
              setState(() {
                showAllTags = !showAllTags;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: widget.colorScheme.onSurface.withOpacity(0.06),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: widget.colorScheme.onSurface.withOpacity(0.12),
                ),
              ),
              child: Text(
                showAllTags ? "LESS" : "+$remaining",
                style: TextStyle(
                  fontSize: 11,
                  color: widget.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}