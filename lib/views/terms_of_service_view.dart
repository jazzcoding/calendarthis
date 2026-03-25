import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_theme.dart';
import '../constants/terms_of_service_text.dart';
import '../widgets/app_bottom_nav.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(TermsOfServiceText.title),
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last updated text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                TermsOfServiceText.lastUpdated,
                style: AppTheme.captionStyle.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Markdown(
                data: TermsOfServiceText.content,
                styleSheet: MarkdownStyleSheet(
                  h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                  h3: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  p: Theme.of(context).textTheme.bodyMedium,
                  listBullet: Theme.of(context).textTheme.bodyMedium,
                ),
                onTapLink: (text, href, title) {
                  if (href != null) {
                    _launchUrl(href);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
