import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
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
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 16),
            Text(
                  "Gaurav Jha",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
            const SizedBox(height: 8),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'I build things for the web and mobile.',
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  speed: const Duration(milliseconds: 80),
                ),
              ],
              totalRepeatCount: 1,
              pause: const Duration(milliseconds: 1000),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 500,
              child: Text(
                "I'm a software developer specializing in building exceptional digital experiences. Currently, I'm focused on building accessible, human-centered products.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ).animate().fadeIn(duration: 800.ms, delay: 300.ms),
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
                )
                .animate()
                .fadeIn(duration: 1000.ms, delay: 500.ms)
                .scaleXY(begin: 0.9, end: 1.0),
          ],
        ),
      ),
    );
  }
}