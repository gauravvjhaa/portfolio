import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_theme.dart';
import 'constants.dart';

// Layout + navigation
import 'widgets/navigation.dart';
import 'widgets/components.dart';

// Pages
import 'pages/home_page.dart';
import 'pages/about_page.dart';
import 'pages/projects_page.dart';
import 'pages/skills_page.dart';
import 'pages/experience_page.dart';
import 'pages/education_page.dart';
import 'pages/blog_page.dart';
import 'pages/contact_page.dart';
import 'pages/certifications_page.dart';
import 'pages/gallery_page.dart';
import 'pages/resume_page.dart';
import 'pages/opensource_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  setPathUrlStrategy();
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaurav Jha | Portfolio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
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
