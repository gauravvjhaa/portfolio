import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../widgets/reusable.dart';

enum TimeFilter { all, last7Days, last30Days, thisYear }

class BlogPage extends StatefulWidget {
  const BlogPage({Key? key}) : super(key: key);

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  late Future<List<Map<String, dynamic>>> _blogsFuture;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  TimeFilter _timeFilter = TimeFilter.all;
  String? _selectedTag;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _blogsFuture = _fetchBlogs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() => _searchQuery = _searchController.text.trim());
    });
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

  DateTime? _timeFilterStart(TimeFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case TimeFilter.all:
        return null;
      case TimeFilter.last7Days:
        return now.subtract(const Duration(days: 7));
      case TimeFilter.last30Days:
        return now.subtract(const Duration(days: 30));
      case TimeFilter.thisYear:
        return DateTime(now.year, 1, 1);
    }
  }

  List<String> _extractTags(List<Map<String, dynamic>> blogs) {
    final set = <String>{};
    for (final blog in blogs) {
      final tags = (blog['tags'] as List<dynamic>?)?.cast<String>() ?? [];
      set.addAll(tags.map((e) => e.trim()).where((e) => e.isNotEmpty));
    }
    final list = set.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> blogs) {
    final start = _timeFilterStart(_timeFilter);
    final q = _searchQuery.toLowerCase();

    return blogs.where((blog) {
      final publishedAt = _parseDate(blog['published_at']);
      final title = (blog['title'] ?? '').toString().toLowerCase();
      final summary = (blog['summary'] ?? '').toString().toLowerCase();
      final content = (blog['content'] ?? '').toString().toLowerCase();
      final tags = (blog['tags'] as List<dynamic>?)?.cast<String>() ?? [];
      final tagsString = tags.join(' ').toLowerCase();

      final matchesSearch = q.isEmpty ||
          title.contains(q) ||
          summary.contains(q) ||
          content.contains(q) ||
          tagsString.contains(q);

      final matchesTime = start == null || !publishedAt.isBefore(start);
      final matchesTag = _selectedTag == null || tags.contains(_selectedTag);

      return matchesSearch && matchesTime && matchesTag;
    }).toList();
  }

  int _gridColumns(double width) {
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 650) return 2;
    return 1;
  }

  double _cardAspectRatio(double width) {
    if (width < 450) return 1.18;
    if (width < 650) return 1.30;
    if (width < 900) return 1.10;
    return 1.02;
  }

  EdgeInsets _pagePadding(double width) {
    if (width < 600) return const EdgeInsets.symmetric(horizontal: 14);
    if (width < 900) return const EdgeInsets.symmetric(horizontal: 18);
    return const EdgeInsets.symmetric(horizontal: 0);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _blogsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState();
        }
        if (snapshot.hasError) {
          return ErrorState(
            message: "Failed to load blog posts. Please try again later.",
            onRetry: () => setState(() => _blogsFuture = _fetchBlogs()),
          );
        }

        final allBlogs = snapshot.data ?? [];
        if (allBlogs.isEmpty) {
          return const EmptyState(message: "No blog posts yet. Come back soon!");
        }

        final tags = _extractTags(allBlogs);
        final blogs = _applyFilters(allBlogs);

        return LayoutBuilder(
          builder: (context, constraints) {
            final pad = _pagePadding(constraints.maxWidth);

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: pad,
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 6, 0, 12),
                      child: const SectionTitle('Blogs'),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: pad,
                  sliver: SliverAppBar(
                    pinned: true,
                    floating: false,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    surfaceTintColor: Colors.transparent,
                    toolbarHeight: 0,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
                        child: _buildTopSearchBar(context, cs),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: pad,
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${blogs.length} post${blogs.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ),
                if (tags.isNotEmpty)
                  SliverPadding(
                    padding: pad,
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _TagPill(
                                label: 'All tags',
                                selected: _selectedTag == null,
                                onTap: () =>
                                    setState(() => _selectedTag = null),
                              ),
                              const SizedBox(width: 8),
                              ...tags.map(
                                (tag) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _TagPill(
                                    label: tag,
                                    selected: _selectedTag == tag,
                                    onTap: () =>
                                        setState(() => _selectedTag = tag),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (blogs.isEmpty)
                  const SliverToBoxAdapter(
                    child: EmptyState(message: "No blogs match current filters."),
                  )
                else
                  SliverPadding(
                    padding: pad,
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final cols = _gridColumns(constraints.crossAxisExtent);
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio:
                                _cardAspectRatio(constraints.crossAxisExtent),
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final blog = blogs[i];
                              return BlogGridCard(
                                title: (blog['title'] ?? '').toString(),
                                content: (blog['content'] ?? '').toString(),
                                publishedAt: _parseDate(blog['published_at']),
                                coverImage: blog['cover_image_url']?.toString(),
                                readMins: _estimateReadMinutes(
                                  (blog['content'] ?? '').toString(),
                                ),
                                onTap: () {
                                  final slug =
                                      (blog['slug'] ?? '').toString().trim();
                                  if (slug.isEmpty) return;
                                  Navigator.of(context).pushNamed(
                                    '/blog/$slug',
                                    arguments: blog,
                                  );
                                },
                              );
                            },
                            childCount: blogs.length,
                          ),
                        );
                      },
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 18)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTopSearchBar(BuildContext context, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withOpacity(0.18)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          final searchField = TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Search blogs...',
              hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.6)),
              prefixIcon: Icon(Icons.search_rounded, color: cs.secondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: cs.onSurfaceVariant,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: cs.background.withOpacity(0.45),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outline.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outline.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.secondary.withOpacity(0.6)),
              ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          );

          final chips = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TimeChip(
                  label: 'All',
                  selected: _timeFilter == TimeFilter.all,
                  onTap: () => setState(() => _timeFilter = TimeFilter.all),
                ),
                const SizedBox(width: 8),
                _TimeChip(
                  label: '7 days',
                  selected: _timeFilter == TimeFilter.last7Days,
                  onTap: () =>
                      setState(() => _timeFilter = TimeFilter.last7Days),
                ),
                const SizedBox(width: 8),
                _TimeChip(
                  label: '30 days',
                  selected: _timeFilter == TimeFilter.last30Days,
                  onTap: () =>
                      setState(() => _timeFilter = TimeFilter.last30Days),
                ),
                const SizedBox(width: 8),
                _TimeChip(
                  label: 'This year',
                  selected: _timeFilter == TimeFilter.thisYear,
                  onTap: () => setState(() => _timeFilter = TimeFilter.thisYear),
                ),
              ],
            ),
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 6, child: searchField),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: Align(alignment: Alignment.centerRight, child: chips),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchField,
              const SizedBox(height: 8),
              chips,
            ],
          );
        },
      ),
    );
  }
}

class BlogGridCard extends StatelessWidget {
  final String title;
  final String content;
  final DateTime publishedAt;
  final String? coverImage;
  final int readMins;
  final VoidCallback onTap;

  const BlogGridCard({
    Key? key,
    required this.title,
    required this.content,
    required this.publishedAt,
    required this.coverImage,
    required this.readMins,
    required this.onTap,
  }) : super(key: key);

  String _formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasImage = coverImage != null && coverImage!.trim().isNotEmpty;
    final imageUrl = hasImage
        ? (coverImage!.startsWith('http')
            ? coverImage!
            : '$storageUrl/blog/${coverImage!}')
        : null;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withOpacity(0.15)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _CoverImage(imageUrl: imageUrl),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: cs.onBackground,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: cs.secondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _formatDate(publishedAt),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: cs.secondary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: cs.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$readMins min',
                            style: TextStyle(
                              color: cs.secondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 40.ms);
  }
}

class _CoverImage extends StatelessWidget {
  final String? imageUrl;
  const _CoverImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (imageUrl == null) {
      return Container(
        color: cs.background.withOpacity(0.3),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: cs.secondary,
            size: 36,
          ),
        ),
      );
    }

    return Container(
      color: cs.background.withOpacity(0.25),
      child: Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, _, __) => Center(
          child: Icon(Icons.broken_image_rounded, color: cs.secondary, size: 34),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? cs.secondary.withOpacity(0.18)
              : cs.background.withOpacity(0.35),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: selected
                ? cs.secondary.withOpacity(0.55)
                : cs.outline.withOpacity(0.22),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? cs.secondary : cs.onSurface.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TagPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.secondary.withOpacity(0.18) : cs.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected
                ? cs.secondary.withOpacity(0.55)
                : cs.outline.withOpacity(0.22),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? cs.secondary : cs.onSurface.withOpacity(0.86),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}