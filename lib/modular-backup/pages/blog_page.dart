import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../widgets/components.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({Key? key}) : super(key: key);

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  late Future<List<Map<String, dynamic>>> _blogsFuture;

  @override
  void initState() {
    super.initState();
    _blogsFuture = _fetchBlogs();
  }

  Future<List<Map<String, dynamic>>> _fetchBlogs() async {
    try {
      final response = await supabase
          .from('blogs')
          .select()
          .eq('is_published', true)
          .order('published_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load blogs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Blog'),
            const SizedBox(height: 24),
            Text(
              "Welcome to my blog! Here you'll find posts about my journey, tips, and technical deep-dives.",
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 32),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _blogsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState();
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    message:
                        "Failed to load blog posts. Please try again later.",
                    onRetry: () => setState(
                        () => _blogsFuture = _fetchBlogs()),
                  );
                }

                final blogs = snapshot.data ?? [];

                if (blogs.isEmpty) {
                  return const EmptyState(
                    message: "No blog posts yet. Come back soon!",
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: blogs.length,
                  itemBuilder: (context, index) {
                    final blog = blogs[index];
                    return BlogPostCard(
                      title: blog['title'] ?? '',
                      slug: blog['slug'] ?? '',
                      summary: blog['summary'] ?? '',
                      content: blog['content'] ?? '',
                      publishedAt: blog['published_at'] != null
                          ? DateTime.parse(blog['published_at'])
                          : DateTime.now(),
                      tags: (blog['tags'] as List<dynamic>?)
                              ?.cast<String>() ??
                          [],
                      coverImage: blog['cover_image_url'],
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

class BlogPostCard extends StatefulWidget {
  final String title;
  final String slug;
  final String summary;
  final String content;
  final DateTime publishedAt;
  final List<String> tags;
  final String? coverImage;

  const BlogPostCard({
    Key? key,
    required this.title,
    required this.slug,
    required this.summary,
    required this.content,
    required this.publishedAt,
    required this.tags,
    this.coverImage,
  }) : super(key: key);

  @override
  State<BlogPostCard> createState() => _BlogPostCardState();
}

class _BlogPostCardState extends State<BlogPostCard> {
  bool _expanded = false;

  String _formatDate(DateTime date) {
    final formatter = DateFormat('MMM d, yyyy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.coverImage != null && widget.coverImage!.isNotEmpty;
    final imageUrl = hasImage
        ? (widget.coverImage!.startsWith('http')
            ? widget.coverImage!
            : '$storageUrl/blog/${widget.coverImage}')
        : null;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 24),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _expanded = !_expanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if (imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.fitHeight,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      width: double.infinity,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.1),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color:
                            Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _expanded ? Icons.unfold_less : Icons.unfold_more,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _expanded = !_expanded;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(widget.publishedAt),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.summary,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.6,
                  fontSize: 16,
                ),
              ),
              if (_expanded) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                MarkdownBody(
                  data: widget.content,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.6,
                    ),
                    h1: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                    h2: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                    h3: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                    code: TextStyle(
                      backgroundColor:
                          Theme.of(context).colorScheme.background,
                      color:
                          Theme.of(context).colorScheme.secondary,
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.12),
                        labelStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary,
                          fontSize: 13,
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms);
  }
}