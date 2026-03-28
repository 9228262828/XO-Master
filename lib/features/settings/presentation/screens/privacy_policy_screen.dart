import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          _buildHeader(context, isDark, colorScheme),
          const SizedBox(height: 24),
          ..._sections.map((s) => _PolicySection(
                title: s['title']!,
                body: s['body']!,
                isDark: isDark,
                colorScheme: colorScheme,
              )),
          const SizedBox(height: 24),
          _buildFooter(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
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
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withAlpha(220)),
          ),
          const SizedBox(height: 16),
          Text(
            'Last updated: March 2025',
            style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withAlpha(160)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This policy applies to the SpendWise mobile application for Android and iOS. For questions, contact us at privacy@spendwise.app',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurface.withAlpha(180),
              ),
            ),
          ),
        ],
      ),
    );
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
          'All data you enter into SpendWise (expenses, categories, settings) is used solely to provide the app\'s core functionality:\n\n'
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
          'The only network activity the app may perform is downloading fonts from Google Fonts on first launch if the Poppins font is not cached on your device. No personal data is sent in this request.',
    },
    {
      'title': '5. Notifications',
      'body':
          'If you enable daily reminders, SpendWise uses your device\'s local notification system to schedule reminders. These notifications are:\n\n'
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
          '• SpendWise has no involvement in or visibility into where you send the exported file\n\n'
          'Once exported, the data is subject to the privacy policies of the service you choose to share it with.',
    },
    {
      'title': '7. Children\'s Privacy',
      'body':
          'SpendWise is not directed at children under 13 years of age. We do not knowingly collect any information from children. Since we collect no information at all, the app is safe for use by people of all ages.',
    },
    {
      'title': '8. Changes to This Policy',
      'body':
          'We may update this Privacy Policy from time to time. If we make material changes, we will update the "Last updated" date at the top of this policy and release a new version of the app. Continued use of the app after changes constitutes acceptance of the updated policy.\n\n'
          'Since SpendWise is fully offline and collects no data, any changes to this policy are unlikely to affect how your data is handled.',
    },
    {
      'title': '9. Your Rights',
      'body':
          'Since all your data is stored locally on your device, you have complete control over it at all times:\n\n'
          '• Access: Open the app to view all your data\n'
          '• Correction: Edit any expense or category directly in the app\n'
          '• Deletion: Delete individual expenses, categories, or all data by uninstalling the app\n'
          '• Portability: Export your data to CSV from the Settings screen\n\n'
          'No request to us is necessary — you are the sole owner and controller of your data.',
    },
    {
      'title': '10. Contact Us',
      'body':
          'If you have questions or concerns about this Privacy Policy, please contact us:\n\n'
          'Email: privacy@spendwise.app\n\n'
          'We aim to respond to all inquiries within 7 business days.',
    },
  ];
}

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
      padding: const EdgeInsets.only(bottom: 16),
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
                color: colorScheme.onSurface.withAlpha(200),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
