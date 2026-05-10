import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _introText =
      "I'm a computer science student passionate about building meaningful digital experiences. "
      "My interests include mobile & web development, artificial intelligence, competitive programming, and core computer science.";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final bool isXs = width < 360;
    final bool isSm = width >= 360 && width < 600;
    final bool isMd = width >= 600 && width < 1024;
    final bool isLg = width >= 1024;

    final double nameSize = isXs ? 30 : (isSm ? 38 : (isMd ? 48 : 60));
    final double introSize = isXs ? 13.5 : (isSm ? 15 : 16.5);

    final introStyle = TextStyle(
      color: theme.colorScheme.onSurface.withOpacity(0.88),
      fontSize: introSize,
      fontWeight: FontWeight.w500,
      height: 1.65,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isXs ? 16 : 24,
            vertical: isXs ? 20 : 32,
          ),
          child: isLg
              ? Row(
                  children: [
                    Expanded(
                      flex: 52,
                      child: _HeroText(
                        theme: theme,
                        nameSize: nameSize,
                        introStyle: introStyle,
                        introText: _introText,
                        isXs: isXs,
                      ),
                    ),
                    const SizedBox(width: 52),
                    const Expanded(
                      flex: 48,
                      child: _HeroImage(),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroText(
                        theme: theme,
                        nameSize: nameSize,
                        introStyle: introStyle,
                        introText: _introText,
                        isXs: isXs,
                      ),
                      const SizedBox(height: 32),
                      const _HeroImage(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({
    required this.theme,
    required this.nameSize,
    required this.introStyle,
    required this.introText,
    required this.isXs,
  });

  final ThemeData theme;
  final double nameSize;
  final TextStyle introStyle;
  final String introText;
  final bool isXs;

  @override
  Widget build(BuildContext context) {
    final secondary = theme.colorScheme.secondary;
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hello, I'm",
          style: TextStyle(
            color: secondary,
            fontSize: isXs ? 14 : 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "Gaurav Kumar Jha",
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontSize: nameSize,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "Computer Science Student • App Dev • AI/ML • DSA",
          style: TextStyle(
            color: secondary.withOpacity(0.9),
            fontSize: isXs ? 13.5 : 16,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        AnimatedTextKit(
          key: const ValueKey('intro_typewriter'),
          isRepeatingAnimation: false,
          totalRepeatCount: 1,
          displayFullTextOnTap: true,
          stopPauseOnTap: true,
          animatedTexts: [
            TypewriterAnimatedText(
              introText,
              textStyle: introStyle,
              speed: const Duration(milliseconds: 22),
              cursor: '',
            ),
          ],
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
                        _HighlightChip(
              icon: Icons.leaderboard_outlined,
              title: "GATE 2026",
              subtitle: "99.4%ile",
              color: secondary,
            ),
            _HighlightChip(
              icon: Icons.school_outlined,
              title: "UGC NET JRF",
              subtitle: "99.8%ile",
              color: secondary,
            ),
_HighlightChip(
  icon: Icons.psychology_alt_outlined,
  title: "AI Systems",
  subtitle: "Exploring & Learning",
  color: secondary,
),
          ],
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            _FilledActionButton(
              label: isMobile ? "Know More" : "View Projects",
              icon: isMobile ? Icons.menu_rounded : Icons.arrow_forward_rounded,
              onPressed: () {
                if (isMobile) {
                  Scaffold.of(context).openDrawer();
                } else {
                  Navigator.pushNamed(context, '/projects');
                }
              },
              color: secondary,
              textColor: theme.primaryColor,
              isCompact: isXs,
            ),
            _OutlinedActionButton(
              label: "Get In Touch",
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: () => Navigator.pushNamed(context, '/contact'),
              color: secondary,
              isCompact: isXs,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;

    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: secondary.withOpacity(0.22),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: secondary.withOpacity(0.10),
            blurRadius: 42,
            spreadRadius: 2,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Image.asset(
              'assets/main.webp',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.08),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 174,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color.withOpacity(0.95),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.isCompact,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: color,
        elevation: 0,
        side: BorderSide(color: color.withOpacity(0.75), width: 1),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 18 : 24,
          vertical: isCompact ? 14 : 17,
        ),
        textStyle: TextStyle(
          fontSize: isCompact ? 14 : 15.5,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _FilledActionButton extends StatelessWidget {
  const _FilledActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.textColor,
    required this.isCompact,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 18 : 24,
          vertical: isCompact ? 14 : 17,
        ),
        textStyle: TextStyle(
          fontSize: isCompact ? 14 : 15.5,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: onPressed,
      label: Text(label),
      icon: Icon(icon, size: 18),
    );
  }
}