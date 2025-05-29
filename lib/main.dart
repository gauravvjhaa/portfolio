import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:html' as html;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dudwzfefssvxzckffvkx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1ZHd6ZmVmc3N2eHpja2Zmdmt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg1MzA3NzAsImV4cCI6MjA2NDEwNjc3MH0.27Uxc_yppQrDb-TEueQLDl2oOtSn81IjjzFk50rEljQ',
  );
  setPathUrlStrategy();
  runApp(const PortfolioApp());
}

final supabase = Supabase.instance.client;
const String storageUrl =
    'https://dudwzfefssvxzckffvkx.supabase.co/storage/v1/object/public/portfolio-assets';

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaurav Jha | Portfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0A192F),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF64FFDA),
          surface: const Color(0xFF112240),
          background: const Color(0xFF0A192F),
          onBackground: const Color(0xFFCCD6F6),
          onSurface: const Color(0xFF8892B0),
        ),
        textTheme: GoogleFonts.montserratTextTheme(),
        scaffoldBackgroundColor: const Color(0xFF0A192F),
      ),
      initialRoute: '/home',
      onGenerateRoute: (settings) {
        final routeName = settings.name?.replaceAll('/', '');
        Widget page;
        switch (routeName) {
          case 'about':
            page = const AboutPage();
            break;
          case 'projects':
            page = const ProjectsPage();
            break;
          case 'skills':
            page = const SkillsPage();
            break;
          case 'experience':
            page = const ExperiencePage();
            break;
          case 'education':
            page = const EducationPage();
            break;
          case 'blog':
            page = const BlogPage();
            break;
          case 'contact':
            page = const ContactPage();
            break;
          case 'certifications':
            page = const CertificationsPage();
            break;
          case 'gallery':
            page = const GalleryPage();
            break;
          case 'resume':
            page = const ResumePage();
            break;
          case 'opensource':
            page = const OpenSourcePage();
            break;
          case 'home':
          default:
            page = const HomePage();
        }
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => PortfolioPage(child: page),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder:
              (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}

class PortfolioPage extends StatelessWidget {
  final Widget child;
  const PortfolioPage({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: MobileLayout(child: child),
        desktop: DesktopLayout(child: child),
      ),
    );
  }
}

class DesktopLayout extends StatelessWidget {
  final Widget child;
  const DesktopLayout({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SideNavigation(),
        Expanded(
          child: Padding(padding: const EdgeInsets.all(32.0), child: child),
        ),
      ],
    );
  }
}

class MobileLayout extends StatelessWidget {
  final Widget child;
  const MobileLayout({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text(
          'GAURAV JHA',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: const SideNavigation(isMobile: true),
        ),
      ),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(16.0), child: child),
      ),
    );
  }
}

class SideNavigation extends StatelessWidget {
  final bool isMobile;
  const SideNavigation({Key? key, this.isMobile = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'title': 'Home', 'route': '/home'},
      {'title': 'About', 'route': '/about'},
      {'title': 'Projects', 'route': '/projects'},
      {'title': 'Skills', 'route': '/skills'},
      {'title': 'Experience', 'route': '/experience'},
      {'title': 'Education', 'route': '/education'},
      {'title': 'Blog', 'route': '/blog'},
      {'title': 'Contact', 'route': '/contact'},
      {'title': 'Certifications', 'route': '/certifications'},
      {'title': 'Gallery', 'route': '/gallery'},
      {'title': 'Resume', 'route': '/resume'},
      {'title': 'Open Source', 'route': '/opensource'},
    ];

    return Container(
      width: isMobile ? double.infinity : 240,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'GAURAV JHA',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 36),
          Expanded(
            child: ListView(
              children:
                  navItems
                      .map(
                        (item) => ListTile(
                              title: Text(
                                item['title']!,
                                style: TextStyle(
                                  color:
                                      ModalRoute.of(context)?.settings.name ==
                                              item['route']
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.secondary
                                          : Theme.of(
                                            context,
                                          ).colorScheme.onBackground,
                                  fontWeight:
                                      ModalRoute.of(context)?.settings.name ==
                                              item['route']
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () {
                                if (ModalRoute.of(context)?.settings.name !=
                                    item['route']) {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed(item['route']!);

                                  // Close drawer if on mobile
                                  if (isMobile) {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                            )
                            .animate()
                            .fadeIn(duration: 350.ms)
                            .slideX(begin: -0.1, end: 0, curve: Curves.easeOut),
                      )
                      .toList(),
            ),
          ),
          const SocialLinks(),
        ],
      ),
    );
  }
}

class SocialLinks extends StatelessWidget {
  const SocialLinks({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SocialIcon(
            icon: Icons.email_outlined,
            url: 'mailto:gauravkumarjha306@gmail.com',
          ),
          SocialIcon(icon: Icons.code, url: 'https://github.com/gauravvjhaa'),
          SocialIcon(
            icon: Icons.person,
            url: 'https://linkedin.com/in/gauravvjhaa',
          ),
          SocialIcon(icon: Icons.facebook, url: 'https://facebook.com'),
        ],
      ),
    );
  }
}

class SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;

  const SocialIcon({Key? key, required this.icon, required this.url})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Theme.of(context).colorScheme.onBackground),
      onPressed: () {
        launchUrl(Uri.parse(url));
      },
      hoverColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
    );
  }
}

// ==== Helper Components ====
class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({Key? key, required this.message, this.onRetry})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.redAccent.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitHourGlass(color: Colors.black.withOpacity(0.54), size: 50.0),
          const SizedBox(height: 16),
          Text(
            "Loading...",
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          ),
        ],
      ),
    );
  }
}

// ==== Pages ====

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, I'm",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 16),
            Text(
                  "Gaurav Jha",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
            const SizedBox(height: 8),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'I build things for the web and mobile.',
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  speed: const Duration(milliseconds: 80),
                ),
              ],
              totalRepeatCount: 1,
              pause: const Duration(milliseconds: 1000),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
            const SizedBox(height: 24),
            Container(
              width: 500,
              child: Text(
                "I'm a software developer specializing in building exceptional digital experiences. Currently, I'm focused on building accessible, human-centered products.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ).animate().fadeIn(duration: 800.ms, delay: 300.ms),
            const SizedBox(height: 48),
            ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    elevation: 0,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 20,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/contact');
                  },
                  child: const Text("Get In Touch"),
                )
                .animate()
                .fadeIn(duration: 1000.ms, delay: 500.ms)
                .scaleXY(begin: 0.9, end: 1.0),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 48, left: 16, right: 16, bottom: 24),
      child: AnimatedContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle("About Me"),
            const SizedBox(height: 24),
            Text(
              "I'm Gaurav Jha, a Flutter developer and applied ML enthusiast based in Delhi, currently pursuing my B.Tech. in Information Technology and Mathematical Innovations at the Cluster Innovation Centre, University of Delhi.",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                height: 1.6,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "With a strong foundation in mathematics and programming, I thrive in building efficient, scalable, and user-centric applications. I’ve spent the last few years mastering Flutter, working on real-world apps and systems that balance elegant UI with practical performance.",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                height: 1.6,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "I enjoy working on problems that blend logic, usability, and innovation — and I’m driven by clean architecture, thoughtful design patterns, and building things that genuinely help users.",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                height: 1.6,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "I'm especially interested in the area where app development and machine learning/AI interact — and I’m always exploring ways to build smarter, more adaptive products.",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                height: 1.6,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Projects Page with Supabase ----
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
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load projects: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedContentContainer(
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
                    onRetry:
                        () =>
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
                          tags:
                              (project['tags'] as List<dynamic>?)
                                  ?.cast<String>() ??
                              [],
                          image: project['cover_image_url'],
                          githubUrl: project['github_url'],
                          liveUrl: project['live_url'],
                        ),
                      );
                    },
                  ),
                  desktop: LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children:
                            projects.map((project) {
                              return SizedBox(
                                width:
                                    constraints.maxWidth / 3 -
                                    14, // Account for spacing
                                child: ProjectCard(
                                  title: project['title'] ?? "",
                                  description: project['description'] ?? "",
                                  tags:
                                      (project['tags'] as List<dynamic>?)
                                          ?.cast<String>() ??
                                      [],
                                  image: project['cover_image_url'],
                                  githubUrl: project['github_url'],
                                  liveUrl: project['live_url'],
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
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
    final hasImage = widget.image != null && widget.image!.isNotEmpty;
    final imageUrl =
        hasImage
            ? (widget.image!.startsWith('http')
                ? widget.image!
                : '$storageUrl/projects/${widget.image}')
            : null;

    return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform:
                isHovered
                    ? (Matrix4.identity()..translate(0, -5))
                    : Matrix4.identity(),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow:
                  isHovered
                      ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            child: ClipRRect(
              // Added ClipRRect to ensure nothing overflows
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ConstrainedBox(
                          // Add constraints to the image
                          constraints: BoxConstraints(
                            maxHeight: 140,
                            maxWidth: double.infinity,
                          ),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 80,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 28,
                        ),
                        Row(
                          children: [
                            if (widget.liveUrl != null &&
                                widget.liveUrl!.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.language),
                                color: Theme.of(context).colorScheme.onSurface,
                                onPressed:
                                    () => launchUrl(Uri.parse(widget.liveUrl!)),
                                tooltip: "Visit Live Project",
                              ),
                            if (widget.githubUrl != null &&
                                widget.githubUrl!.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.code),
                                color: Theme.of(context).colorScheme.onSurface,
                                onPressed:
                                    () =>
                                        launchUrl(Uri.parse(widget.githubUrl!)),
                                tooltip: "View Source Code",
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2, // Limit title to 2 lines
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
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
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                              height: 1.5,
                            ),
                            maxLines: showFullDescription ? null : 4,
                            overflow:
                                showFullDescription
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                          ),
                          if (widget.description.length > 200)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                showFullDescription ? "Show less" : "Read more",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Wrap tags in a container with fixed height and scrolling if needed
                    SizedBox(
                      height: 36, // Fixed height for tags area
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children:
                                widget.tags
                                    .map(
                                      (tag) => Chip(
                                        label: Text(
                                          tag,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                          ),
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.1),
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
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: 100.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}

// ---- Skills Page with Supabase ----
class SkillsPage extends StatefulWidget {
  const SkillsPage({Key? key}) : super(key: key);

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  late Future<List<Map<String, dynamic>>> _skillsFuture;

  @override
  void initState() {
    super.initState();
    _skillsFuture = _fetchSkills();
  }

  Future<List<Map<String, dynamic>>> _fetchSkills() async {
    try {
      final response = await supabase
          .from('skills')
          .select()
          .order('category', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load skills: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle("Skills"),
            const SizedBox(height: 24),
            Text(
              "Here are the technologies and skills I've acquired throughout my journey:",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(height: 1.6),
            ),
            const SizedBox(height: 32),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _skillsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState();
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    message: "Failed to load skills. Please try again later.",
                    onRetry:
                        () => setState(() => _skillsFuture = _fetchSkills()),
                  );
                }

                final skills = snapshot.data ?? [];

                if (skills.isEmpty) {
                  return const EmptyState(message: "No skills to display yet.");
                }

                // Group skills by category
                final Map<String, List<Map<String, dynamic>>> skillsByCategory =
                    {};
                for (var skill in skills) {
                  final category = skill['category'] as String? ?? 'Other';
                  if (!skillsByCategory.containsKey(category)) {
                    skillsByCategory[category] = [];
                  }
                  skillsByCategory[category]!.add(skill);
                }

                return Column(
                  children:
                      skillsByCategory.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children:
                                  entry.value.map((skill) {
                                    return SkillChip(
                                      name: skill['name'] ?? '',
                                      proficiency:
                                          skill['proficiency'] as int? ?? 0,
                                    );
                                  }).toList(),
                            ),
                            const SizedBox(height: 32),
                          ],
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SkillChip extends StatelessWidget {
  final String name;
  final int proficiency;

  const SkillChip({Key? key, required this.name, required this.proficiency})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.13),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$proficiency/10',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms);
  }
}

// ---- Experience Page with Supabase ----
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
          .order('start_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load experience: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle("Experience"),
            const SizedBox(height: 24),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _experienceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState();
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    message:
                        "Failed to load experience data. Please try again later.",
                    onRetry:
                        () => setState(
                          () => _experienceFuture = _fetchExperience(),
                        ),
                  );
                }

                final experiences = snapshot.data ?? [];

                if (experiences.isEmpty) {
                  return const EmptyState(
                    message: "No work experience to display yet.",
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: experiences.length,
                  itemBuilder: (context, index) {
                    final exp = experiences[index];
                    return ExperienceCard(
                      organization: exp['organization'] ?? '',
                      title: exp['title'] ?? '',
                      location: exp['location'],
                      description: exp['description'] ?? '',
                      startDate:
                          exp['start_date'] != null
                              ? DateTime.parse(exp['start_date'])
                              : null,
                      endDate:
                          exp['end_date'] != null
                              ? DateTime.parse(exp['end_date'])
                              : null,
                      isCurrent: exp['is_current'] ?? false,
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

class ExperienceCard extends StatelessWidget {
  final String organization;
  final String title;
  final String? location;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;

  const ExperienceCard({
    Key? key,
    required this.organization,
    required this.title,
    this.location,
    required this.description,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final formatter = DateFormat('MMM yyyy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        organization,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isCurrent
                            ? Colors.green.withOpacity(0.2)
                            : Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_formatDate(startDate)} - ${isCurrent ? 'Present' : _formatDate(endDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isCurrent
                              ? Colors.green
                              : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            if (location != null && location!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    location!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }
}

// ---- Education Page with Supabase ----
class EducationPage extends StatefulWidget {
  const EducationPage({Key? key}) : super(key: key);

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  late Future<List<Map<String, dynamic>>> _educationFuture;

  @override
  void initState() {
    super.initState();
    _educationFuture = _fetchEducation();
  }

  Future<List<Map<String, dynamic>>> _fetchEducation() async {
    try {
      final response = await supabase
          .from('education')
          .select()
          .order('start_year', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load education: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle("Education"),
            const SizedBox(height: 24),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _educationFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState();
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    message:
                        "Failed to load education data. Please try again later.",
                    onRetry:
                        () => setState(
                          () => _educationFuture = _fetchEducation(),
                        ),
                  );
                }

                final education = snapshot.data ?? [];

                if (education.isEmpty) {
                  return const EmptyState(
                    message: "No education details to display yet.",
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: education.length,
                  itemBuilder: (context, index) {
                    final edu = education[index];
                    return EducationCard(
                      institution: edu['institution'] ?? '',
                      degree: edu['degree'] ?? '',
                      fieldOfStudy: edu['field_of_study'],
                      startYear: edu['start_year'] as int? ?? 0,
                      endYear: edu['end_year'] as int?,
                      grade: edu['grade'],
                      location: edu['location'],
                      description: edu['description'],
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

class EducationCard extends StatelessWidget {
  final String institution;
  final String degree;
  final String? fieldOfStudy;
  final int startYear;
  final int? endYear;
  final String? grade;
  final String? location;
  final String? description;

  const EducationCard({
    Key? key,
    required this.institution,
    required this.degree,
    this.fieldOfStudy,
    required this.startYear,
    this.endYear,
    this.grade,
    this.location,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isCurrent = endYear == null;
    final yearText = '$startYear - ${isCurrent ? 'Present' : endYear}';

    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        degree,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        institution,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    yearText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            if (fieldOfStudy != null && fieldOfStudy!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                fieldOfStudy!,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
            if (location != null && location!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    location!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
            if (grade != null && grade!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.grade,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Grade: $grade',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                description!,
                style: TextStyle(
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }
}

// ---- Blog Page with Supabase ----
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
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.6),
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
                    onRetry: () => setState(() => _blogsFuture = _fetchBlogs()),
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
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: blogs.length,
                  itemBuilder: (context, index) {
                    final blog = blogs[index];
                    return BlogPostCard(
                      title: blog['title'] ?? '',
                      slug: blog['slug'] ?? '',
                      summary: blog['summary'] ?? '',
                      content: blog['content'] ?? '',
                      publishedAt:
                          blog['published_at'] != null
                              ? DateTime.parse(blog['published_at'])
                              : DateTime.now(),
                      tags:
                          (blog['tags'] as List<dynamic>?)?.cast<String>() ??
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
    final imageUrl =
        hasImage
            ? (widget.coverImage!.startsWith('http')
                ? widget.coverImage!
                : '$storageUrl/blog/${widget.coverImage}')
            : null;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.fitHeight,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 160,
                          width: double.infinity,
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.1),
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Theme.of(context).colorScheme.secondary,
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
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
                      backgroundColor: Theme.of(context).colorScheme.background,
                      color: Theme.of(context).colorScheme.secondary,
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
                children:
                    widget.tags.map((tag) {
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
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms);
  }
}

// ---- Certifications Page with Supabase ----
class CertificationsPage extends StatefulWidget {
  const CertificationsPage({Key? key}) : super(key: key);

  @override
  State<CertificationsPage> createState() => _CertificationsPageState();
}

class _CertificationsPageState extends State<CertificationsPage> {
  late Future<List<Map<String, dynamic>>> _certificationsFuture;

  @override
  void initState() {
    super.initState();
    _certificationsFuture = _fetchCertifications();
  }

  Future<List<Map<String, dynamic>>> _fetchCertifications() async {
    try {
      final response = await supabase
          .from('certificates')
          .select()
          .order('issue_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load certifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle("Certifications"),
            const SizedBox(height: 24),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _certificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState();
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    message:
                        "Failed to load certifications. Please try again later.",
                    onRetry:
                        () => setState(
                          () => _certificationsFuture = _fetchCertifications(),
                        ),
                  );
                }

                final certs = snapshot.data ?? [];

                if (certs.isEmpty) {
                  return const EmptyState(
                    message: "No certifications to display yet.",
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: certs.length,
                  itemBuilder: (context, index) {
                    final cert = certs[index];
                    return CertificateCard(
                      name: cert['name'] ?? '',
                      authority: cert['authority'] ?? '',
                      description: cert['description'],
                      issueDate:
                          cert['issue_date'] != null
                              ? DateTime.parse(cert['issue_date'])
                              : null,
                      expiryDate:
                          cert['expiry_date'] != null
                              ? DateTime.parse(cert['expiry_date'])
                              : null,
                      credentialId: cert['credential_id'],
                      credentialUrl: cert['credential_url'],
                      fileUrl: cert['file_url'],
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

class CertificateCard extends StatelessWidget {
  final String name;
  final String authority;
  final String? description;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? credentialId;
  final String? credentialUrl;
  final String? fileUrl;

  const CertificateCard({
    Key? key,
    required this.name,
    required this.authority,
    this.description,
    this.issueDate,
    this.expiryDate,
    this.credentialId,
    this.credentialUrl,
    this.fileUrl,
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final formatter = DateFormat('MMM yyyy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final hasFileUrl = fileUrl != null && fileUrl!.isNotEmpty;
    final certificateFileUrl =
        hasFileUrl
            ? (fileUrl!.startsWith('http')
                ? fileUrl!
                : '$storageUrl/certificates/$fileUrl')
            : null;

    final hasCredentialUrl = credentialUrl != null && credentialUrl!.isNotEmpty;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            certificateFileUrl != null
                ? () {
                  html.window.open(certificateFileUrl, 'Certificate');
                }
                : null,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        Text(
                          authority,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (certificateFileUrl != null)
                    IconButton(
                      icon: const Icon(Icons.file_open),
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () {
                        html.window.open(certificateFileUrl, 'Certificate');
                      },
                      tooltip: 'View Certificate',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (issueDate != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Issued: ${_formatDate(issueDate)}${expiryDate != null ? ' • Expires: ${_formatDate(expiryDate)}' : ''}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
              if (credentialId != null && credentialId!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.badge,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Credential ID: $credentialId',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  description!,
                  style: TextStyle(
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
              if (hasCredentialUrl) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: const Icon(Icons.verified),
                  label: const Text('Verify Credential'),
                  onPressed: () {
                    launchUrl(Uri.parse(credentialUrl!));
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }
}

// ---- Gallery Page with Supabase ----
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
      // Since we don't have a specific gallery table in our schema,
      // we can either create one or simply list files from the gallery folder
      final response = await supabase.storage
          .from('portfolio-assets')
          .list(path: 'gallery');

      // Convert storage objects to a normalized format
      return response
          .map(
            (file) => {
              'name': file.name,
              'url': '$storageUrl/gallery/${file.name}',
              'created_at': file.createdAt,
            },
          )
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(height: 1.6),
                ),
                const SizedBox(height: 32),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _galleryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingState();
                    }

                    if (snapshot.hasError) {
                      return ErrorState(
                        message:
                            "Failed to load gallery. Please try again later.",
                        onRetry:
                            () => setState(
                              () => _galleryFuture = _fetchGallery(),
                            ),
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
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final image = images[index];
                          return GalleryImage(
                            imageUrl: image['url'],
                            title: image['name'],
                            onTap: () => _openImageViewer(image['url']),
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
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final image = images[index];
                          return GalleryImage(
                            imageUrl: image['url'],
                            title: image['name'],
                            onTap: () => _openImageViewer(image['url']),
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
        // Full-screen image viewer
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
                    child: Image.network(_selectedImage!, fit: BoxFit.contain),
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
                      onPressed: () => setState(() => _selectedImage = null),
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
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.1),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                ),
                // Overlay on hover
                AnimatedOpacity(
                  opacity: isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.title != null)
                          Text(
                            widget.title!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.zoom_in, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
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

// ---- Open Source Page with Supabase ----
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

// ---- Contact Page ----
class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;
  bool _submitted = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://dudwzfefssvxzckffvkx.supabase.co/functions/v1/resend-email',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'message': _messageController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isSubmitting = false;
          _submitted = true;
        });
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      } else {
        setState(() {
          _isSubmitting = false;
          _error = 'Failed to send message. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = 'Failed to send message. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle("Contact"),
            const SizedBox(height: 24),
            Text(
              "Feel free to reach out to me with any questions or opportunities.",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(height: 1.6),
            ),
            const SizedBox(height: 32),
            Responsive(
              mobile: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContactInfo(context),
                  const SizedBox(height: 40),
                  _buildContactForm(context),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildContactInfo(context)),
                  const SizedBox(width: 60),
                  Expanded(flex: 3, child: _buildContactForm(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's Connect",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildContactItem(
          context,
          Icons.email,
          "Email",
          "gauravkumarjha306@cic.du.ac.in",
        ),
        _buildContactItem(context, Icons.phone, "Phone", "+91 9354897359"),
        _buildContactItem(
          context,
          Icons.location_on,
          "Location",
          "Delhi, India",
        ),
        const SizedBox(height: 24),
        Text(
          "Or find me on social media:",
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SocialIconWithLabel(
              icon: Icons.code,
              label: 'GitHub',
              url: 'https://github.com/gauravvjhaa',
            ),
            const SizedBox(width: 16),
            SocialIconWithLabel(
              icon: Icons.person,
              label: 'LinkedIn',
              url: 'https://linkedin.com/in/gauravvjhaa',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm(BuildContext context) {
    if (_submitted) {
      return Card(
        color: Colors.green.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Message Sent!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for reaching out. I will get back to you as soon as possible.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _submitted = false;
                  });
                },
                child: const Text('Send Another Message'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Send Me a Message",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Message',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 5,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.background,
                  ),
                  child:
                      _isSubmitting
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Theme.of(context).colorScheme.background,
                            ),
                          )
                          : const Text('Send Message'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SocialIconWithLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const SocialIconWithLabel({
    Key? key,
    required this.icon,
    required this.label,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: () {
        launchUrl(Uri.parse(url));
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.secondary,
        side: BorderSide(color: Theme.of(context).colorScheme.secondary),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}

// == Reusable Components ==

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            thickness: 1,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0);
  }
}

class AnimatedContentContainer extends StatelessWidget {
  final Widget child;
  const AnimatedContentContainer({Key? key, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: child,
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05, end: 0);
  }
}

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;
  const Responsive({Key? key, required this.mobile, required this.desktop})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return mobile;
        } else {
          return desktop;
        }
      },
    );
  }
}
