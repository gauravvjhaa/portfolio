import 'package:flutter/material.dart';
import '../widgets/layout.dart';
import '../widgets/reusable.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 48, left: 16, right: 16, bottom: 24),
      child: AnimatedContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle("About Me"),
            const SizedBox(height: 24),
            Text(
              "I'm Gaurav Jha, a Flutter developer and applied ML enthusiast based in Delhi, currently pursuing my B.Tech. in Information Technology and Mathematical Innovations at the Cluster Innovation Centre, University of Delhi.",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                height: 1.6,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "With a strong foundation in mathematics and programming, I thrive in building efficient, scalable, and user-centric applications. I've spent the last few years mastering Flutter, working on real-world apps and systems that balance elegant UI with practical performance.",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                height: 1.6,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "I enjoy working on problems that blend logic, usability, and innovation — and I'm driven by clean architecture, thoughtful design patterns, and building things that genuinely help users.",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                height: 1.6,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "I'm especially interested in the area where app development and machine learning/AI interact — and I'm always exploring ways to build smarter, more adaptive products.",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                height: 1.6,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}