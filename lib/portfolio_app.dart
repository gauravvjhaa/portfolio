import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/pages/admin/admin_page.dart';
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
          case 'admin':
            final args =
                settings.arguments as Map<String, dynamic>?; // <-- add this
            final token = args?['token'] as String?;
            print('Admin token: $token'); // <-- debug print
            page = AdminPage(token: token!); // <-- pass token
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
