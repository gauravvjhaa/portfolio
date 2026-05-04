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

    final double maxContentWidth = isLg ? 900 : (isMd ? 760 : 560);

    final double greetingSize = isXs ? 14 : (isSm ? 15 : 16);
    final double nameSize = isXs ? 30 : (isSm ? 36 : (isMd ? 44 : 56));
    final double introSize = isXs ? 13.5 : (isSm ? 15 : 17);

    final double topGap = isXs ? 16 : 24;
    final double sectionGap = isXs ? 12 : 16;
    final double afterNameGap = isXs ? 12 : 18;
    final double buttonGap = isXs ? 12 : 16;

    final introStyle = TextStyle(
      color: theme.colorScheme.onSurface.withOpacity(0.85),
      fontSize: introSize,
      fontWeight: FontWeight.w500,
      height: 1.6,
    );

    return Align(
      alignment: Alignment.topLeft, // ← changed from topCenter
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isXs ? 16 : 20,
            vertical: isSm ? 24 : 28,
          ),
          child: Column(
            mainAxisAlignment:
                isMd || isLg ? MainAxisAlignment.center : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: topGap),
              Text(
                "Hello, I'm",
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontSize: greetingSize,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: sectionGap),
              Text(
                "Gaurav Kumar Jha",
                style: TextStyle(
                  color: theme.colorScheme.onBackground,
                  fontSize: nameSize,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              SizedBox(height: afterNameGap),
              AnimatedTextKit(
                key: const ValueKey('intro_typewriter'),
                isRepeatingAnimation: false,
                totalRepeatCount: 1,
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
                animatedTexts: [
                  TypewriterAnimatedText(
                    _introText,
                    textStyle: introStyle,
                    speed: const Duration(milliseconds: 28),
                    cursor: '',
                  ),
                ],
              ),
              SizedBox(height: isXs ? 20 : 28),
              Wrap(
                spacing: buttonGap,
                runSpacing: 12,
                children: [
                  _OutlinedActionButton(
                    label: "Get In Touch",
                    onPressed: () => Navigator.pushNamed(context, '/contact'),
                    color: theme.colorScheme.secondary,
                    isCompact: isXs,
                  ),
                  if (isSm || isXs)
                    _FilledActionButton(
                      label: "Know more",
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      color: theme.colorScheme.secondary,
                      textColor: theme.primaryColor,
                      isCompact: isXs,
                    ),
                ],
              ),
              SizedBox(height: isXs ? 16 : 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.label,
    required this.onPressed,
    required this.color,
    required this.isCompact,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: color,
        elevation: 0,
        side: BorderSide(color: color, width: 1),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 20 : 28,
          vertical: isCompact ? 14 : 18,
        ),
        textStyle: TextStyle(fontSize: isCompact ? 14 : 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class _FilledActionButton extends StatelessWidget {
  const _FilledActionButton({
    required this.label,
    required this.onPressed,
    required this.color,
    required this.textColor,
    required this.isCompact,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 20 : 28,
          vertical: isCompact ? 14 : 18,
        ),
        textStyle: TextStyle(fontSize: isCompact ? 14 : 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
