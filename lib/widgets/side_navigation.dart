import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SideNavigation extends StatelessWidget {
  final bool isMobile;
  const SideNavigation({Key? key, this.isMobile = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

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

    final secondary = Theme.of(context).colorScheme.secondary;
    final onBg = Theme.of(context).colorScheme.onBackground;

    return Container(
      width: isMobile ? double.infinity : 232, // slightly tighter than 250
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        vertical: 22.0,
        horizontal: 8,
      ), // reduced horizontal padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Name/logo: forced one line + adaptive sizing
          Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                child: SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'GAURAV JHA',
                      maxLines: 1,
                      style: TextStyle(
                        color: secondary,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(
                begin: -0.12,
                end: 0,
                duration: 430.ms,
                curve: Curves.easeOutCubic,
              ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 2,
              ), // tighter left/right inset
              itemCount: navItems.length,
              itemBuilder: (context, i) {
                final item = navItems[i];
                final isActive = currentRoute == item['route'];

                return _AnimatedNavTile(
                  title: item['title']!,
                  isActive: isActive,
                  index: i,
                  onTap: () {
                    if (currentRoute == item['route']) return;

                    if (isMobile) {
                      Navigator.pop(context); // close drawer
                    }

                    // Let MaterialApp.onGenerateRoute apply transition
                    Navigator.of(context).pushReplacementNamed(item['route']!);
                  },
                  activeColor: secondary,
                  textColor: onBg,
                );
              },
            ),
          ),

          const SizedBox(height: 6),
          const SocialLinks()
              .animate(delay: 220.ms)
              .fadeIn(duration: 380.ms)
              .slideY(
                begin: 0.18,
                end: 0,
                duration: 380.ms,
                curve: Curves.easeOutCubic,
              ),
        ],
      ),
    );
  }

  Future<void> _navigateSmooth(BuildContext context, String routeName) async {
    final builder = _routeBuilder(routeName);
    if (builder == null) {
      // fallback if unknown route mapping
      Navigator.of(context).pushReplacementNamed(routeName);
      return;
    }

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        settings: RouteSettings(name: routeName),
        transitionDuration: const Duration(milliseconds: 360),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) => builder(context),
        transitionsBuilder: (_, animation, __, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final slide = Tween<Offset>(
            begin: const Offset(0.02, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  // IMPORTANT:
  // Replace these builders with your actual page widgets if names differ.
  WidgetBuilder? _routeBuilder(String route) {
    switch (route) {
      case '/home':
      case '/about':
      case '/projects':
      case '/skills':
      case '/experience':
      case '/education':
      case '/blog':
      case '/contact':
      case '/certifications':
      case '/gallery':
      case '/resume':
      case '/opensource':
        return (context) =>
            Navigator.of(context).widget.pages.isNotEmpty
                ? const SizedBox.shrink() // safe placeholder fallback for declarative nav setups
                : const SizedBox.shrink();
      default:
        return null;
    }
  }
}

class _AnimatedNavTile extends StatefulWidget {
  final String title;
  final bool isActive;
  final int index;
  final VoidCallback onTap;
  final Color activeColor;
  final Color textColor;

  const _AnimatedNavTile({
    Key? key,
    required this.title,
    required this.isActive,
    required this.index,
    required this.onTap,
    required this.activeColor,
    required this.textColor,
  }) : super(key: key);

  @override
  State<_AnimatedNavTile> createState() => _AnimatedNavTileState();
}

class _AnimatedNavTileState extends State<_AnimatedNavTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final activeBg = widget.activeColor.withOpacity(0.13);
    final hoverBg = widget.activeColor.withOpacity(0.08);

    return MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color:
                  widget.isActive
                      ? activeBg
                      : (_hover ? hoverBg : Colors.transparent),
              borderRadius: BorderRadius.circular(11),
            ),
            child: ListTile(
              dense: true,
              minLeadingWidth: 6,
              visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 0,
              ),
              leading: AnimatedContainer(
                duration: const Duration(milliseconds: 170),
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color:
                      widget.isActive ? widget.activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              title: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 170),
                style: TextStyle(
                  color:
                      widget.isActive ? widget.activeColor : widget.textColor,
                  fontWeight:
                      widget.isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15.5,
                  letterSpacing: 0.15,
                ),
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onTap: widget.onTap,
              horizontalTitleGap: 6,
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 36 * widget.index))
        .fadeIn(duration: 300.ms)
        .slideX(
          begin: -0.10,
          end: 0,
          duration: 340.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class SocialLinks extends StatelessWidget {
  const SocialLinks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 2,
        runSpacing: 2,
        children: const [
          SocialIcon(
            icon: Icons.mail_outline_rounded,
            tooltip: 'Email',
            url: 'mailto:gauravkumarjha306@gmail.com',
          ),
          SocialIcon(
            icon: Icons.terminal_rounded,
            tooltip: 'GitHub',
            url: 'https://github.com/gauravvjhaa',
          ),
          SocialIcon(
            icon: Icons.work_outline_rounded,
            tooltip: 'LinkedIn',
            url: 'https://linkedin.com/in/gauravvjhaa',
          ),
          SocialIcon(
            icon: Icons.facebook_rounded,
            tooltip: 'Facebook',
            url: 'https://www.facebook.com/profile.php?id=61583634223446',
          ),
        ],
      ),
    );
  }
}

class SocialIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final String url;

  const SocialIcon({
    Key? key,
    required this.icon,
    required this.tooltip,
    required this.url,
  }) : super(key: key);

  @override
  State<SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<SocialIcon> {
  bool _hover = false;

  Future<void> _openLink() async {
    final uri = Uri.parse(widget.url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    final onBg = Theme.of(context).colorScheme.onBackground;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _hover ? secondary.withOpacity(0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hover ? secondary.withOpacity(0.42) : Colors.transparent,
            ),
          ),
          child: IconButton(
            icon: Icon(
              widget.icon,
              color: _hover ? secondary : onBg.withOpacity(0.92),
              size: 21,
            ),
            onPressed: _openLink,
            splashRadius: 19,
          ),
        ),
      ),
    );
  }
}
