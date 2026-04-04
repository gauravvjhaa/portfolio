import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/layout.dart';
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
import 'pages/open_source_page.dart';

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to my portfolio website',
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
          transitionDuration: const Duration(milliseconds: 550),
          reverseTransitionDuration: const Duration(milliseconds: 420),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);

            final slide = Tween<Offset>(
              begin: const Offset(0, 0.02), // subtle upward settle
              end: Offset.zero,
            ).animate(curved);

            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
        );
      },
    );
  }
}
