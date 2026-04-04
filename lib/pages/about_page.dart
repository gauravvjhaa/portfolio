import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/layout.dart';
import '../widgets/reusable.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  TextStyle _bodyStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      height: 1.9,
      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.92),
      fontSize: 17,
    );
  }

  Widget _storyParagraph(BuildContext context, String text) {
    return Text(text, style: _bodyStyle(context));
  }

  Widget _linkPrompt(
    BuildContext context, {
    required String label,
    required String url,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _openLink(url),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            label,
            style: _bodyStyle(context).copyWith(
              color: Colors.lightBlueAccent.shade200,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Colors.lightBlueAccent.shade200,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionGap() => const SizedBox(height: 26);

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        width: 72,
        height: 1.2,
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.45),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 52),
      child: AnimatedContentContainer(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle("About Me"),
              const SizedBox(height: 30),

              _storyParagraph(
                context,
                "My journey into technology began with a simple curiosity: why do some problems feel impossible until you look at them through the lens of logic and patterns? "
                "That curiosity slowly turned into a deep interest in quantitative and visual reasoning.",
              ),
              _sectionGap(),
              _divider(context),

              _storyParagraph(
                context,
                "That is what led me to pursue a B.Tech in Information Technology and Mathematical Innovations at the Cluster Innovation Centre, University of Delhi. "
                "The program gave me a space where mathematics and computing could come together-not as separate subjects, but as tools to think better and build smarter.",
              ),
              _linkPrompt(
                context,
                label: "Explore course structure - Click here",
                url:
                    "http://cic.du.ac.in/userfiles/downloads/BTECH/B.Tech.%20(IT%20&%20MI)%20Collated%20Syllabus%20with%20Course%20Structure%2025.09.25.pdf",
              ),
              _sectionGap(),
              _divider(context),

              _storyParagraph(
                context,
                "As I kept learning, I started exploring technologies beyond the classroom-frameworks, tools, and workflows that help transform ideas into real products. "
                "Each new tool added a new way to solve problems.",
              ),
              _linkPrompt(
                context,
                label: "View my skills - Click here",
                url: "https://gauravbuilds.web.app/skills",
              ),
              _sectionGap(),
              _divider(context),

              _storyParagraph(
                context,
                "Over the years, I have worked on projects that reflect this mindset: practical, thoughtful, and built with purpose. "
                "For me, good software is not just about code that runs-it is about experiences that feel intuitive and useful.",
              ),
              _linkPrompt(
                context,
                label: "Browse my projects - Click here",
                url: "https://gauravbuilds.web.app/projects",
              ),
              _sectionGap(),
              _divider(context),

              _storyParagraph(
                context,
                "Alongside projects, I have also gained hands-on experience that taught me how ideas evolve in real environments—through collaboration, iteration, and continuous improvement.",
              ),
              _linkPrompt(
                context,
                label: "See my experience - Click here",
                url: "https://gauravbuilds.web.app/experience",
              ),
              _sectionGap(),
              _divider(context),

              _storyParagraph(
                context,
                "I am still learning, still building, and still excited by meaningful problems. "
                "If my work resonates with you, I would be glad to connect.",
              ),
              _linkPrompt(
                context,
                label: "Get in touch - Click here",
                url: "https://gauravbuilds.web.app/contact",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
