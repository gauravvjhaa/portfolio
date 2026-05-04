import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main.dart';
import '../widgets/reusable.dart';

class BlogDetailsPage extends StatefulWidget {
  final String slug;
  final Map<String, dynamic>? initialBlog;

  const BlogDetailsPage({Key? key, required this.slug, this.initialBlog})
      : super(key: key);

  @override
  State<BlogDetailsPage> createState() => _BlogDetailsPageState();
}

class _BlogDetailsPageState extends State<BlogDetailsPage> {
  late Future<Map<String, dynamic>> _blogFuture;

  @override
  void initState() {
    super.initState();
    _blogFuture = _resolveBlog();
  }

  Future<Map<String, dynamic>> _resolveBlog() async {
    if (widget.initialBlog != null) return widget.initialBlog!;

    final response = await supabase
        .from('blogs')
        .select()
        .eq('slug', widget.slug)
        .eq('is_published', true)
        .maybeSingle();

    if (response == null) {
      throw Exception('Blog not found');
    }

    return Map<String, dynamic>.from(response);
  }

  DateTime _parseDate(dynamic value) {
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  int _estimateReadMinutes(String text) {
    final words =
        text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    return ((words / 200).ceil()).clamp(1, 99);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<Map<String, dynamic>>(
      future: _blogFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              child: Text(
                'Blog not found.',
                style: TextStyle(color: cs.onBackground),
              ),
            ),
          );
        }

        final blog = snapshot.data!;
        final title = (blog['title'] ?? '').toString();
        final summary = (blog['summary'] ?? '').toString();
        final content = (blog['content'] ?? '').toString();
        final tags = (blog['tags'] as List<dynamic>?)?.cast<String>() ?? [];
        final publishedAt = _parseDate(blog['published_at']);
        final readMins = _estimateReadMinutes(content);

        final cover = blog['cover_image_url']?.toString();
        final imageUrl = (cover != null && cover.isNotEmpty)
            ? (cover.startsWith('http') ? cover : '$storageUrl/blog/$cover')
            : null;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 860),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  children: [
                    // ── BLOG TITLE ────────────────────────
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            color: cs.onBackground,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 14),

                    // ── META INFO ─────────────────────────
                    Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 16, color: cs.secondary),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('MMM d, yyyy').format(publishedAt),
                              style: TextStyle(
                                color: cs.onSurface.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded,
                                size: 16, color: cs.secondary),
                            const SizedBox(width: 6),
                            Text(
                              '$readMins min read',
                              style: TextStyle(
                                color: cs.onSurface.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (imageUrl != null) ...[
                      const SizedBox(height: 28),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: cs.surface,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: cs.surface,
                            child: Center(
                              child: Icon(Icons.broken_image_rounded,
                                  color: cs.secondary, size: 40),
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (summary.isNotEmpty) ...[
                      const SizedBox(height: 26),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cs.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cs.outline.withOpacity(0.15)),
                        ),
                        child: Text(
                          summary,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: cs.onBackground.withOpacity(0.9),
                                height: 1.65,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ── MARKDOWN CONTENT ─────────────────
                    MarkdownBody(
                      data: content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: cs.onBackground.withOpacity(0.92),
                          fontSize: 18,
                          height: 1.8,
                        ),
                        h1: TextStyle(
                          color: cs.onBackground,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                        h2: TextStyle(
                          color: cs.onBackground,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                        h3: TextStyle(
                          color: cs.onBackground,
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                        h4: TextStyle(
                          color: cs.onBackground,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        strong: TextStyle(
                          color: cs.onBackground,
                          fontWeight: FontWeight.w800,
                        ),
                        em: TextStyle(
                          color: cs.onBackground.withOpacity(0.95),
                          fontStyle: FontStyle.italic,
                        ),
                        blockquote: TextStyle(
                          color: cs.onBackground.withOpacity(0.88),
                          fontSize: 17,
                          height: 1.7,
                        ),
                        blockquoteDecoration: BoxDecoration(
                          color: cs.surface.withOpacity(0.38),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(
                              color: cs.secondary.withOpacity(0.65),
                              width: 4,
                            ),
                          ),
                        ),
                        listBullet: TextStyle(
                          color: cs.secondary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        code: TextStyle(
                          color: cs.secondary,
                          fontFamily: 'monospace',
                          backgroundColor: cs.surface.withOpacity(0.55),
                          fontSize: 15,
                        ),
                        codeblockPadding: const EdgeInsets.all(14),
                        codeblockDecoration: BoxDecoration(
                          color: cs.surface.withOpacity(0.70),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: cs.outline.withOpacity(0.22),
                          ),
                        ),
                        horizontalRuleDecoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: cs.outline.withOpacity(0.35),
                              width: 1,
                            ),
                          ),
                        ),
                        a: TextStyle(
                          color: cs.secondary,
                          decoration: TextDecoration.underline,
                          decorationColor: cs.secondary.withOpacity(0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                backgroundColor:
                                    cs.secondary.withOpacity(0.12),
                                labelStyle: TextStyle(
                                  color: cs.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
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