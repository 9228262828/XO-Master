import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _contactEmail = 'privacy@spendwise.app';
  static const String _websiteUrl = 'https://9228262828.github.io/SpendWise/privacy/';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _buildHeader(context, isDark),
          const SizedBox(height: 24),
          ..._sections.map((s) => _PolicySection(
                title: s['title']!,
                body: s['body']!,
                isDark: isDark,
                colorScheme: colorScheme,
              )),

          // ── Contact section with tappable links ──────────────────────────
          const SizedBox(height: 8),
          _buildContactSection(context, isDark, colorScheme),
          const SizedBox(height: 16),

          // ── Link to Terms & Conditions ────────────────────────────────────
          _buildTermsLink(context, isDark, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Privacy Matters',
            style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'SpendWise is built with a privacy-first approach. All your data stays on your device — we never collect, sell, or share your personal information.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 12, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(
                'Last updated: March 2025  •  Version 1.0',
                style: AppTextStyles.labelSmall
                    .copyWith(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(
      BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '10. Contact Us',
            style: AppTextStyles.headlineSmall
                .copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            'If you have questions or concerns about this Privacy Policy, please reach out:',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),

          // Email link
          _LinkTile(
            icon: Icons.email_outlined,
            label: _contactEmail,
            onTap: () => _launchEmail(context),
          ),
          const SizedBox(height: 8),

          // Website link
          _LinkTile(
            icon: Icons.language_rounded,
            label: _websiteUrl,
            onTap: () => _launchWebsite(context),
          ),

          const SizedBox(height: 12),
          Text(
            'We aim to respond to all inquiries within 7 business days.',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsLink(
      BuildContext context, bool isDark, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => context.push(AppRoutes.terms),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.gavel_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms & Conditions',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Read our full terms of service',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _contactEmail,
      query: 'subject=SpendWise Privacy Policy Inquiry',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open mail app. Email us at $_contactEmail'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _launchWebsite(BuildContext context) async {
    final uri = Uri.parse(_websiteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open browser'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static const List<Map<String, String>> _sections = [
    {
      'title': '1. Information We Collect',
      'body':
          'SpendWise does not collect any personal information from you. The app operates entirely offline. All expense data, categories, and settings you enter are stored locally on your device using a local database (Hive) and are never transmitted to any server.\n\n'
          'We do not collect:\n'
          '• Names, email addresses, or contact information\n'
          '• Financial account numbers or banking data\n'
          '• Location data\n'
          '• Device identifiers or analytics data\n'
          '• Any usage statistics or behavioral data',
    },
    {
      'title': '2. How Your Data Is Used',
      'body':
          'All data you enter into SpendWise is used solely to provide the app\'s core functionality:\n\n'
          '• Displaying your expense history and summaries\n'
          '• Generating charts and reports\n'
          '• Storing your preferences (theme, currency, language)\n'
          '• Scheduling local notifications (reminders) on your device\n\n'
          'This data never leaves your device. We have no access to it.',
    },
    {
      'title': '3. Data Storage & Security',
      'body':
          'Your data is stored locally on your device using Hive, a lightweight and secure NoSQL database. The data is stored in your app\'s private storage area, which is protected by your device\'s built-in security mechanisms.\n\n'
          '• Data is stored in the app\'s sandboxed storage\n'
          '• Only SpendWise can access this data\n'
          '• Data is included in your device\'s backup if you have backups enabled\n'
          '• Uninstalling the app permanently deletes all your data',
    },
    {
      'title': '4. Third-Party Services',
      'body':
          'SpendWise does not integrate with any third-party analytics, advertising, or tracking services. The app does not contain:\n\n'
          '• Advertising SDKs\n'
          '• Analytics platforms (e.g. Firebase Analytics, Mixpanel)\n'
          '• Crash reporting services that transmit data externally\n'
          '• Social media integrations\n\n'
          'The only network activity the app may perform is downloading fonts from Google Fonts on first launch if the Poppins font is not cached. No personal data is sent in this request.',
    },
    {
      'title': '5. Notifications',
      'body':
          'If you enable daily reminders, SpendWise uses your device\'s local notification system. These notifications are:\n\n'
          '• Generated entirely on your device\n'
          '• Not sent through any external server\n'
          '• Controlled entirely by you in the Settings screen\n'
          '• Revokable at any time via app settings or device notification settings',
    },
    {
      'title': '6. Data Export',
      'body':
          'SpendWise allows you to export your expense data as a CSV file. When you use this feature:\n\n'
          '• The CSV file is generated on your device\n'
          '• You choose where to send or save it using your device\'s share sheet\n'
          '• SpendWise has no visibility into where you send the exported file\n\n'
          'Once exported, the data is subject to the privacy policy of the service you choose.',
    },
    {
      'title': '7. Children\'s Privacy',
      'body':
          'SpendWise is not directed at children under 13 years of age. Since we collect no information at all, the app is safe for use by people of all ages.',
    },
    {
      'title': '8. Changes to This Policy',
      'body':
          'We may update this Privacy Policy from time to time. If we make material changes, we will update the "Last updated" date at the top of this policy and release a new version of the app.\n\n'
          'Since SpendWise is fully offline and collects no data, any changes to this policy are unlikely to affect how your data is handled.',
    },
    {
      'title': '9. Your Rights',
      'body':
          'Since all your data is stored locally on your device, you have complete control:\n\n'
          '• Access: Open the app to view all your data\n'
          '• Correction: Edit any expense or category directly in the app\n'
          '• Deletion: Delete individual items, or uninstall the app to delete everything\n'
          '• Portability: Export your data to CSV from the Settings screen\n\n'
          'No request to us is necessary — you are the sole owner and controller of your data.',
    },
  ];
}

// ─── Shared link tile widget ────────────────────────────────────────────────
class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

// ─── Section card ─────────────────────────────────────────────────────────
class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.title,
    required this.body,
    required this.isDark,
    required this.colorScheme,
  });

  final String title;
  final String body;
  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.78),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
