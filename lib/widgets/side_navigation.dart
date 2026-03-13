import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 1),
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
          SocialIcon(
            icon: Icons.facebook,
            url: 'https://www.facebook.com/profile.php?id=61583634223446',
          ),
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
