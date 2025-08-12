import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../widgets/components.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late Future<List<Map<String, dynamic>>> _galleryFuture;
  String? _selectedImage;

  @override
  void initState() {
    super.initState();
    _galleryFuture = _fetchGallery();
  }

  Future<List<Map<String, dynamic>>> _fetchGallery() async {
    try {
      final response = await supabase.storage
          .from('portfolio-assets')
          .list(path: 'gallery');

      return response
          .map((file) => {
                'name': file.name,
                'url': '$storageUrl/gallery/${file.name}',
                'created_at': file.createdAt,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to load gallery: $e');
    }
  }

  void _openImageViewer(String imageUrl) {
    setState(() {
      _selectedImage = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: AnimatedContentContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle("Gallery"),
                const SizedBox(height: 24),
                Text(
                  "A collection of images showcasing my work and experiences.",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(height: 1.6),
                ),
                const SizedBox(height: 32),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _galleryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const LoadingState();
                    }

                    if (snapshot.hasError) {
                      return ErrorState(
                        message:
                            "Failed to load gallery. Please try again later.",
                        onRetry: () => setState(
                            () => _galleryFuture = _fetchGallery()),
                      );
                    }

                    final images = snapshot.data ?? [];

                    if (images.isEmpty) {
                      return const EmptyState(
                        message: "No images in the gallery yet.",
                      );
                    }

                    return Responsive(
                      mobile: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final image = images[index];
                          return GalleryImage(
                            imageUrl: image['url'],
                            title: image['name'],
                            onTap: () =>
                                _openImageViewer(image['url']),
                          );
                        },
                      ),
                      desktop: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final image = images[index];
                          return GalleryImage(
                            imageUrl: image['url'],
                            title: image['name'],
                            onTap: () =>
                                _openImageViewer(image['url']),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (_selectedImage != null)
          GestureDetector(
            onTap: () => setState(() => _selectedImage = null),
            child: Container(
              color: Colors.black.withOpacity(0.9),
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Center(
                    child: Image.network(_selectedImage!,
                        fit: BoxFit.contain),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () =>
                          setState(() => _selectedImage = null),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class GalleryImage extends StatefulWidget {
  final String imageUrl;
  final String? title;
  final VoidCallback onTap;

  const GalleryImage({
    Key? key,
    required this.imageUrl,
    this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  State<GalleryImage> createState() => _GalleryImageState();
}

class _GalleryImageState extends State<GalleryImage> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.1),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: isHovered ? 1.0 : 0.0,
                  duration:
                      const Duration(milliseconds: 200),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end:
                            Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        if (widget.title != null)
                          Text(
                            widget.title!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.zoom_in,
                                color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Click to enlarge',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
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
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms);
  }
}