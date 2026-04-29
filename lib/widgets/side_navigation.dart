import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SideNavigation extends StatelessWidget {
  final bool isMobile;
  const SideNavigation({Key? key, this.isMobile = false}) : super(key: key);

  static const List<Map<String, String>> _navItems = [
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

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final secondary = Theme.of(context).colorScheme.secondary;
    final onBg = Theme.of(context).colorScheme.onBackground;

    return Container(
      width: isMobile ? double.infinity : 232,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _NavHeader(),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              itemCount: _navItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, i) {
                final item = _navItems[i];
                final route = item['route']!;
                final isActive = currentRoute == route;

                return _NavTile(
                  title: item['title']!,
                  isActive: isActive,
                  activeColor: secondary,
                  textColor: onBg,
                  onTap: () {
                    if (isActive) return;
                    if (isMobile) Navigator.pop(context);
                    Navigator.of(context).pushReplacementNamed(route);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const SocialLinks(),
        ],
      ),
    );
  }
}

class _NavHeader extends StatelessWidget {
  const _NavHeader();

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: SizedBox(
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '',
            maxLines: 1,
            style: TextStyle(
              color: secondary,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color textColor;

  const _NavTile({
    Key? key,
    required this.title,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.textColor,
  }) : super(key: key);

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final activeBg = widget.activeColor.withOpacity(0.12);
    final hoverBg = widget.activeColor.withOpacity(0.07);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color:
              widget.isActive
                  ? activeBg
                  : (_hover ? hoverBg : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          dense: true,
          visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
          minLeadingWidth: 6,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: widget.isActive ? widget.activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          horizontalTitleGap: 6,
          title: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: widget.isActive ? widget.activeColor : widget.textColor,
              fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15.2,
              letterSpacing: 0.1,
            ),
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

class SocialLinks extends StatelessWidget {
  const SocialLinks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 2,
        runSpacing: 2,
        children: [
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
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _hover ? secondary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hover ? secondary.withOpacity(0.35) : Colors.transparent,
            ),
          ),
          child: IconButton(
            splashRadius: 19,
            onPressed: _openLink,
            icon: Icon(
              widget.icon,
              size: 21,
              color: _hover ? secondary : onBg.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }
}
