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
    final introStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 17,
      fontWeight: FontWeight.w500,
      height: 1.6,
    );

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
            ),
            const SizedBox(height: 16),
            Text(
              "Gaurav Kumar Jha",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 50,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 18),

            // Fixed box prevents layout shifting while typing
            SizedBox(
              width: 900,
              height: 120,
              child: AnimatedTextKit(
                key: const ValueKey('intro_typewriter'),
                isRepeatingAnimation: false,
                totalRepeatCount: 1,
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
                animatedTexts: [
                  TypewriterAnimatedText(
                    _introText,
                    textStyle: introStyle,
                    speed: const Duration(milliseconds: 30),
                    cursor: '', // remove cursor to reduce perceived movement
                  ),
                ],
              ),
            ),

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
            ),
          ],
        ),
      ),
    );
  }
}
