import 'package:flutter/material.dart';
import 'side_navigation.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          '',
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
      body: SafeArea(child: child), // <-- no global scroll here
    );
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
